<?xml version="1.0"?>
<queryset>

<fullquery name="dtype::form::add_elements.check_object_existence"> 
	<querytext>
	    select object_id
	    from acs_objects
	    where object_id = :object_id
	</querytext>
</fullquery>

<fullquery name="dtype::form::process.update_content"> 
	<querytext>
      update cr_revisions set content = (select content from cr_revisions where revision_id = :prev_revision_id) where revision_id = :revision_id
	</querytext>
</fullquery>

<fullquery name="dtype::form::metadata::widgets_list.select_dform_metadata">
	<querytext>
      select attribute_id, object_type, table_name, attribute_name,
             pretty_name, pretty_plural, sort_order, datatype,
             default_value, min_n_values, max_n_values, storage,
             static_p, column_name, form_id, form_name, element_id,
             widget, is_required
        from dtype_form_elements_all
       where object_type = :object_type
         and form_name = :dform
    order by sort_order
	</querytext>
</fullquery>

<fullquery name="dtype::form::metadata::widgets_list.select_dform_metadata_dynamic">
	<querytext>
      select e.attribute_id, object_type, table_name, attribute_name,
             pretty_name, pretty_plural, sort_order, datatype,
             default_value, min_n_values, max_n_values, storage,
             static_p, column_name, form_id, form_name, element_id,
             widget, is_required
        from dtype_form_elements_all e, dtype_attributes a
       where object_type = :object_type
         and form_name = :dform
	 and e.attribute_id = a.attribute_id
    order by sort_order
	</querytext>
</fullquery>

<fullquery name="dtype::form::metadata::params_list.select_dform_metadata"> 
	<querytext>
      select ea.element_id,
             a.attribute_id,
             ea.form_id,
             ea.form_name,
             ea.param_id,
             ea.param_type,
             ea.param_source,
             ea.value,
             ea.param,
             ea.is_required,
             ea.is_html,
             ea.default_value,
             a.attribute_name
        from dtype_element_params_all ea,
             acs_attributes a
       where a.attribute_id = ea.attribute_id
         and a.object_type = :object_type
         and ea.form_name = :dform
    order by a.attribute_id
	</querytext>
</fullquery>

<fullquery name="dtype::form::metadata::widget_templates.select_widget_templates"> 
	<querytext>
      select template_id,
             name,
             pretty_name,
             datatype,
             widget
        from dtype_widget_templates wt
	</querytext>
</fullquery>

<fullquery name="dtype::form::metadata::widget_template.select_widget_template">
	<querytext>
      select template_id,
             name,
             pretty_name,
             datatype,
             widget
        from dtype_widget_templates wt
       where name = :template 
	</querytext>
</fullquery>

<fullquery name="dtype::form::metadata::widget_template_params.select_widget_template_params">
	<querytext>
      select wp.widget,
             wp.param,
             wp.is_required,
             wp.is_html,
             wp.default_value,
             wtp.template_id,
             wtp.param_id,
             wtp.param_type,
             wtp.param_source,
             wtp.value
        from dtype_widget_template_params wtp,
             dtype_widget_templates wt,
             dtype_widget_params wp
       where wtp.template_id = wt.template_id
         and wtp.param_id = wp.param_id
         and wt.name = :template
	</querytext>
</fullquery>

<fullquery name="dtype::form::parameter_value.get_object_type">
	<querytext>
      select object_type
        from acs_attributes a
       where attribute_id = :attribute_id
	</querytext>
</fullquery>

<fullquery name="dtype::form::parameter_value.param_query">
	<querytext>

	$param(value)

	</querytext>
</fullquery>

<fullquery name="dtype::form::get_object_data.get_type_info">
	<querytext>

	select table_name, id_column
    from acs_object_types
   where object_type = :object_type

	</querytext>
</fullquery>

<fullquery name="dtype::form::process.get_type_info">
	<querytext>

	select table_name, id_column
    from acs_object_types
   where object_type = :object_type

	</querytext>
</fullquery>

<fullquery name="dtype::form::process.get_revision_ids">
	<querytext>

	select revision_id
    from cr_revisions,
         acs_objects
   where revision_id = object_id
     and item_id = :item_id
order by creation_date desc

	</querytext>
</fullquery>

<fullquery name="dtype::form::new.insert_form">
  <querytext>

	insert into dtype_forms (form_id, name, object_type)
	values (:form_id, :form_name, :object_type)

  </querytext>
</fullquery>

<fullquery name="dtype::form::edit.update_form">
  <querytext>

	update dtype_forms
	set name = :form_name
	where form_id = :form_id

  </querytext>
</fullquery>

</queryset>
