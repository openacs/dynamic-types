<?xml version="1.0"?>
<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="dtype::create.create_type">      
      <querytext>

        begin
          :1 := dynamic_type.create_type (
                :name,
                :supertype,
                :pretty_name,
                :pretty_plural,
                :table_name,
                :id_column,
                :name_method
          );
        end;

      </querytext>
</fullquery>

<fullquery name="dtype::delete.drop_type">      
      <querytext>

        begin
          :1 := dynamic_type.drop_type (
                :name,
                :drop_children,
                :drop_table
          );
        end

      </querytext>
</fullquery>

<fullquery name="dtype::create_attribute.create_attr">      
      <querytext>

        begin
          :1 := dynamic_type.create_attribute (
                :object_type,
                :name,
                :datatype,
                :pretty_name,
                :pretty_plural,
                :sort_order,
                :default_value,
                :column_spec
          );
        end

      </querytext>
</fullquery>

<fullquery name="dtype::delete_attribute.drop_attr">      
      <querytext>

        begin
          :1 := dynamic_type.drop_attribute (
                :object_type,
                :name,
                :drop_column
          );
        end

      </querytext>
</fullquery>

<fullquery name="dtype::get_attributes_list.select_attributes">
      <querytext>

      select a.attribute_name as name, 
             a.pretty_name,
             a.attribute_id,
             a.datatype,
             a.table_name,
             nvl(a.column_name, a.attribute_name) as column_name,
             a.default_value,
             a.min_n_values,
             a.max_n_values,
             a.storage,
             a.static_p
      from acs_object_type_attributes a,
           (select t.object_type, level as type_level
            from acs_object_types_t
            start with t.object_type = :start_with
            connect by prior t.object_type = t.supertype) t
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
             nvl(a.column_name, a.attribute_name) as column_name,
             a.default_value,
             a.min_n_values,
             a.max_n_values,
             a.storage,
             a.static_p
      from acs_object_type_attributes a, dtype_attributes d,
           (select t.object_type, level as type_level
            from acs_object_types_t
            start with t.object_type = :start_with
            connect by prior t.object_type = t.supertype) t
      where a.object_type = :name
      and d.attribute_id = a.attribute_id
      and t.object_type = a.ancestor_type $storage_clause
      order by type_level, a.sort_order

      </querytext>
</fullquery>

</queryset>
