/* Register attribute widgets for content_revision and image */

create or replace function inline_1 ()
returns integer as '
begin
  -- register form widgets for content revision attributes

  PERFORM dtype_widget__register_form_widget(
      ''content_revision'', 
      ''standard'',
      ''title'', 
      ''text'', 
      ''t'',
      ''t''
  );

  PERFORM dtype_widget__set_param_value(
      ''content_revision'', 
      ''standard'',
      ''title'', 
      ''maxlength'', 
      ''1000'',
      ''onevalue'', 
      ''literal''
  );

  PERFORM dtype_widget__register_form_widget(
      ''content_revision'', 
      ''standard'',
      ''description'', 
      ''textarea'',
      ''f'',
      ''t''
  );

  PERFORM dtype_widget__set_param_value(
      ''content_revision'', 
      ''standard'',
      ''description'', 
      ''cols'', 
      ''40'',
      ''onevalue'', 
      ''literal''
  );

  -- register for widgets for image attributes

  PERFORM dtype_widget__register_form_widget(
      ''image'', 
      ''standard'',
      ''width'', 
      ''text'',
      ''f'',
      ''t''
  );

  PERFORM dtype_widget__register_form_widget(
      ''image'', 
      ''standard'',
      ''height'', 
      ''text'',
      ''f'',
      ''t''
  ); 
  
  PERFORM dtype_widget__set_param_value(
      ''image'', 
      ''standard'',
      ''width'', 
      ''size'', 
      ''5'',
      ''onevalue'',
      ''literal''
  );

  PERFORM dtype_widget__set_param_value(
      ''image'', 
      ''standard'',
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
