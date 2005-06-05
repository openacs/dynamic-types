<?xml version="1.0"?>
<queryset>
	<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="dynamic_forms">
  <querytext>

    select f.form_id, f.name as form_name, a.attribute_name, e.element_id,
           e.widget, e.is_required, wp.param, ep.param_type,
	   ep.param_source, ep.value as param_value
    from dtype_forms f, acs_attributes a, dtype_form_elements e,
         dtype_element_params ep, dtype_widget_params wp
    where f.object_type = :object_type
    and e.form_id = f.form_id
    and a.attribute_id = e.attribute_id
    and e.element_id = ep.element_id (+)
    and ep.param_id = wp.param_id (+)

  </querytext>
</fullquery>

</queryset>
