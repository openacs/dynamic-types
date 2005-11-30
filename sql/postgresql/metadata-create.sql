/* widgets.sql - metadata for form widgets */

/* insert form widgets and params */
create or replace function inline_0 ()
returns integer as '
declare
  v_template_id         integer;
begin

  raise notice ''Inserting standard datatype metadata...'';
  insert into dtype_db_datatypes (datatype, db_type)
  values (''boolean'', ''boolean'');
  insert into dtype_db_datatypes (datatype, db_type)
  values (''number'', ''real'');
  insert into dtype_db_datatypes (datatype, db_type)
  values (''integer'', ''integer'');
  insert into dtype_db_datatypes (datatype, db_type)
  values (''money'', ''varchar(30)'');
  insert into dtype_db_datatypes (datatype, db_type)
  values (''date'', ''timestamp'');
  insert into dtype_db_datatypes (datatype, db_type)
  values (''timestamp'', ''timestamp'');
  insert into dtype_db_datatypes (datatype, db_type)
  values (''time_of_day'', ''timestamp'');
  insert into dtype_db_datatypes (datatype, db_type)
  values (''enumeration'', ''text'');
  insert into dtype_db_datatypes (datatype, db_type)
  values (''url'', ''varchar(1000)'');
  insert into dtype_db_datatypes (datatype, db_type)
  values (''email'', ''varchar(100)'');
  insert into dtype_db_datatypes (datatype, db_type)
  values (''text'', ''text'');
  insert into dtype_db_datatypes (datatype, db_type)
  values (''string'', ''varchar(1000)'');

  raise notice ''Inserting standard widget metadata...'';

  insert into dtype_widgets (widget) values (''text'');
  insert into dtype_widgets (widget) values (''textarea'');
  insert into dtype_widgets (widget) values (''radio'');
  insert into dtype_widgets (widget) values (''checkbox'');
  insert into dtype_widgets (widget) values (''select'');
  insert into dtype_widgets (widget) values (''multiselect'');
  insert into dtype_widgets (widget) values (''date'');
  insert into dtype_widgets (widget) values (''search'');
  insert into dtype_widgets (widget) values (''hidden'');


  raise notice ''Inserting standard widget parameters...'';

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (10, ''text'', ''size'', ''f'', ''t'', ''30'');

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (11, ''text'', ''maxlength'', ''f'', ''t'',  null);

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (12, ''text'', ''validate'', ''f'', ''f'',  null);

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (13, ''text'', ''label'', ''f'', ''f'',  null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (20, ''textarea'', ''rows'', ''f'', ''t'', ''6'');

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (21, ''textarea'', ''cols'', ''f'', ''t'', ''60'');

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (22, ''textarea'', ''wrap'', ''f'', ''t'', ''physical'');

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (23, ''textarea'', ''validate'', ''f'', ''f'',  null);

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (24, ''textarea'', ''label'', ''f'', ''f'',  null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (30, ''radio'', ''options'', ''t'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (31, ''radio'', ''values'', ''f'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (32, ''radio'', ''label'', ''f'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (40, ''checkbox'', ''options'', ''t'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (41, ''checkbox'', ''values'', ''f'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (42, ''checkbox'', ''label'', ''f'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (50, ''select'', ''options'', ''t'', ''f'', ''{ -- {} }'');

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (51, ''select'', ''values'', ''f'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (52, ''select'', ''size'', ''f'', ''t'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (53, ''select'', ''label'', ''f'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (60, ''multiselect'', ''options'', ''t'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (61, ''multiselect'', ''values'', ''f'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (62, ''multiselect'', ''size'', ''f'', ''t'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (63, ''multiselect'', ''label'', ''f'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (70, ''date'', ''format'', ''f'', ''f'', ''DD/MONTH/YYYY'');

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (71, ''date'', ''year_interval'', ''f'', ''f'', null);

  insert into dtype_widget_params 
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (72, ''date'', ''label'', ''f'', ''f'', null);

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (80, ''search'', ''search_query'', ''t'', ''f'',  null);

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (81, ''search'', ''result_datatype'', ''f'', ''f'', ''search'');

  insert into dtype_widget_params
    (param_id, widget, param, is_required, is_html, default_value)
  values
    (82, ''search'', ''label'', ''f'', ''f'', null);


  raise notice ''Inserting standard datatype / widget combinations...'';

  -- Text (single line) (default ''text'' widget)
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''short_text'',
      ''Text (single line)'',
      ''text'',
      ''text'',
      null,
      null
  );

  insert into dtype_default_widgets (template_id, datatype)
  values (v_template_id, ''text'');
  
  -- Text (single line) (default ''string'' widget)
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''string'',
      ''String'',
      ''text'',
      ''string'',
      null,
      null
  );

  insert into dtype_default_widgets (template_id, datatype)
  values (v_template_id, ''string'');
  
  -- Email Address
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''email'',
      ''Email Address'',
      ''text'',
      ''email'',
      null,
      null
  );

  insert into dtype_default_widgets (template_id, datatype)
  values (v_template_id, ''email'');
  
  -- URL
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''url'',
      ''URL'',
      ''text'',
      ''url'',
      null,
      null
  );
  
  insert into dtype_default_widgets (template_id, datatype)
  values (v_template_id, ''url'');
  
  -- Integer (default ''integer'' widget)
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''integer'',
      ''Integer'',
      ''text'',
      ''integer'',
      null,
      null
  );
  
  insert into dtype_default_widgets (template_id, datatype)
  values (v_template_id, ''integer'');
  
  -- Natural Number (default ''number'' widget)
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''number'',
      ''Natural Number'',
      ''text'',
      ''number'',
      null,
      null
  );
  
  insert into dtype_default_widgets (template_id, datatype)
  values (v_template_id, ''number'');
  
  -- Text (essay)
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''long_text'',
      ''Text (essay)'',
      ''textarea'',
      ''text'',
      null,
      null
  );
  
  -- Yes / No (default ''boolean'' widget)
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''yes_no'',
      ''Yes / No'',
      ''radio'',
      ''boolean'',
      null,
      null
  );
  
  insert into dtype_widget_template_params
    (template_id, param_id, param_type, param_source, value)
  values
    (v_template_id, 30, ''multilist'', ''literal'', ''{Yes t} {No f}'');

  insert into dtype_default_widgets (template_id, datatype)
  values (v_template_id, ''boolean'');
  
  -- On / Off
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''on_off'',
      ''On / Off'',
      ''radio'',
      ''boolean'',
      null,
      null
  );
  
  insert into dtype_widget_template_params
    (template_id, param_id, param_type, param_source, value)
  values
    (v_template_id, 30, ''multilist'', ''literal'', ''{On t} {Off f}'');

  -- Date (default ''date'' widget)
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''date'',
      ''Date'',
      ''date'',
      ''date'',
      null,
      null
  );

  insert into dtype_default_widgets (template_id, datatype)
  values (v_template_id, ''date'');

  -- Time (default ''time_of_day'' widget)
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''time_of_day'',
      ''Time'',
      ''date'',
      ''time_of_day'',
      null,
      null
  );

  insert into dtype_widget_template_params
    (template_id, param_id, param_type, param_source, value)
  values
    (v_template_id, 70, ''onevalue'', ''literal'', ''HH24:MI'');

  insert into dtype_default_widgets (template_id, datatype)
  values (v_template_id, ''time_of_day'');

  -- Date and Time (default ''timestamp'' widget)
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''timestamp'',
      ''Date and Time'',
      ''date'',
      ''timestamp'',
      null,
      null
  );

  insert into dtype_widget_template_params
    (template_id, param_id, param_type, param_source, value)
  values
    (v_template_id, 70, ''onevalue'', ''literal'', ''DD-MONTH-YYYY HH24:MI'');

  insert into dtype_default_widgets (template_id, datatype)
  values (v_template_id, ''timestamp'');

  -- Enumeration (default ''enumeration'' widget)
  v_template_id := dtype_wdgt_tmpl__new (
      null,
      null,
      ''select_enum'',
      ''Select List'',
      ''select'',
      ''enumeration'',
      null,
      null
  );

  insert into dtype_widget_template_params
    (template_id, param_id, param_type, param_source, value)
  values
    (v_template_id, 50, ''multilist'', ''query'', ''
        select pretty_name,
               enum_value
          from acs_enum_values
         where attribute_id = :attribute_id
       order by sort_order
    '');

  insert into dtype_default_widgets (template_id, datatype)
  values (v_template_id, ''enumeration'');

  -- create ''default'' form for acs_object with only object_id so that
  -- by default the dtype::form api doesn''t try to add acs_object
  -- attributes to forms
  PERFORM dtype_widget__register_form_widget(
      ''acs_object'', 
      ''default'',
      ''object_id'', 
      ''hidden'', 
      ''t'',
      ''t''
  );

  return 0;
end;' language 'plpgsql';

select inline_0 ();

drop function inline_0 ();
