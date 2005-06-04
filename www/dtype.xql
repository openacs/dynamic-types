<?xml version="1.0"?>

<queryset>

<fullquery name="get_attributes">
  <querytext>

    select attribute_id, attribute_name, pretty_name,
           pretty_plural, datatype
    from acs_attributes
    where object_type = :object_type
    order by sort_order

  </querytext>
</fullquery>

<fullquery name="get_forms">
  <querytext>

    select form_id, name
    from dtype_forms
    where object_type = :object_type
    order by lower(name)

  </querytext>
</fullquery>

</queryset>
