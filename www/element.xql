<?xml version="1.0"?>

<queryset>

<fullquery name="get_form_name">
  <querytext>

    select name as form_name
    from dtype_forms
    where form_id = :form_id

  </querytext>
</fullquery>

<fullquery name="get_attributes">
  <querytext>

    select attribute_name, attribute_id
    from acs_attributes a
    where object_type = :object_type
    and not exists (select 1
		   from dtype_form_elements e
		   where e.form_id = :form_id
		   and e.attribute_id = a.attribute_id)
    order by sort_order

  </querytext>
</fullquery>

<fullquery name="get_widgets">
  <querytext>

    select widget, widget
    from dtype_widgets
    order by lower(widget)

  </querytext>
</fullquery>

<fullquery name="attribute_widget">
  <querytext>

    select a.attribute_name, wt.widget as default_widget
    from acs_attributes a, dtype_default_widgets dw,
         dtype_widget_templates wt
    where a.attribute_id = :attribute_id
    and a.datatype = dw.datatype
    and dw.template_id = wt.template_id
    and dw.datatype = wt.datatype

  </querytext>
</fullquery>

</queryset>
