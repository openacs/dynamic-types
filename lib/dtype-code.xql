<?xml version="1.0"?>

<queryset>

<fullquery name="dynamic_attributes">
  <querytext>

    select a.attribute_id, a.attribute_name, a.pretty_name, a.pretty_plural,
           a.datatype, a.default_value
    from acs_attributes a, dtype_attributes d
    where a.attribute_id = d.attribute_id
    and a.object_type = :object_type
    order by a.sort_order

  </querytext>
</fullquery>

</queryset>
