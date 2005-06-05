<?xml version="1.0"?>

<queryset>

<fullquery name="get_data">
  <querytext>

    select form_name, attribute_name
    from dtype_form_elements_all
    where form_id = :form_id
    and element_id = :element_id

  </querytext>
</fullquery>

<fullquery name="get_parameters">
  <querytext>

    select param_id, param as param_name, param_type, param_source,
           value as param_value
    from dtype_element_params_all
    where form_id = :form_id
    and element_id = :element_id
    order by lower(param)

  </querytext>
</fullquery>

</queryset>
