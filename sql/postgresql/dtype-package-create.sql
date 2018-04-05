-- Dynamic Types dynamic view generation.

-- Based on cms code by Michael Pih (pihman@arsdigita.com) and 
-- Karl Goldstein (karlg@arsdigita.com)

-----------------------------
-- timo:
-- i am quite emberassed to do this, but the OCT wouldn't want it
-- any other way, so here they have it. they'll gonna change it
-- anyway, if this makes it into the core...
-----------------------------

create table dtype_attributes (
  attribute_id     integer
                   constraint dtype_attributes_pk
                   primary key
                   constraint dtype_attributes_fk
                   references acs_attributes
);



select define_function_args('dynamic_type__create_type','object_type,supertype;acs_object,pretty_name,pretty_plural,table_name,id_column;XXX,name_method');

create or replace function dynamic_type__create_type (varchar,varchar,varchar,varchar,varchar,varchar,varchar)
returns integer as '
declare
  p_object_type            alias for $1;  
  p_supertype              alias for $2;  -- default ''acs_object''  
  p_pretty_name            alias for $3;  
  p_pretty_plural          alias for $4;  
  p_table_name             alias for $5;
  p_id_column              alias for $6;  -- default ''XXX''
  p_name_method            alias for $7;  -- default null
  v_table_exists_p         boolean;
  v_supertype_table        acs_object_types.table_name%TYPE;
begin

  -- create the attribute table if not already created

  select count(*) > 0 into v_table_exists_p 
    from pg_class
   where relname = lower(p_table_name);

  if NOT v_table_exists_p then
    select table_name into v_supertype_table from acs_object_types
      where object_type = p_supertype;

    execute ''create table '' || p_table_name || '' ('' ||
      p_id_column  || '' integer primary key references '' || 
      v_supertype_table || '')'';
  end if;

  PERFORM acs_object_type__create_type (
    p_object_type,
    p_pretty_name,
    p_pretty_plural,
    p_supertype,
    p_table_name,
    p_id_column,
    null,
    ''f'',
    null,
    p_name_method
  );

  update acs_object_types
  set dynamic_p = true
  where object_type = p_object_type;

  PERFORM dynamic_type__refresh_view(p_object_type);

  return 0; 
end;' language 'plpgsql';

select define_function_args('dynamic_type__drop_type','object_type,drop_children_p;f,drop_table_p;f');

create or replace function dynamic_type__drop_type (varchar,boolean,boolean)
returns integer as '
declare
  p_object_type           alias for $1;  
  p_drop_children_p       alias for $2;  -- default ''f''  
  p_drop_table_p          alias for $3;  -- default ''f''
  table_exists_p          boolean;       
  v_table_name            varchar;   
  is_subclassed_p         boolean;      
  child_rec               record;    
  attr_row                record;
begin

  -- first we''ll rid ourselves of any dependent child types, if any , 
  -- along with their own dependent grandchild types

  select 
    count(*) > 0 into is_subclassed_p 
  from 
    acs_object_types 
  where supertype = p_object_type;

  -- this is weak and will probably break;
  -- to remove grand child types, the process will probably
  -- require some sort of querying for drop_type 
  -- methods within the children''s packages to make
  -- certain there are no additional unanticipated
  -- restraints preventing a clean drop

  if p_drop_children_p and is_subclassed_p then

    for child_rec in select 
                       object_type
                     from 
                       acs_object_types
                     where
                       supertype = p_object_type 
    LOOP
      PERFORM dynamic_type__drop_type(child_rec.object_type, 
                                      ''t'', 
                                      p_drop_table_p);
    end LOOP;

  end if;

  -- now drop all the attributes related to this type
  for attr_row in select
                    attribute_name
                  from
                    acs_attributes
                  where
                    object_type = p_object_type 
  LOOP
    PERFORM dynamic_type__drop_attribute(p_object_type,
                                         attr_row.attribute_name,
                                         ''f''
    );
  end LOOP;

  -- we''ll remove the associated table if it exists
  select 
    table_exists(lower(table_name)) into table_exists_p
  from 
    acs_object_types
  where 
    object_type = p_object_type;

  if table_exists_p and p_drop_table_p then
    select 
      table_name into v_table_name 
    from 
      acs_object_types 
    where
      object_type = p_object_type;
       
    -- drop the rule and input/output views for the type
    -- being dropped.
    -- FIXME: this did not exist in the oracle code and it needs to be
    -- tested.  Thanks to Vinod Kurup for pointing this out.
    -- The rule dropping might be redundant as the rule might be dropped
    -- when the view is dropped.

    -- different syntax for dropping a rule in 7.2 and 7.3 so check which
    -- version is being used (olah).

    if version() like ''%7.2%'' then
      execute ''drop rule '' || v_table_name || ''_r'';
    else
      -- 7.3 syntax
      execute ''drop rule '' || v_table_name || ''_r '' || ''on '' || v_table_name || ''i'';
    end if;

    execute ''drop view '' || v_table_name || ''x'';
    execute ''drop view '' || v_table_name || ''i'';

    execute ''drop table '' || v_table_name;
  end if;

  PERFORM acs_object_type__drop_type(p_object_type, ''f'');

  return 0; 
end;' language 'plpgsql';

select define_function_args('dynamic_type__create_attribute','object_type,attribute_name,datatype,pretty_name,pretty_plural,sort_order,default_value,column_spec;text');

-- function create_attribute
create or replace function dynamic_type__create_attribute (varchar,varchar,varchar,varchar,varchar,integer,varchar,varchar)
returns integer as '
declare
  p_object_type           alias for $1;  
  p_attribute_name        alias for $2;  
  p_datatype              alias for $3;  
  p_pretty_name           alias for $4;  
  p_pretty_plural         alias for $5;  -- default null  
  p_sort_order            alias for $6;  -- default null
  p_default_value         alias for $7;  -- default null
  p_column_spec           alias for $8;  -- default ''text''
  v_attr_id               acs_attributes.attribute_id%TYPE;
  v_table_name            acs_object_types.table_name%TYPE;
  v_column_exists         boolean;       
begin

 -- add the appropriate column to the table
 
 select table_name into v_table_name from acs_object_types
  where object_type = p_object_type;

 if NOT FOUND then
   raise EXCEPTION ''-20000: Object type % does not exist in dynamic_type.create_attribute'', p_object_type;
 end if; 

 select count(*) > 0 into v_column_exists 
   from pg_class c, pg_attribute a
  where c.relname::varchar = v_table_name
    and c.oid = a.attrelid
    and a.attname = lower(p_attribute_name);

 if NOT v_column_exists then
   execute ''alter table '' || v_table_name || '' add '' || 
      p_attribute_name || '' '' 
      || p_column_spec;
 end if;

 v_attr_id := acs_attribute__create_attribute (
   p_object_type,
   p_attribute_name,
   p_datatype,
   p_pretty_name,
   p_pretty_plural,
   null,
   null,
   p_default_value,
   0,
   1,
   p_sort_order,
   ''type_specific'',
   ''f''
 );

 insert into dtype_attributes values (v_attr_id);

 PERFORM dynamic_type__refresh_view(p_object_type);

 return v_attr_id;

end;' language 'plpgsql';


-- procedure drop_attribute

select define_function_args('dynamic_type__drop_attribute','object_type,attribute_name,drop_column;f');

create or replace function dynamic_type__drop_attribute (varchar,varchar,boolean)
returns integer as '
declare
  p_object_type           alias for $1;  
  p_attribute_name        alias for $2;  
  p_drop_column           alias for $3;  -- default ''f''  
  v_attr_id               acs_attributes.attribute_id%TYPE;
  v_table                 acs_object_types.table_name%TYPE;
begin

  -- Get attribute information 
  select 
    upper(t.table_name), a.attribute_id 
  into 
    v_table, v_attr_id
  from 
    acs_object_types t, acs_attributes a
  where 
    t.object_type = p_object_type
  and 
    a.object_type = p_object_type
  and
    a.attribute_name = p_attribute_name;
    
  if NOT FOUND then
    raise EXCEPTION ''-20000: Attribute %:% does not exist in dynamic_type.drop_attribute'', p_object_type, p_attribute_name;
  end if;

  -- Drop the attribute
  delete from dtype_attributes where attribute_id = v_attr_id;

  PERFORM acs_attribute__drop_attribute(p_object_type, 
                                        p_attribute_name);

  -- Drop the column if necessary
  if p_drop_column then
      execute ''alter table '' || v_table || '' drop column '' ||
	        p_attribute_name || '' cascade'';
  end if;  

  PERFORM dynamic_type__refresh_view(p_object_type);

  return 0; 
end;' language 'plpgsql';


-- function trigger_insert_statement
create or replace function dynamic_type__trigger_insert_statement (varchar)
returns varchar as '
declare
  p_object_type   alias for $1;  
  v_table_name    acs_object_types.table_name%TYPE;
  v_id_column     acs_object_types.id_column%TYPE;
  cols            varchar default '''';
  vals            varchar default '''';
  attr_rec        record;
begin
  if p_object_type is null then 
    return exception ''dynamic_type__trigger_insert_statement called with null object_type'';
  end if;

  select 
    table_name, id_column into v_table_name, v_id_column
  from 
    acs_object_types 
  where 
    object_type = p_object_type;

  for attr_rec in select
                    attribute_name
                  from
                    acs_attributes
                  where
                    object_type = p_object_type 
  LOOP
    cols := cols || '', '' || attr_rec.attribute_name;
    vals := vals || '', new.'' || attr_rec.attribute_name;
  end LOOP;

  return ''insert into '' || v_table_name || 
    '' ( '' || v_id_column || cols || '' ) values (dt_dummy.val'' ||
    vals || '')'';
  
end;' language 'plpgsql' stable;

-- function trigger_update_statement
create or replace function dynamic_type__trigger_update_statement (varchar)
returns varchar as '
declare
  p_object_type   alias for $1;  
  v_table_name    acs_object_types.table_name%TYPE;
  v_id_column     acs_object_types.id_column%TYPE;
  cols            varchar default '''';
  attr_rec        record;
  v_count         integer;
begin
  if p_object_type is null then 
    return exception ''dynamic_type__trigger_update_statement called with null object_type'';
  end if;

  select 
    table_name, id_column into v_table_name, v_id_column
  from 
    acs_object_types 
  where 
    object_type = p_object_type;

  v_count := 0;
  for attr_rec in select
                    attribute_name
                  from
                    acs_attributes
                  where
                    object_type = p_object_type 
  LOOP
    if v_count > 0 then
        cols := cols || '', '';
    end if;

    cols := cols || attr_rec.attribute_name || '' = new.'' || attr_rec.attribute_name;

    v_count := v_count + 1;
  end LOOP;

  if v_count > 0 then
    return ''update '' || v_table_name || 
      '' set '' || cols || '' where '' ||
      v_id_column || '' = old.'' || v_id_column;
  else
    return '''';
  end if;
  
end;' language 'plpgsql' stable;

-- dummy table provides a target for updates in dynamically generated trigger
-- statements.  If type is acs_object or cr_revisions then rule would end up 
-- having only a select statement which causes an error to be thrown by the 
-- dml command. dml command checks for NS_ROWS result and throws an error if 
-- found.  Using a dummy update causes NS_OK to be returned which satisfies 
-- the dml result checking.

-- DCW, 2001-06-09

create table dt_dummy (
       val integer
);

insert into dt_dummy (val) values (null);

create function dt_dummy_ins_del_tr () returns trigger as '
begin
        raise exception ''Only updates are allowed on dt_dummy'';
        return null;
end;' language 'plpgsql';

create trigger dt_dummy_ins_del_tr before insert or delete on 
dt_dummy for each row execute procedure dt_dummy_ins_del_tr ();


-- FIXME: need to look at this in more detail.  This probably can't be made 
-- to work reliably in postgresql.  Currently we are using a rule to insert 
-- into the input view when a new content revision is added.  Pg locks the 
-- underlying table when the rule is dropped, so the dropping and recreating
-- of the new content revisons seems like it would be reliable, but the 
-- possibility of a race condition exists for either the initial creation
-- or dropping of a type.  I'm not sure if the possibility of a race condition
-- actually exists in practice.  The thing to do here might be to just create 
-- a function that dynamically builds the insert strings and does the 
-- each time an insert is done on the content_type view.  Trade-off being
-- that the inserts would be slower due to the use of dynamic code in pl/psql.
-- More digging required ...

-- DCW, 2001-03-30.

-- Create or replace a trigger on insert for simplifying addition of
-- object instances, with special handling code for content revision subtypes

-- procedure refresh_trigger
create or replace function dynamic_type__refresh_trigger (varchar)
returns integer as '
declare
  p_object_type           alias for $1;  
  insert_rule_text        text default '''';
  update_rule_text        text default '''';
  v_content_revision_p    boolean;       
  v_table_name            acs_object_types.table_name%TYPE;
  type_rec                record;
begin

  -- get the table name for the object type (determines view name)

  select table_name 
    into v_table_name
    from acs_object_types 
   where object_type = p_object_type;

  select content_type__is_content_type(p_object_type)
         into v_content_revision_p;
    
  --
  -- start building rule code
  --
  insert_rule_text := ''create rule '' || v_table_name || 
    ''_ir as on insert to '' || v_table_name || ''i do instead ('';

  update_rule_text := ''create rule '' || v_table_name || 
    ''_ur as on update to '' || v_table_name || ''i do instead ('';

  -- if we are dealing with content revisions then add handler code

  if v_content_revision_p then
      insert_rule_text := insert_rule_text || ''update dt_dummy set val = (
                    select content_revision__new(
                                         new.title,
                                         new.description,
                                         now(),
                                         new.mime_type,
                                         new.nls_language,
                                         null,
                                         content_symlink__resolve(new.item_id),
                                         new.revision_id,
                                         now(),
                                         new.creation_user, 
                                         new.creation_ip
                    ));'';
  else
      insert_rule_text := insert_rule_text || ''update dt_dummy set val = (
                    select acs_object__new(
                                         null,
                                         new.object_type,
                                         now(),
                                         new.creation_user, 
                                         new.creation_ip,
                                         null,
                                         ''''t''''
                    ));'';
  end if;

  -- add an insert statement for each subtype in the hierarchy for this type

  for type_rec in select ot2.object_type, tree_level(ot2.tree_sortkey) as level
                  from acs_object_types ot1, acs_object_types ot2
                  where ot1.object_type = p_object_type
                    and ot1.tree_sortkey between ot2.tree_sortkey and tree_right(ot2.tree_sortkey)
                  order by level desc
  loop
    if not (type_rec.object_type = ''acs_object'') then
      if not (type_rec.object_type = ''content_revision'') then
          insert_rule_text := insert_rule_text || '' '' || dynamic_type__trigger_insert_statement(type_rec.object_type) || '';'';
      end if;

      update_rule_text := update_rule_text || '' '' || dynamic_type__trigger_update_statement(type_rec.object_type) || '';'';
    end if;
  end loop;

  -- end building the rule definition code

  insert_rule_text := insert_rule_text || '' );'';
  update_rule_text := update_rule_text || '' );'';

  --
  -- done building rule code
  --

  -- drop the old rule
  if rule_exists(v_table_name || ''_ir'', v_table_name || ''i'') then 

    -- different syntax for dropping a rule in 7.2 and 7.3 so check which
    -- version is being used (olah).
    if version() like ''%7.2%'' then
      execute ''drop rule '' || v_table_name || ''_ir'';
      execute ''drop rule '' || v_table_name || ''_ur'';
    else
      -- 7.3 syntax
      execute ''drop rule '' || v_table_name || ''_ir on '' || v_table_name || ''i'';
      execute ''drop rule '' || v_table_name || ''_ur on '' || v_table_name || ''i'';
    end if;

  end if;

  -- create the new rule for inserts on the content type
  execute insert_rule_text;
  execute update_rule_text;

  return null; 

end;' language 'plpgsql';


-- procedure refresh_view
create or replace function dynamic_type__refresh_view (varchar)
returns integer as '
declare
  p_object_type           alias for $1;  
  cols                    varchar default ''''; 
  tabs                    varchar default ''''; 
  joins                   varchar default '''';
  v_table_name            varchar;
  v_content_revision_p    boolean;
  join_rec                record;
begin
  select (case when p_object_type = ''content_revision'' then 1 
          else 0 end) into v_content_revision_p
    from dual;

  if not v_content_revision_p then
    select count(*) > 0 into v_content_revision_p
      from acs_object_type_supertype_map
     where object_type = p_object_type
       and ancestor_type = ''content_revision'';
  end if;

 if v_content_revision_p then
   PERFORM content_type__refresh_view(p_object_type);
 else

  for join_rec in select ot2.table_name, ot2.id_column, tree_level(ot2.tree_sortkey) as level
                  from acs_object_types ot1, acs_object_types ot2
                  where ot2.object_type <> ''acs_object''                       
                    and ot2.object_type <> ''content_revision''
                    and ot1.object_type = p_object_type
                    and ot1.tree_sortkey between ot2.tree_sortkey and tree_right(ot2.tree_sortkey)
                  order by ot2.tree_sortkey desc
  loop
    cols := cols || '', '' || join_rec.table_name || ''.*'';
    tabs := tabs || '', '' || join_rec.table_name;
    joins := joins || '' and acs_objects.object_id = '' || 
             join_rec.table_name || ''.'' || join_rec.id_column;
  end loop;

  select table_name into v_table_name from acs_object_types
    where object_type = p_object_type;

  if length(v_table_name) > 25 then
      raise exception ''Table name cannot be longer than 25 characters, because that causes conflicting rules when we create the views.'';
  end if;

  -- create the input view (includes content columns)

  if table_exists(v_table_name || ''i'') then
     execute ''drop view '' || v_table_name || ''i'';
  end if;

  -- FIXME:  need to look at content_revision__get_content.  Since the CR
  -- can store data in a lob, a text field or in an external file, getting
  -- the data attribute for this view will be problematic.

  if not v_content_revision_p then
      execute ''create view '' || v_table_name ||
        ''i as select acs_objects.object_id, acs_objects.object_type,
          acs_objects.context_id, acs_objects.security_inherit_p,
          acs_objects.creation_user, acs_objects.creation_date,
          acs_objects.creation_ip, acs_objects.last_modified,
          acs_objects.modifying_user, acs_objects.modifying_ip,
          acs_objects.tree_sortkey, acs_objects.max_child_sortkey'' || cols || 
        '' from acs_objects'' || tabs || 
        '' where acs_objects.object_id is not null'' || joins;
  else
      -- we don''t include acs_object.title below because it should be the same
      -- as cr_item.title - the relationship will be maintained for inserts and
      -- updates on this view
      execute ''create view '' || v_table_name ||
        ''i as select acs_objects.object_id, acs_objects.object_type,
          acs_objects.context_id, acs_objects.security_inherit_p,
          acs_objects.creation_user, acs_objects.creation_date,
          acs_objects.creation_ip, acs_objects.last_modified,
          acs_objects.modifying_user, acs_objects.modifying_ip,
          acs_objects.tree_sortkey, acs_objects.max_child_sortkey, 
          cr.revision_id, cr.title, cr.item_id,
          cr.description, cr.publish_date, cr.mime_type, cr.nls_language'' || 
          cols || 
        '' from acs_objects, cr_revisions cr'' || tabs || 
        '' where acs_objects.object_id = cr.revision_id '' || joins;
  end if;

  PERFORM dynamic_type__refresh_trigger(p_object_type);

 end if;

  return 0; 
end;' language 'plpgsql';
-- show errors
