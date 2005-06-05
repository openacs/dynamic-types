<?xml version="1.0"?>
<queryset>
	<rdbms><type>postgresql</type><version>7.3</version></rdbms>

<fullquery name="dynamic_forms">
  <querytext>

    select f.form_id, f.name as form_name, a.attribute_name, e.element_id,
           e.widget, e.is_required, wp.param, ep.param_type,
	   ep.param_source, ep.value as param_value
    from dtype_forms f, acs_attributes a, dtype_form_elements e
         left outer join dtype_element_params ep using (element_id)
         left outer join dtype_widget_params wp using (param_id)
    where f.object_type = :object_type
    and e.form_id = f.form_id
    and a.attribute_id = e.attribute_id

  </querytext>
</fullquery>

</queryset>
