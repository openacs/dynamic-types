<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN"
"http://www.thecodemill.biz/repository/xql.dtd">
<!--  -->
<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2005-02-12 -->
<!-- @arch-tag: 18e03567-f797-496c-837a-96e851fcf883 -->
<!-- @cvs-id $Id$ -->

<queryset>
  
  <rdbms>
    <type>postgresql</type>
    <version>7.3</version>
  </rdbms>
  
  <partialquery name="dtype::table::get_db_type_map.get_type_map">
    <querytext>int4 integer varchar text boolean boolean numeric
    number real number float number integer integer serial integer
    date date timestamptz date
    "timestamp with time zone" date
    "timestamp without time zone" date
    timestamp date
    "time without time zone" time_of_day
    "time with time zone" time_of_day  time time_of_day "" enumeration
    "" url "" email "" keyword</querytext>
  </partialquery>

  <fullquery name="dtype::table::get_table_array.get_cols">
    <querytext>
      SELECT attname as column_name, typname as data_type
      FROM pg_class c, pg_attribute a, pg_type t
      WHERE c.oid = a.attrelid AND a.atttypid = t.oid AND a.attnum > 0
      AND c.relname=:table
    </querytext>
  </fullquery>

  <fullquery name="dtype::table::id_column.get_id_column">
    <querytext>
      select attname
      from
        pg_attribute,
        pg_constraint,
        pg_class
      where
        contype='p'
      and conrelid=pg_class.oid
      and pg_attribute.attnum = any(pg_constraint.conkey)
      and pg_attribute.attrelid=pg_class.oid
      and upper(pg_class.relname)=upper(:table)
    </querytext>
  </fullquery>

  <fullquery name="dtype::table::supertype.get_supertype">
    <querytext>
  select object_type
  from (select fa.attname,
         fc.relname
      from
        pg_attribute fa,
        pg_attribute pa,
        pg_constraint c,
        pg_class pc,
        pg_class fc
      where
          c.contype='f'
      and c.conrelid=pc.oid
      and pa.attnum = any(c.conkey)
      and fa.attnum = any(c.confkey)
      and pa.attrelid=pc.oid
      and upper(pc.relname)=upper(:table)
      and upper(pa.attname)=upper(:id_column)
      and fa.attrelid=c.confrelid
      and fc.oid=fa.attrelid) as st,
   acs_object_types t
   where t.id_column=st.attname
   and   t.table_name=st.relname
    </querytext>
  </fullquery>

  <fullquery name="dtype::table::get_fk.get_fk">
    <querytext>
      select pa1.attname,
        pa2.attname,
        pc2.relname,
        case when ot.object_type is null then 0 else 1 end
        as object_p
      from pg_attribute pa1,
        pg_attribute pa2,
        pg_constraint,
        pg_class pc1,
        pg_class pc2
        left join
        acs_object_types ot
        on pc2.relname=ot.table_name
      where conrelid=pc1.oid
        and pc1.relname=:table
        and contype='f'
        and confrelid=pc2.oid
        and pa2.attnum = any(pg_constraint.confkey)
        and pa2.attrelid=pc2.oid
        and pc1.oid=pa1.attrelid
        and pa1.attnum=any(pg_constraint.conkey);
      </querytext>
    </fullquery>
</queryset>
