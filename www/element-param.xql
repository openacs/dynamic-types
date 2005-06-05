<?xml version="1.0"?>

<queryset>

<fullquery name="get_data">
  <querytext>

    select p.form_name, a.attribute_name, p.param
    from dtype_element_params_all p, acs_attributes a
    where p.form_id = :form_id
    and p.element_id = :element_id
    and p.param_id = :param_id
    and a.attribute_id = p.attribute_id

  </querytext>
</fullquery>

<fullquery name="get_param_data">
  <querytext>

    select param_type, param_source, value
    from dtype_element_params_all
    where form_id = :form_id
    and element_id = :element_id
    and param_id = :param_id

  </querytext>
</fullquery>

</queryset>
