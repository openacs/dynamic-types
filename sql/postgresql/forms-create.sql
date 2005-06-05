--
-- Metadata for generating data entry forms
--
-- Based on CMS form metadata code.
--
-- The core datamodel allows applications to store metadata to generate html
-- forms for use with dynamic object types.
--
-- Widget templates are provided to allow common widget / datatype combinations
-- to be named and offered in user interfaces that create object types.  
-- Default widgets identify which widget templates to use for default object
-- type forms.

create sequence t_dtype_seq start 500;
create view dtype_seq as select nextval('t_dtype_seq') as nextval;

---------------------------------------------
-- Core reference datamodel
---------------------------------------------

create table dtype_db_datatypes (
  datatype         varchar(50)
                   constraint dtype_wdgt_tmpl_dtype_fk
                   references acs_datatypes,
  db_type          varchar(50)
);

create table dtype_widgets (
  widget           varchar(100)
                   constraint dtype_widgets_pk
                   primary key
);

comment on table dtype_widgets is '
  Canonical list of all widgets defined in the system.
';

create table dtype_widget_params (
  param_id         integer
                   constraint dtype_widget_params_pk
                   primary key,
  widget           varchar(100)
                   constraint dtype_widget_params_fk
                   references dtype_widgets,
  param            varchar(100)
                   constraint dtype_widget_param_nil
                   not null,
  is_required      boolean,
  is_html          boolean,
  default_value    varchar(1000)
);

comment on table dtype_widget_params is '
  Parameters that are specific to a particular type of form widget.
';


---------------------------------------------
-- Widget templates datamodel
---------------------------------------------

create table dtype_widget_templates (
  template_id      integer
                   constraint dtype_wdgt_tmpl_tid_fk
                   references acs_objects(object_id)
                   constraint dtype_wdgt_tmpl_tid_pk
                   primary key,
  name             varchar(100)
                   constraint dtype_wdgt_tmpl_unq
                   unique,
  pretty_name      varchar(1000)
                   constraint dtype_wdgt_tmpl_pname_nn
                   not null,
  datatype         varchar(50)
                   constraint dtype_wdgt_tmpl_dtype_fk
                   references acs_datatypes,
  widget           varchar(100)
                   constraint dtype_wdgt_tmpl_wgt_fk
                   references dtype_widgets
);

comment on table dtype_widget_templates is '
  A list of common datatype / widget combinations and what to call them.
';

select acs_object_type__create_type (
    'dtype_widget_template',        -- object_type
    'Widget Template',              -- pretty_name
    'Widget Templates',             -- pretty_plural
    'acs_object',                   -- supertype
    'dtype_widget_templates',       -- table_name
    'template_id',                  -- id_column
    null,                           -- package_name
    'f',                            -- abstract_p
    null,                           -- type_extension_table
    'widget_template__title'        -- name_method
);

select acs_attribute__create_attribute (
   'dtype_widget_template',         -- object_type
   'name',                          -- attribute_name
   'text',                          -- datatype
   'Short Name',                    -- pretty_name
   'Short Names',                   -- pretty_plural
   null,                            -- table_name
   null,                            -- column_name
   null,                            -- default_value
   1,                               -- min_n_values
   1,                               -- max_n_values
   2,                               -- sort_order
   'type_specific',                 -- storage
   'f'                              -- static_p
);

select acs_attribute__create_attribute (
   'dtype_widget_template',         -- object_type
   'pretty_name',                   -- attribute_name
   'text',                          -- datatype
   'Name',                          -- pretty_name
   'Names',                         -- pretty_plural
   null,                            -- table_name
   null,                            -- column_name
   null,                            -- default_value
   1,                               -- min_n_values
   1,                               -- max_n_values
   1,                               -- sort_order
   'type_specific',                 -- storage
   'f'                              -- static_p
);

select acs_attribute__create_attribute (
   'dtype_widget_template',         -- object_type
   'datatype',                      -- attribute_name
   'text',                          -- datatype
   'Datatype',                      -- pretty_name
   'Datatypes',                     -- pretty_plural
   null,                            -- table_name
   null,                            -- column_name
   'text',                          -- default_value
   1,                               -- min_n_values
   1,                               -- max_n_values
   3,                               -- sort_order
   'type_specific',                 -- storage
   'f'                              -- static_p
);

select acs_attribute__create_attribute (
   'dtype_widget_template',         -- object_type
   'widget',                        -- attribute_name
   'text',                          -- datatype
   'Widget',                        -- pretty_name
   'Widgets',                       -- pretty_plural
   null,                            -- table_name
   null,                            -- column_name
   'text',                          -- default_value
   1,                               -- min_n_values
   1,                               -- max_n_values
   4,                               -- sort_order
   'type_specific',                 -- storage
   'f'                              -- static_p
);

create table dtype_widget_template_params (
  template_id      integer
                   constraint dtype_wgt_tpls_tpl_id_fk
                   references dtype_widget_templates,
  param_id         integer
                   constraint dtype_wgt_tpls_pm_id_fk
                   references dtype_widget_params,
  param_type       varchar(100) default 'onevalue'
                   constraint dtype_wgt_tpls_pm_type_nn
                   not null
                   constraint dtype_wgt_tpls_pm_type_ck
                   check (param_type in ('onevalue', 'onelist', 'multilist')),
  param_source     varchar(100) default 'literal'
                   constraint dtype_wgt_tpls_pm_src_nn
                   not null
                   constraint dtype_wgt_tpls_pm_src_ck 
                   check (param_source in ('literal', 'query', 'eval')),
  value	           text,
  constraint dtype_wgt_tpls_pm_pk
  primary key(template_id, param_id)
);
  
comment on table dtype_widget_template_params is '
  The parameters to apply to the templated widget for a given datatype.
';

create table dtype_default_widgets (
  template_id      integer
                   constraint dtype_wgt_tpls_tpl_id_fk
                   references dtype_widget_templates,
  datatype         varchar(50)
                   constraint dtype_dft_wgts_dtype_fk
                   references acs_datatypes
                   constraint dtype_dft_wgts_dtype_unq
                   unique
);

comment on table dtype_default_widgets is '
  Widgets to be used for particular datatypes by default.
';


---------------------------------------------
-- Form instance datamodel
---------------------------------------------

create table dtype_forms (
    form_id       integer
                  constraint dtype_form_id_pk
                  primary key,
    name          varchar(100),
    object_type   varchar(1000)
                  constraint dtype_obj_type_ref
                  references acs_object_types,
    constraint dtype_name_obj_type_unq unique(name,object_type)
);

comment on table dtype_forms is '
  Canonical list of all forms defined for each object type.
';

create table dtype_form_elements (
  element_id       integer
                   constraint dtype_felements_pk
                   primary key,
  attribute_id     integer
                   constraint dtype_felements_attr_fk
                   references acs_attributes
                   on delete cascade,
  form_id          integer
                   constraint dtype_felements_form_id_fk
                   references dtype_forms,
  widget           varchar(100)
                   constraint dtype_felements_widget_fk
                   references dtype_widgets
                   constraint dtype_felements_widget_nil
                   not null,
  is_required      boolean
);

comment on table dtype_form_elements is '
  A map of attribute to widget for a particular object type / form.
';

create table dtype_element_params (
  element_id       integer
                   constraint dtype_element_param_elm_fk
                   references dtype_form_elements
                   on delete cascade,
  param_id         integer
                   constraint dtype_element_param_fk
                   references dtype_widget_params,
  param_type       varchar(100) default 'onevalue'
                   constraint dtype_element_param_type_nil
                   not null
                   constraint dtype_element_param_type_ck
                   check (param_type in ('onevalue', 'onelist', 'multilist')),
  param_source     varchar(100) default 'literal'
                   constraint dtype_element_param_src_nil
                   not null,
                   constraint dtype_element_param_src_ck 
                   check (param_source in ('literal', 'query', 'eval')),
  value	           text,
  constraint dtype_element_param_pk
  primary key(element_id, param_id)
);

comment on table dtype_element_params is '
  Parameter values for specific object type form widgets.
';

---------------------------------------------
-- Consolidated views
---------------------------------------------

-- This view contains the elements of all defined forms plus the elements of a
-- 'implicit' form for all object_types that have metadata.

create view dtype_form_elements_all as
  select a.attribute_id,
         a.object_type,
         a.table_name,
         a.attribute_name,
         a.pretty_name,
         a.pretty_plural,
         a.sort_order,
         a.datatype,
         a.default_value,
         a.min_n_values,
         a.max_n_values,
         a.storage,
         a.static_p,
         a.column_name,
         f.form_id,
         f.name as form_name,
         e.element_id,
         e.widget,
         e.is_required
    from acs_attributes a,
         dtype_form_elements e,
         dtype_forms f
   where a.attribute_id = e.attribute_id
     and e.form_id = f.form_id
     and a.object_type = f.object_type
  union
  select a.attribute_id,
         a.object_type,
         a.table_name,
         a.attribute_name,
         a.pretty_name,
         a.pretty_plural,
         a.sort_order,
         a.datatype,
         a.default_value,
         a.min_n_values,
         a.max_n_values,
         a.storage,
         a.static_p,
         a.column_name,
         null as form_id,
         'implicit' as form_name,
         null as element_id,
         wt.widget,
         (case when a.min_n_values > 0 then TRUE else FALSE end) as is_required
    from acs_attributes a,
         dtype_widget_templates wt,
         dtype_default_widgets dw
   where a.datatype = dw.datatype
     and dw.template_id = wt.template_id
     and dw.datatype = wt.datatype;
                      
-- This view contains all defined element parameters, any default parameters 
-- each element has by virtue of its datatype and any default parameters each
-- element has by virtue of its widget type in order of precedence.  It 
-- includes parameters for the 'implicit' forms defined in the view above.

create view dtype_element_params_all as
  select e.element_id,
         e.attribute_id,
         e.form_id,
         f.name as form_name,
         ep.param_id,
         ep.param_type,
         ep.param_source,
         ep.value,
         wp.widget,
         wp.param,
         wp.is_required,
         wp.is_html,
         wp.default_value     
    from dtype_widget_params wp,
         dtype_element_params ep,
         dtype_form_elements e,
         dtype_forms f
   where ep.param_id = wp.param_id
     and ep.element_id = e.element_id
     and e.form_id = f.form_id
   union
  select ea.element_id,
         ea.attribute_id,
         ea.form_id,
         ea.form_name,
         wtp.param_id,
         wtp.param_type,
         wtp.param_source,
         wtp.value,
         wp.widget,
         wp.param,
         wp.is_required,
         wp.is_html,
         wp.default_value
    from dtype_default_widgets dw,
         dtype_widget_params wp,
         dtype_widget_templates wt,
         dtype_widget_template_params wtp,
         dtype_form_elements_all ea
   where ea.datatype = dw.datatype
     and dw.template_id = wt.template_id
     and dw.datatype = wt.datatype
     and wt.template_id = wtp.template_id
     and wtp.param_id = wp.param_id
     and not exists (select 1
                       from dtype_element_params ep
                      where ep.element_id = ea.element_id
                        and ep.param_id = wp.param_id)
   union
  select ea.element_id,
         ea.attribute_id,
         ea.form_id,
         ea.form_name,
         wp.param_id,
         'onevalue' as param_type,
         'literal' as param_source,
         wp.default_value as value,
         wp.widget,
         wp.param,
         wp.is_required,
         wp.is_html,
         wp.default_value
    from dtype_widget_params wp,
         dtype_form_elements_all ea
   where ea.widget = wp.widget
     and not exists (select 1
                       from dtype_element_params ep
                      where ep.element_id = ea.element_id
                        and ep.param_id = wp.param_id)
     and not exists (select 1
                       from dtype_widget_template_params wtp,
                            dtype_widget_templates wt,
                            dtype_default_widgets dw
                      where dw.datatype = ea.datatype
                        and dw.template_id = wt.template_id
                        and dw.datatype = wt.datatype
                        and wt.template_id = wtp.template_id
                        and wtp.param_id = wp.param_id);


---------------------------------------------
-- Package definition
---------------------------------------------

create or replace function dtype_widget__register_form_widget (varchar,varchar,varchar,varchar,boolean,boolean)
returns integer as '
declare
  p_object_type         alias for $1;  
  p_form_name           alias for $2;  
  p_attribute_name      alias for $3;  
  p_widget              alias for $4;  
  p_is_required         alias for $5;  -- default ''f''
  p_create_form         alias for $6;
  v_form_id             dtype_forms.form_id%TYPE;
  v_attr_id             acs_attributes.attribute_id%TYPE;
  v_prev_elm            integer;       
begin
  
    -- Look for the attribute
    select attribute_id into v_attr_id 
      from acs_attributes
     where attribute_name = p_attribute_name
       and object_type = p_object_type;

    if NOT FOUND then
        if p_object_type <> ''acs_object'' and p_attribute_name <> ''object_id'' then
            raise EXCEPTION ''-20000: Attribute %: % does not exist in dtype_widget.register_form_widget'', p_object_type, p_attribute_name;
        end if;
    end if;

    -- Look for the form
    select form_id into v_form_id
      from dtype_forms
     where object_type = p_object_type
       and name = p_form_name;

    if NOT FOUND then
        if p_create_form then
            select nextval into v_form_id from dtype_seq;

            insert into dtype_forms (form_id, name, object_type)
            values (v_form_id, p_form_name, p_object_type);
        else
            raise EXCEPTION ''-20000: Form % does not exist for object type % in dtype_widget__register_form_widget'', p_form_name, p_object_type;
        end if;
    end if;

    -- Determine if a previous value exists
    select element_id into v_prev_elm
      from dtype_form_elements
     where attribute_id = v_attr_id
       and form_id = v_form_id;

    if NOT FOUND then 
      -- No previous widget registered
      -- Insert a new row 

      insert into dtype_form_elements (
          element_id,
          attribute_id, 
          form_id,
          widget, 
          is_required
      )
      select nextval,
             v_attr_id, 
             v_form_id,
             p_widget, 
             p_is_required
        from dtype_seq;

    else
      -- Old widget exists: erase parameters, update widget

      delete from dtype_element_params 
      where element_id = v_prev_elm
        and param_id in (select param_id 
                           from dtype_widget_params
                          where widget = p_widget);

      update dtype_form_elements 
         set widget = p_widget,
             is_required = p_is_required
       where attribute_id = v_attr_id
         and form_id = v_form_id;
    end if;

    return 0; 
end;' language 'plpgsql';


-- procedure set_attribute_order
create or replace function dtype_widget__set_attribute_order (varchar,varchar,integer)
returns integer as '
declare
  p_object_type         alias for $1;  
  p_attribute_name      alias for $2;  
  p_sort_order          alias for $3;  
begin

    update acs_attributes    
       set sort_order = p_sort_order
     where object_type = p_object_type
       and attribute_name = p_attribute_name;
        
    return 0; 
end;' language 'plpgsql';


-- procedure unregister_form_widget
create or replace function dtype_widget__unregister_form_widget (varchar,varchar,varchar,boolean)
returns integer as '
declare
  p_object_type         alias for $1;  
  p_form_name           alias for $2;  
  p_attribute_name      alias for $3;  
  p_delete_form         alias for $4;  -- default ''t''
  v_attr_id             acs_attributes.attribute_id%TYPE;
  v_form_id             dtype_forms.form_id%TYPE;
  v_element_id          dtype_form_elements.element_id%TYPE;
  v_element_count       integer;
  v_widget              dtype_widgets.widget%TYPE;
begin
  
    -- Look for the attribute
    
    select attribute_id into v_attr_id from acs_attributes
     where attribute_name = p_attribute_name
       and object_type = p_object_type;

    if NOT FOUND then
        raise EXCEPTION ''-20000: Attribute %: % does not exist in dtype_widget.unregister_form_widget'', p_object_type, p_attribute_name;
    end if;   

    -- Look for the widget; if no widget is registered, just return
    
    select e.element_id, e.widget into v_element_id, v_widget 
      from dtype_form_elements e,
           dtype_forms f
     where e.attribute_id = v_attr_id
       and e.form_id = f.form_id
       and f.name = p_form_name;

    if NOT FOUND then
       return null;
    end if;
  
    -- Delete the param values and the widget assignment
    delete from dtype_element_params where element_id = v_element_id;
    delete from dtype_form_elements where element_id = v_element_id;

    if p_delete_form then
        select count(*) into v_element_count
          from dtype_form_elements 
         where form_id = v_form_id;

        if v_element_count = 0 then
            delete from dtype_forms where form_id = v_form_id;
        end if;
    end if;

    return 0; 
end;' language 'plpgsql';


create or replace function dtype_widget__set_param_value (varchar,varchar,varchar,varchar,varchar,varchar,varchar)
returns integer as '
declare
  p_object_type         alias for $1;  
  p_form_name           alias for $2;  
  p_attribute_name      alias for $3;  
  p_param               alias for $4;  
  p_value               alias for $5;  
  p_param_type          alias for $6;  -- default ''one_value''
  p_param_source        alias for $7;  -- default ''literal''
  v_element_id          dtype_form_elements.element_id%TYPE;
  v_attr_id             acs_attributes.attribute_id%TYPE;
  v_form_id             dtype_forms.form_id%TYPE;
  v_widget              dtype_widgets.widget%TYPE;
  v_param_id            dtype_widget_params.param_id%TYPE;
  v_prev_value          integer;       
begin

    -- Get the attribute id and the widget 
    select e.attribute_id, 
           e.widget, 
           e.form_id,
           e.element_id 
      into v_attr_id, 
           v_widget, 
           v_form_id,
           v_element_id 
      from acs_attributes a, 
           dtype_form_elements e,
           dtype_forms f
     where a.attribute_name = p_attribute_name
       and a.object_type = p_object_type
       and a.attribute_id = e.attribute_id
       and e.form_id = f.form_id
       and f.object_type = p_object_type
       and f.name = p_form_name;

    if NOT FOUND then
      raise EXCEPTION ''-20000: No widget is registered for attribute %.% with a form % in dtype_widget__set_param_value'', p_object_type, p_attribute_name, p_form_name;
    end if;

    -- Get the param id
    select param_id into v_param_id from dtype_widget_params
     where widget = v_widget 
       and param = p_param;

    if NOT FOUND then
      raise EXCEPTION ''-20000: No parameter named % exists for the widget % in dtype_widget__set_param_value'', p_param, v_widget;
    end if;  

    -- Check if an old value exists
    -- Determine if a previous value exists
    select count(1) into v_prev_value from dual 
      where exists (select 1 from dtype_element_params
                    where element_id = v_element_id
                    and param_id = v_param_id);
    
    if v_prev_value > 0 then
      -- Update the value
      update dtype_element_params set
        param_type = p_param_type,
        param_source = p_param_source,
        value = p_value
      where
        element_id = v_element_id
      and
        param_id = v_param_id;
    else
      -- Insert a new value
      insert into dtype_element_params
        (element_id, param_id, param_type, param_source, value)
      values
        (v_element_id, v_param_id, p_param_type, p_param_source, p_value);
    end if;

    return 0; 
end;' language 'plpgsql';


create or replace function dtype_widget__set_param_value (varchar,varchar,varchar,varchar,integer,varchar,varchar)
returns integer as '
begin
    return dtype_widget__set_param_value($1, $2, $3, $4, cast ($5 as varchar), $6, $7); 
end;' language 'plpgsql';


create or replace function dtype_wdgt_tmpl__new (integer,integer,varchar,varchar,varchar,varchar,integer,varchar)
returns integer as '
declare
  p_template_id         alias for $1;  
  p_package_id          alias for $2;
  p_name                alias for $3;  
  p_pretty_name         alias for $4;  
  p_widget              alias for $5;  
  p_datatype            alias for $6;  
  p_creation_user       alias for $7;
  p_creation_ip         alias for $8;
  v_template_id         integer;
begin
  
    v_template_id := acs_object__new (
        p_template_id,
        ''dtype_widget_template'',
        current_timestamp,
        p_creation_user,
        p_creation_ip,
        p_package_id
    );

    insert into dtype_widget_templates (
        template_id,
        name,
        pretty_name,
        datatype,
        widget
    ) values (
        v_template_id,
        p_name,
        p_pretty_name,
        p_datatype,
        p_widget
    );

    return v_template_id; 
end;' language 'plpgsql';

create or replace function dtype_wdgt_tmpl__delete (integer)
returns integer as '
declare
    p_template_id alias for $1;
begin
    -- delete parameters associated with this widget template
    delete from dtype_widget_template_params
    where template_id = p_template_id;

    delete from dtype_widget_templates
    where template_id = p_template_id;
    PERFORM acs_object__delete(p_template_id);
    return 0;
end;
' language 'plpgsql';

create or replace function dtype_wdgt_tmpl__set_param_value (varchar,varchar,varchar,varchar,varchar,varchar,varchar)
returns integer as '
declare
  p_template_name       alias for $1;  
  p_param               alias for $2;  
  p_value               alias for $3;  
  p_param_type          alias for $4;  -- default ''one_value''
  p_param_source        alias for $5;  -- default ''literal''
  v_template_id         dtype_widget_templates.template_id%TYPE;
  v_param_id            dtype_widget_params.param_id%TYPE;
  v_widget              dtype_widgets.widget%TYPE;
  v_prev_value          integer;       
begin

    -- Get the template id and the widget 
    select wt.template_id, 
           wt.widget 
      into v_template_id, 
           v_widget 
      from widget_templates wt
     where wt.name = p_template_name;

    if NOT FOUND then
      raise EXCEPTION ''-20000: No widget template exists with the name % in dtype_wdgt_tmpl__set_param_value'', p_template_name;
    end if;

    -- Get the param id
    select param_id into v_param_id from dtype_widget_params
     where widget = v_widget 
       and param = p_param;

    if NOT FOUND then
      raise EXCEPTION ''-20000: No parameter named % exists for the widget % in dtype_widget__set_param_value'', p_param, v_widget;
    end if;  

    -- Check if an old value exists
    -- Determine if a previous value exists
    select count(1) into v_prev_value from dual 
      where exists (select 1 from dtype_widget_template_params
                    where template_id = v_template_id
                    and param_id = v_param_id);
    
    if v_prev_value > 0 then
      -- Update the value
      update dtype_widget_template_params set
        param_type = p_param_type,
        param_source = p_param_source,
        value = p_value
      where
        template_id = v_template_id
      and
        param_id = v_param_id;
    else
      -- Insert a new value
      insert into dtype_widget_template_params
        (template_id, param_id, param_type, param_source, value)
      values
        (v_template_id, v_param_id, p_param_type, p_param_source, p_value);
    end if;

    return 0; 
end;' language 'plpgsql';
