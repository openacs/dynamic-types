/* cms-widgets.sql - metadata for form widgets */



/* insert form widgets and params */
begin

  dbms_output.put_line('Inserting standard widget metadata...');

  insert into dtype_widgets (widget) values ('text');
  insert into dtype_widgets (widget) values ('textarea');
  insert into dtype_widgets (widget) values ('radio');
  insert into dtype_widgets (widget) values ('checkbox');
  insert into dtype_widgets (widget) values ('select');
  insert into dtype_widgets (widget) values ('multiselect');
  insert into dtype_widgets (widget) values ('date');
  insert into dtype_widgets (widget) values ('search');
  insert into dtype_widgets (widget) values ('hidden');


  dbms_output.put_line('Inserting standard widget parameters...');

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (10, 'text', 'size', 'f', 't', '30');

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (11, 'text', 'maxlength', 'f', 't',  null);

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (12, 'text', 'validate', 'f', 'f',  null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (20, 'textarea', 'rows', 'f', 't', '6');

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (21, 'textarea', 'cols', 'f', 't', '60');

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (22, 'textarea', 'wrap', 'f', 't', 'physical');

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (23, 'textarea', 'validate', 'f', 'f',  null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (30, 'radio', 'options', 't', 'f', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (31, 'radio', 'values', 'f', 'f', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (40, 'checkbox', 'options', 't', 'f', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (41, 'checkbox', 'values', 'f', 'f', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (50, 'select', 'options', 't', 'f', '{ -- {} }');

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (51, 'select', 'values', 'f', 'f', '{}');

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (52, 'select', 'size', 'f', 't', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (60, 'multiselect', 'options', 't', 'f', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (61, 'multiselect', 'size', 'f', 't', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (62, 'multiselect', 'values', 'f', 'f', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (70, 'date', 'format', 'f', 'f', 'DD/MONTH/YYYY');

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (71, 'date', 'year_interval', 'f', 'f', '2000 2010 1');

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (80, 'search', 'search_query', 't', 'f',  null);

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (81, 'search', 'result_datatype', 'f', 'f', 'search');


  dbms_output.put_line('Inserting default datatype / widget combinations...');

  insert into dtype_default_widgets (datatype, widget)
  values ('string', 'text');

  insert into dtype_default_widgets (datatype, widget)
  values ('boolean', 'radio');

  insert into dtype_default_widgets (datatype, widget)
  values ('number', 'text');

  insert into dtype_default_widgets (datatype, widget)
  values ('integer', 'text');

  insert into dtype_default_widgets (datatype, widget)
  values ('money', 'text');

  insert into dtype_default_widgets (datatype, widget)
  values ('date', 'date');

  insert into dtype_default_widgets (datatype, widget)
  values ('timestamp', 'date');

  insert into dtype_default_widgets (datatype, widget)
  values ('time_of_day', 'date');

  insert into dtype_default_widgets (datatype, widget)
  values ('enumeration', 'select');

  insert into dtype_default_widgets (datatype, widget)
  values ('url', 'text');

  insert into dtype_default_widgets (datatype, widget)
  values ('email', 'text');

  insert into dtype_default_widgets (datatype, widget)
  values ('text', 'text');

  insert into dtype_default_widgets (datatype, widget)
  values ('keyword', 'select');


  dbms_output.put_line('Inserting parameters for standard datatype / widget combinations...');

  insert into dtype_default_widget_params
    (datatype, widget, param_id, param_type, param_source, value)
  values
    ('boolean', 'radio', 30, 'multilist', 'literal', '{ {Yes t} {No f} }');

  insert into dtype_default_widget_params
    (datatype, widget, param_id, param_type, param_source, value)
  values
    ('boolean', 'select', 50, 'multilist', 'literal', '{ {Yes t} {No f} }');

  insert into dtype_default_widget_params
    (datatype, widget, param_id, param_type, param_source, value)
  values
    ('timestamp', 'date', 70, 'onevalue', 'literal', 'YYYY/MONTH/DD HH24:MI');

  insert into dtype_default_widget_params
    (datatype, widget, param_id, param_type, param_source, value)
  values
    ('time_of_day', 'date', 70, 'onevalue', 'literal', 'HH24:MI');

  insert into dtype_default_widget_params
    (datatype, widget, param_id, param_type, param_source, value)
  values
    ('enumeration', 'select', 50, 'multilist', 'query', '
        select pretty_name,
               enum_value
          from acs_enum_values
         where attribute_id = :attribute_id
       sort by sort_order
    ');

  -- add default validation parameters for the various text types here

  insert into dtype_default_widget_params
    (datatype, widget, param_id, param_type, param_source, value)
  values
    ('email', 'text', 50, 'onelist', 'literal', 'valid_email { util_email_valid_p $value } {This does not appear to be a valid email.}');

end;
/
show errors


/* Register attribute widgets for content_revision and image */

begin
  -- register form widgetes for content revision attributes

  dtype_widget.register_form_widget(
      content_type      => 'content_revision', 
      form_name         => 'admin',
      attribute_name    => 'title', 
      widget	          => 'text', 
      is_required       => 't'
  );

  dtype_widget.register_form_widget(
      content_type      => 'content_revision', 
      form_name         => 'admin',
      attribute_name    => 'description', 
      widget	          => 'textarea'
  );

  dtype_widget.set_form_param_value(
      content_type      => 'content_revision', 
      form_name         => 'admin',
      attribute_name    => 'description', 
      param	            => 'cols', 
      param_type        => 'onevalue', 
      param_source      => 'literal', 
      value	            => 40
  );

  dtype_widget.register_form_widget(
      content_type      => 'content_revision', 
      form_name         => 'admin',
      attribute_name    => 'mime_type', 
      widget	          => 'select',
      is_required       => 't'
  );
  
  dtype_widget.set_form_param_value(
      content_type      => 'content_revision', 
      form_name         => 'admin',
      attribute_name    => 'mime_type', 
      param	            => 'options', 
      param_type        => 'multilist', 
      param_source      => 'query',
      value	            => 'select label, map.mime_type as value 
                              from cr_mime_types types, 
			                             cr_content_mime_type_map map 
			                       where types.mime_type = map.mime_type 
			                         and content_type = :content_type 
			                    order by label'
  );

  dtype_widget.set_form_param_value(
      content_type      => 'content_revision', 
      form_name         => 'admin',
      attribute_name    => 'mime_type', 
      param	            => 'values', 
      param_type        => 'onevalue', 
      param_source      => 'query',
      value	            => 'select mime_type
			                        from cr_revisions
			                       where revision_id = content_item.get_latest_revision(:item_id)'
  );

  dtype_widget.set_form_param_value(
      content_type      => 'content_revision', 
      form_name         => 'admin',
      attribute_name    => 'title', 
      param	            => 'maxlength', 
      param_type        => 'onevalue', 
      param_source      => 'literal', 
      value	            => 1000
  );

  dtype_widget.set_form_param_value (
      content_type      => 'content_revision',
      form_name         => 'admin',
      attribute_name    => 'description',
      param	            => 'validate',
      param_type        => 'onevalue',
      param_source      => 'literal',
      value             => 'description_4k_max { cm_widget::validate_description $value } {  Description length cannot exceed 4000 bytes. }'
  );

  -- register for widgets for image attributes

  dtype_widget.register_form_widget(
      content_type      => 'image', 
      form_name         => 'admin',
      attribute_name    => 'width', 
      widget	          => 'text'
  );

  dtype_widget.register_form_widget(
      content_type      => 'image', 
      form_name         => 'admin',
      attribute_name    => 'height', 
      widget	          => 'text'
  ); 
  
  dtype_widget.set_form_param_value(
      content_type      => 'image', 
      form_name         => 'admin',
      attribute_name    => 'width', 
      param	            => 'size', 
      param_type        => 'onevalue',
      param_source      => 'literal', 
      value	            => 5
  );

  dtype_widget.set_form_param_value(
      content_type      => 'image', 
      form_name         => 'admin',
      attribute_name    => 'height', 
      param	            => 'size', 
      param_type        => 'onevalue', 
      param_source      => 'literal', 
      value	            => 5
  );
end;
/
show errors
