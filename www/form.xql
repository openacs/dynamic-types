<?xml version="1.0"?>

<queryset>

<fullquery name="get_form_name">
  <querytext>

    select name as form_name
    from dtype_forms
    where form_id = :form_id

  </querytext>
</fullquery>

<fullquery name="get_elements">
  <querytext>

    select e.element_id, a.attribute_name, a.pretty_name,
           a.pretty_plural, a.datatype, e.widget, e.is_required
    from acs_attributes a, dtype_form_elements e
    where a.attribute_id = e.attribute_id
    and e.form_id = :form_id
    order by a.sort_order

  </querytext>
</fullquery>

</queryset>
