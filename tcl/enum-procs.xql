<?xml version="1.0"?>
<queryset>

   <fullquery name="dtype::enum::add_value.insert_value">      
      <querytext>
          insert into acs_enum_values
          select :attribute_id,:pretty_name,:enum_value,coalesce(max(sort_order),0)+1 from acs_enum_values where attribute_id=:attribute_id
      </querytext>
   </fullquery>

   <fullquery name="dtype::enum::edit_value.update_value">      
      <querytext>
          update acs_enum_values
          set pretty_name=:new_pretty_name,enum_value=:enum_value
          where attribute_id=:attribute_id
          and pretty_name=:old_pretty_name
      </querytext>
   </fullquery>

   <fullquery name="dtype::enum::delete_value.delete_value">      
      <querytext>
          delete from acs_enum_values
          where attribute_id=:attribute_id
          and pretty_name=:pretty_name
      </querytext>
   </fullquery>

   <fullquery name="dtype::enum::value_exists_p.select_value_exists">
      <querytext>
         select 1
         from acs_enum_values
         where attribute_id = :attribute_id
         and pretty_name = :pretty_name
      </querytext>
   </fullquery>

   <fullquery name="dtype::enum::get_values.select_values">      
         <querytext>
           select *
           from acs_enum_values
           where attribute_id = :attribute_id
           order by sort_order
         </querytext>
   </fullquery>
 
</queryset>
