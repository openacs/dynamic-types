/* Register attribute widgets for content_revision and image */

create or replace function inline_1 ()
returns integer as '
begin
  -- register form widgets for content revision attributes

  PERFORM dtype_widget__register_form_widget(
      ''content_revision'', 
      ''default'',
      ''title'', 
      ''text'', 
      ''t'',
      ''t''
  );

  PERFORM dtype_widget__set_param_value(
      ''content_revision'', 
      ''default'',
      ''title'', 
      ''maxlength'', 
      ''1000'',
      ''onevalue'', 
      ''literal''
  );

  PERFORM dtype_widget__register_form_widget(
      ''content_revision'', 
      ''default'',
      ''description'', 
      ''textarea'',
      ''f'',
      ''t''
  );

  PERFORM dtype_widget__set_param_value(
      ''content_revision'', 
      ''default'',
      ''description'', 
      ''cols'', 
      ''40'',
      ''onevalue'', 
      ''literal''
  );

  -- register for widgets for image attributes

  PERFORM dtype_widget__register_form_widget(
      ''image'', 
      ''default'',
      ''width'', 
      ''text'',
      ''f'',
      ''t''
  );

  PERFORM dtype_widget__register_form_widget(
      ''image'', 
      ''default'',
      ''height'', 
      ''text'',
      ''f'',
      ''t''
  ); 
  
  PERFORM dtype_widget__set_param_value(
      ''image'', 
      ''default'',
      ''width'', 
      ''size'', 
      ''5'',
      ''onevalue'',
      ''literal''
  );

  PERFORM dtype_widget__set_param_value(
      ''image'', 
      ''default'',
      ''height'', 
      ''size'', 
      ''5'',
      ''onevalue'', 
      ''literal'' 
  );

  return 0;
end;' language 'plpgsql';

select inline_1 ();

drop function inline_1 ();


-- show errors
