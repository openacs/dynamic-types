--
-- Metadata for generating data entry forms
--
-- Based on CMS form metadata code.
--

create sequence dtype_widget_param_seq start with 500;

create table dtype_forms (
    form_id       integer
                  constraint dtype_form_id_pk
                  primary key,
    name          varchar2(100),
    object_type   varchar2(1000)
                  constraint dtype_obj_type_ref
                  references acs_object_types,
    constraint dtype_name_obj_type_unq unique(name,object_type)
);

create table dtype_widgets (
  widget           varchar2(100)
                   constraint dtype_widgets_pk
                   primary key
);

comment on table dtype_widgets is '
  Canonical list of all widgets defined in the system
';


create table dtype_default_widgets (
  datatype         varchar2(50)
                   constraint dtype_dft_wgts_dtype_fk
                   references acs_datatypes,
  widget           varchar2(100)
                   constraint dtype_dft_wgts_wgt_fk
                   references dtype_widgets
);

comment on table dtype_default_widgets is '
  Widgets to be used for particular datatypes by default.
';

create table dtype_widget_params (
  param_id         integer
                   constraint dtype_widget_params_pk
                   primary key,
  widget           varchar2(100)
                   constraint cm_widget_params_fk
                   references dtype_widgets,
  param            varchar2(100)
                   constraint cm_widget_param_nil
                   not null,
  is_required      char(1)
                   constraint cm_widget_param_req_chk
                   check (is_required in ('t', 'f')),
  is_html          char(1)
                   constraint cm_widget_param_html_chk
                   check (is_html in ('t', 'f')),
  default_value    varchar2(1000)
);

comment on table dtype_widget_params is '
  Parameters that are specific to a particular type of form widget.
';


create table dtype_default_widget_params (
  datatype         varchar2(50)
                   constraint dtype_dft_wgts_pm_dtype_fk
                   references acs_datatypes,
  widget           varchar2(100)
                   constraint dtype_dft_wgts_pm_wgt_fk
                   references dtype_widgets,
  param_id         integer
                   constraint dtype_dft_wgts_pm_id_fk
                   references dtype_widget_params,
  param_type       varchar2(100) default 'onevalue'
                   constraint dtype_dft_wgts_pm_type_nn
                   not null
                   constraint dtype_dft_wgts_pm_type_ck
                   check (param_type in ('onevalue', 'onelist', 'multilist')),
  param_source     varchar2(100) default 'literal'
                   constraint dtype_dft_wgts_pm_src_nn
                   not null
                   constraint dtype_dft_wgts_pm_src_ck 
                   check (param_source in ('literal', 'query', 'eval')),
  value		         text,
  constraint dtype_dft_wgts_pm_pk
  primary key(datatype, widget, param_id)
);
  
comment on table dtype_default_widget_params is '
  The parameters to apply to the default widget for a given datatype.
';

create table dtype_form_elements (
  element_id       integer
                   constraint dtype_felements_pk
                   primary key,
  attribute_id     integer
                   constraint dtype_felements_attr_fk
                   references acs_attributes,
  form_id          integer
                   constraint dtype_felements_form_id_fk
                   references dtype_forms,
  widget	         varchar2(100)
                   constraint dtype_felements_widget_fk
                   references dtype_widgets
                   constraint dtype_felements_widget_nil
                   not null,
  is_required      char(1) 
                   constraint dtype_felements_opt_ck
                   check(is_required in ('t', 'f'))
);

comment on table dtype_form_elements is '
  A mapping of attribute to widget for a particular object type / form.
';

create table dtype_element_params (
  element_id       integer
                   constraint dtype_elm_param_attr_fk
                   references acs_attributes,
  param_id         integer
                   constraint dtype_elm_param_fk
                   references dtype_widget_params,
  param_type       varchar2(100) default 'onevalue'
                   constraint dtype_elm_param_type_nil
                   not null
                   constraint dtype_elm_param_type_ck
                   check (param_type in ('onevalue', 'onelist', 'multilist')),
  param_source     varchar2(100) default 'literal'
                   constraint dtype_elm_param_src_nil
                   not null,
                   constraint dtype_elm_param_src_ck 
                   check (param_source in ('literal', 'query', 'eval')),
  value		         varchar2(4000),
  constraint dtype_elm_param_pk
  primary key(attribute_id, param_id)
);

comment on table dtype_element_params is '
  Parameter values for specific attribute widgets.
';

create table dtype_element_types (
  name             varchar2(100)
                   constraint dtype_element_type_pk
                   primary key,
  pretty_name      varchar2(1000)
                   constraint dtype_element_type_pname_nn
                   not null,
  datatype         varchar2(50)
                   constraint dtype_element_type_dtype_fk
                   references acs_datatypes,
  widget           varchar2(100)
                   constraint dtype_element_type_wgt_fk
                   references dtype_widgets
);

comment on table dtype_element_types is '
  A list of common datatype / widget combinations and what to call them.
';

-- This view contains the elements of all defined forms plus the elements of a
-- 'default' form for all object_types that have metadata.

create view dtype_form_elements_all as
  select a.attribute_id,
         a.object_type,
         a.table_name,
         a.attribute_name,
         a.pretty_name,
         a.pretty_plural,
         a.sort_order,
         a.datatype,
         a.default_value,
         a.min_n_values,
         a.max_n_values,
         a.storage,
         a.static_p,
         a.column_name,
         f.form_id,
         f.name as form_name,
         e.element_id,
         e.widget,
         e.is_required
    from acs_attributes a,
         dtype_form_elements e,
         dtype_forms f
   where a.attribute_id = e.attribute_id
     and e.form_id = f.form_id
     and a.object_type = f.object_type
  union
  select a.attribute_id,
         a.object_type,
         a.table_name,
         a.attribute_name,
         a.pretty_name,
         a.pretty_plural,
         a.sort_order,
         a.datatype,
         a.default_value,
         a.min_n_values,
         a.max_n_values,
         a.storage,
         a.static_p,
         a.column_name,
         null as form_id,
         'default' as form_name,
         null as element_id,
         dw.widget,
         decode(a.min_n_values, 0, 'f', 't') as is_required
    from acs_attributes a,
         dtypes_default_widgets dw
   where a.datatype = dw.datatype
                      
-- This view contains all defined element parameters, any default parameters 
-- each element has by virtue of its datatype and any default parameters each
-- element has by virtue of its widget type in order of precedence.  It 
-- includes parameters for the 'default' forms defined in the view above.

create view dtype_element_params_all as
  select e.element_id,
         e.attribute_id,
         e.form_id,
         f.form_name,
         ep.param_id,
         ep.param_type,
         ep.param_source,
         ep.value,
         wp.param,
         wp.is_required,
         wp.is_html,
         wp.default_value     
    from dtype_widget_params wp,
         dtype_element_params ep,
         dtype_form_elements e,
         dtype_forms f
   where ep.param_id = wp.param_id
     and ep.element_id = e.element_id
     and e.form_id = f.form_id
   union
  select ea.element_id,
         ea.attribute_id,
         ea.form_id,
         ea.form_name,
         dwp.param_id,
         dwp.param_type,
         dwp.param_source,
         dwp.value,
         wp.param,
         wp.is_required,
         wp.is_html,
         wp.default_value
    from dtype_default_widgets dw,
         dtype_widget_params wp,
         dtype_default_widget_params dwp,
         dtype_form_elements_all a
   where ea.datatype = dw.datatype
     and dw.datatype = dwp.datatype
     and dw.widget = dwp.widget
     and dwp.param_id = wp.param_id
     and not exists (select 1
                       from dtype_element_params ep
                      where ep.element_id = ea.element_id
                        and ep.param_id = wp.param_id)
   union
  select ea.element_id,
         ea.attribute_id,
         ea.form_id,
         ea.form_name,
         wp.param_id,
         'onevalue' as param_type,
         'literal' as param_source,
         default_value as value,
         wp.param,
         wp.is_required,
         wp.is_html,
         wp.default_value
    from dtype_widget_params wp,
         dtype_form_elements_all ea
   where ea.datatype = wp.datatype
     and not exists (select 1
                       from dtype_element_params ep
                      where ep.element_id = ea.element_id
                        and ep.param_id = wp.param_id)
     and not exists (select 1
                       from dtype_default_widget_params dwp
                      where dwp.datatype = ea.datatype
                        and dwp.widget = ea.widget
                        and dwp.param_id = wp.param_id)

create or replace package dtype_widget 
is

procedure set_attribute_order (
  --/** Update the sort_order column of acs_attributes.
  --    @author Karl Goldstein
  --    @param content_type   The name of the content type
  --    @param attribute_name The name of the attribute
  --    @param sort_order     The sort order.
  --*/
  content_type   in acs_attributes.object_type%TYPE,
  attribute_name in acs_attributes.attribute_name%TYPE,
  sort_order     in acs_attributes.sort_order%TYPE
);

procedure register_form_widget (
  --/** Register a form widget to a content type form.  The form widget
  --    uses the default values if none are set. If there is already a widget
  --    registered to the form, the new widget replaces the old widget,
  --    and all parameters are set to their default values.
  --    @author Karl Goldstein, Stanislav Freidin
  --    @param content_type   The name of the content type
  --    @param form_name      The name of the form
  --    @param attribute_name The name of the attribute
  --	  @param widget	        The name of the form widget to use in metadata
  --			                    forms
  --	  @param is_required    Whether this form widget requires a value, 
  --			                    defaults to 'f'
  --	  @param create_form    Whether to create the specified form if it
  --                          doesn't already exist
  --    @see <a href="">/ats/form-procs.tcl/element_create</a>,
  --         {dtype_widget.set_form_param_value},
  --         {dtype_widget.unregister_form_widget}
  --*/
  content_type   in acs_attributes.object_type%TYPE,
  form_name      in dtype_forms.form_name%TYPE,
  attribute_name in acs_attributes.attribute_name%TYPE,
  widget         in dtype_widgets.widget%TYPE,
  is_required    in dtype_form_elements.is_required%TYPE default 'f',
  create_form    in char(1) default 't'
);

procedure unregister_form_widget (
  --/** Unregister a form widget from a content type form. 
  --    The form will no longer show up on the dynamic revision
  --    upload form.<p>If no widget is registered to the form,
  --    the procedure does nothing.
  --    @author Karl Goldstein, Stanislav Freidin 
  --    @param content_type   The name of the content type
  --    @param form_name      The name of the form
  --    @param attribute_name The name of the attribute for which to
  --                          unregister the widget
  --	  @param create_form    Whether to delete the specified form if it
  --                          has no more widgets registered to it
  --    @see {dtype_widget.register_form_widget}
  --*/
  content_type   in acs_attributes.object_type%TYPE,
  form_name      in dtype_forms.form_name%TYPE,
  attribute_name in acs_attributes.attribute_name%TYPE,
  delete_form    in char(1) default 't'
);

procedure set_form_param_value (
  --/** Sets custom values for the param tag of a form widget that is 
  --    registered to a content type form. Unless this procedure is
  --    called, the default form widget param values are used.<p>
  --    If the parameter already has a value associated with it, the old
  --    value is overwritten.
  --    @author Karl Goldstein, Stanislav Freidin
  --    @param content_type   The name of the content type
  --    @param form_name      The name of the form
  --    @param attribute_name The name of the attribute
  --    @param param	        The name of the form widget parameter.
  --			                    Can be an ATS 'element create' flag or an
  --			                    HTML form widget tag
  --    @param param_type     The type of value the param tag expects.
  --			                    Can be 'onevalue','onelist', or 'multilist',
  --			                    defaults to 'onevalue'
  --    @param param_source   How the param value is to be acquired, either
  --			                    'literal', 'eval', or 'query', defaults to
  --			                    'literal'
  --    @param value	        The value(s) or means or obtaining the value(s)
  --			                    for the param tag
  --    @see <a href="">/ats/form-procs.tcl/element_create</a>,
  --         {dtype_widget.register_form_widget}
  --*/
  content_type   in acs_attributes.object_type%TYPE,
  form_name      in dtype_forms.form_name%TYPE,
  attribute_name in acs_attributes.attribute_name%TYPE,
  param          in dtype_widget_params.param%TYPE,
  value          in dtype_element_params.value%TYPE,
  param_type     in dtype_element_params.param_type%TYPE 
                    default 'onevalue',
  param_source   in dtype_element_params.param_source%TYPE
                    default 'literal'
);

end dtype_widget;
/
show errors


create or replace package body dtype_widget 
is

  procedure register_form_widget (
    content_type   in acs_attributes.object_type%TYPE,
    form_name      in dtype_forms.form_name%TYPE,
    attribute_name in acs_attributes.attribute_name%TYPE,
    widget         in dtype_widgets.widget%TYPE,
    is_required    in dtype_form_elements.is_required%TYPE default 'f'
    create_form    in char(1) default 't'
  )
  is
    v_attr_id      acs_attributes.attribute_id%TYPE;
    v_form_id      dtype_forms.form_id%TYPE;
    v_prev_elm     integer;
  begin
  
    -- Look for the attribute
    begin
      select attribute_id into v_attr_id from acs_attributes
        where attribute_name=register_form_widget.attribute_name
        and object_type=register_form_widget.content_type;

      exception when no_data_found then 
        raise_application_error(-20000, 'Attribute ' || content_type ||
          ':' || attribute_name || 
          ' does not exist in dtype_widget.register_form_widget'
        );
    end;

    begin
      select form_id into v_form_id from dtype_forms
        where object_type = register_form_widget.content_type;

      exception when no_data_found then
        v_form_id := null;
    end;

    if v_form_id is null then
      if register_form_widget.create_form = 't' then
        select dtype_seq.nextval into v_form_id from dual;

        insert into dtype_forms (form_id, name, object_type)
        values (v_form_id, p_form_name, p_content_type);
      else
        raise_application_error(-20000, 'Form ' || form_name ||
          ' does not exist for object type ' || content_type || 
          ' in dtype_widget.register_form_widget'
        );
      end if;
    end if;

    -- Determine if a previous value exists
    begin
      select element_id into v_prev_elm
        from dtype_form_elements
       where attriute_id = v_attr_id
         and form_id = v_form_id;

      exception when no_data_found then
        v_prev_elm := null;
    end;

    if v_prev_elm is null then 
      -- No previous widget registered
      -- Insert a new row 
      insert into dtype_form_elements
        (element_id, attribute_id, form_id, widget, is_required)
      select dtype_seq.nextval,
             v_attr_id, 
             v_form_id,
             widget, 
             is_required
        from dual;
    else
      -- Old widget exists: erase parameters, update widget
      delete from dtype_element_params 
      where element_id = v_prev_elm
        and param_id in (select param_id 
                           from dtype_widget_params
                          where widget = register_form_widget.widget);

      update dtype_form_elements 
         set widget = register_form_widget.widget,
             is_required = register_form_widget.is_required
       where attribute_id = v_attr_id
         and form_id = v_form_id;
    end if;

  end register_form_widget;

  procedure set_attribute_order (
    content_type   in acs_attributes.object_type%TYPE,
    attribute_name in acs_attributes.attribute_name%TYPE,
    sort_order     in acs_attributes.sort_order%TYPE
  ) is

  begin

    update 
      acs_attributes    
    set
      sort_order = set_attribute_order.sort_order
    where
      object_type = set_attribute_order.content_type
    and
      attribute_name = set_attribute_order.attribute_name;
        
  end set_form_order;

  procedure unregister_form_widget (
    content_type   in acs_attributes.object_type%TYPE,
    form_name      in dtype_forms.form_name%TYPE,
    attribute_name in acs_attributes.attribute_name%TYPE,
    delete_form    in char(1)
  )
  is
    v_attr_id       acs_attributes.attribute_id%TYPE;
    v_element_id    dtype_form_elements.element_id%TYPE;
    v_element_count integer;
    v_widget        dtype_widgets.widget%TYPE;
  begin
  
    -- Look for the attribute
    begin
      select attribute_id into v_attr_id from acs_attributes
        where attribute_name = unregister_form_widget.attribute_name
        and object_type = unregister_form_widget.content_type;

      exception when no_data_found then
        raise_application_error(-20000, 'Attribute ' || content_type ||
          ':' || attribute_name || 
          ' does not exist in dtype_widget.unregister_form_widget'
        );
    end;   

    -- Look for the widget; if no widget is registered, just return
    begin
      select e.element_id, e.widget into v_element_id, v_widget 
        from dtype_form_elements e,
             dtype_forms f
       where e.attribute_id = v_attr_id
         and e.form_id = f.form_id
         and f.name = unregister_form_widget.form_name;

      exception when no_data_found then
        return;
    end;

  
    -- Delete the param values and the widget assignment
    delete from dtype_element_params where element_id = v_element_id;
    delete from dtype_form_elements where element_id = v_element_id;

    if delete_form = 't' then
      select count(*) into v_element_count
        from dtype_form_elements 
       where form_id = v_form_id;

      if v_element_count = 0 then
          delete from dtype_forms where form_id = v_form_id;
      end if;
    end if;
  end unregister_form_widget;  

  procedure set_form_param_value (
    content_type   in acs_attributes.object_type%TYPE,
    form_name      in dtype_forms.form_name%TYPE,
    attribute_name in acs_attributes.attribute_name%TYPE,
    param          in dtype_widget_params.param%TYPE,
    value          in dtype_element_params.value%TYPE,
    param_type     in dtype_element_params.param_type%TYPE 
                      default 'onevalue',
    param_source   in dtype_element_params.param_source%TYPE
                      default 'literal'
  )
  is
    v_attr_id    acs_attributes.attribute_id%TYPE;
    v_form_id    dtype_forms.form_id%TYPE;
    v_widget     dtype_widgets.widget%TYPE;
    v_param_id   dtype_widget_params.param_id%TYPE;
    v_prev_value integer;
  begin

    -- Get the attribute id and the widget 
    begin
      select e.attribute_id, 
             e.widget, 
             e.form_id 
        into v_attr_id, 
             v_widget, 
             v_form_id 
        from acs_attributes a, 
             dtype_form_elements e,
             dtype_forms f
       where a.attribute_name = p_attribute_name
         and a.object_type = p_content_type
         and a.attribute_id = e.attribute_id
         and e.form_id = f.form_id
         and f.object_type = p_content_type
         and f.form_name = p_form_name;

    exception when no_data_found then
      raise_application_error(-20000, 
        'No widget is registered for attribute ' ||
        content_type || '.' || attribute_name || 
        ' in dtype_widget.set_form_param_value');
    end;

    -- Get the param id
    begin
      select param_id into v_param_id from dtype_widget_params
       where widget = v_widget 
         and param = set_form_param_value.param;

      exception when no_data_found then
        raise_application_error(-20000, 
          'No parameter named ' || param || 
          ' exists for the widget ' || v_widget ||
          ' in dtype_widget.set_form_param_value');
    end;  

    -- Check if an old value exists
    -- Determine if a previous value exists
    select count(1) into v_prev_value from dual 
      where exists (select 1 from dtype_element_params
                    where element_id = v_element_id
                    and param_id = v_param_id);
    
    if v_prev_value > 0 then
      -- Update the value
      update dtype_element_params set
        param_type = set_form_param_value.param_type,
        param_source = set_form_param_value.param_source,
        value = set_form_param_value.value
      where
        element_id = v_element_id
      and
        param_id = v_param_id;
    else
      -- Insert a new value
      insert into dtype_element_params
        (element_id, param_id, param_type, param_source, value)
      values
        (v_element_id, v_param_id, param_type, param_source, value);
    end if;
  end set_form_param_value;

end dtype_widget;
/
show errors
