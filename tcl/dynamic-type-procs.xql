<?xml version="1.0"?>
<queryset>

   <fullquery name="dtype::get_object.select_table_name">      
         <querytext>
 
         select table_name
         from acs_object_types
         where object_type = :object_type
 
         </querytext>
   </fullquery>

   <fullquery name="dtype::get_object.select_object">      
         <querytext>
 
         select $columns
         from ${table_name}i
         where object_id = :object_id
 
         </querytext>
   </fullquery>
 
   <fullquery name="dtype::create_attribute.select_column_spec">      
         <querytext>
 
         select db_type as column_spec
         from dtype_db_datatypes
         where datatype = :data_type
 
         </querytext>
   </fullquery>
 
   <fullquery name="dtype::get_attribute.select_attribute">      
         <querytext>
 
         select *
         from acs_attributes
         where acs_attributes.attribute_name = :name
         and acs_attributes.object_type = :object_type
 
         </querytext>
   </fullquery>
 
   <fullquery name="dtype::edit_attribute.update_attribute">      
         <querytext>
 
         update acs_attributes
         set pretty_name = :pretty_name,
	     pretty_plural = :pretty_plural,
	     default_value = :default_value
         where acs_attributes.attribute_name = :name
         and acs_attributes.object_type = :object_type
 
         </querytext>
   </fullquery>

  <fullquery name="dtype::get_table_name.get_table_name">
    <querytext>
      select table_name from acs_object_types where
      object_type=:object_type
    </querytext>
  </fullquery>

  <fullquery name="dtype::get_id_column.get_id_column">
    <querytext>
      select id_column from acs_object_types where
      object_type=:object_type
    </querytext>
  </fullquery>
  
</queryset>
