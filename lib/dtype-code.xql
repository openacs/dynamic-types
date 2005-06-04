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

<fullquery name="dynamic_forms">
  <querytext>

    select f.form_id, f.name as form_name, a.attribute_name,
           e.widget, e.is_required
    from dtype_forms f, dtype_form_elements e, acs_attributes a
    where f.object_type = :object_type
    and e.form_id = f.form_id
    and a.attribute_id = e.attribute_id

  </querytext>
</fullquery>

</queryset>
