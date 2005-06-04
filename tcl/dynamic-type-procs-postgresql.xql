<?xml version="1.0"?>
<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="dtype::create.create_type">      
      <querytext>

          select dynamic_type__create_type (
                :name,
                :supertype,
                :pretty_name,
                :pretty_plural,
                :table_name,
                :id_column,
                :name_method
          );

      </querytext>
</fullquery>

<fullquery name="dtype::delete.drop_type">      
      <querytext>

          select dynamic_type__drop_type (
                :name,
                :drop_children,
                :drop_table
          );

      </querytext>
</fullquery>

<fullquery name="dtype::create_attribute.create_attr">      
      <querytext>

          select dynamic_type__create_attribute (
                :object_type,
                :name,
                :data_type,
                :pretty_name,
                :pretty_plural,
                :sort_order,
                :default_value,
                :column_spec
          );

      </querytext>
</fullquery>

<fullquery name="dtype::get_attributes_list.select_attributes">
      <querytext>
      select a.attribute_name as name, 
             a.pretty_name,
             a.attribute_id,
             a.datatype,
             a.table_name,
             coalesce(a.column_name, a.attribute_name) as column_name,
             a.default_value,
             a.min_n_values,
             a.max_n_values,
             a.storage,
             a.static_p
      from acs_object_type_attributes a,
           (select t.object_type, tree_level(t.tree_sortkey) - tree_level(t2.tree_sortkey) as type_level
            from acs_object_types t, acs_object_types t2
            where t2.object_type = :start_with
            and t.tree_sortkey between t2.tree_sortkey and tree_right(t2.tree_sortkey)) t
      where a.object_type = :name
      and t.object_type = a.ancestor_type $storage_clause
      order by type_level, a.sort_order
      </querytext>
</fullquery>

<fullquery name="dtype::get_attributes_list.select_attributes_dynamic">
      <querytext>
      select a.attribute_name as name, 
             a.pretty_name,
             a.attribute_id,
             a.datatype,
             a.table_name,
             coalesce(a.column_name, a.attribute_name) as column_name,
             a.default_value,
             a.min_n_values,
             a.max_n_values,
             a.storage,
             a.static_p
      from acs_object_type_attributes a, dtype_attributes d,
           (select t.object_type, tree_level(t.tree_sortkey) - tree_level(t2.tree_sortkey) as type_level
            from acs_object_types t, acs_object_types t2
            where t2.object_type = :start_with
            and t.tree_sortkey between t2.tree_sortkey and tree_right(t2.tree_sortkey)) t
      where a.object_type = :name
      and d.attribute_id = a.attribute_id
      and t.object_type = a.ancestor_type $storage_clause
      order by type_level, a.sort_order
      </querytext>
</fullquery>

<fullquery name="dtype::delete_attribute.drop_attr">      
      <querytext>

          select dynamic_type__drop_attribute (
                :object_type,
                :name,
                :drop_column
          );

      </querytext>
</fullquery>

</queryset>
