<?xml version="1.0"?>

<queryset>

<fullquery name="get_form_name">
  <querytext>

    select name as form_name
    from dtype_forms
    where form_id = :form_id

  </querytext>
</fullquery>

<fullquery name="attribute_name">
  <querytext>

    select a.attribute_name
    from acs_attributes a, dtype_form_elements e
    where a.attribute_id = e.attribute_id
    and e.element_id = :e_id

  </querytext>
</fullquery>

</queryset>
