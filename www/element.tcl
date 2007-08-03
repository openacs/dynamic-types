ad_page_contract {

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-03
    @cvs-id $Id$

} {
    {form_id:notnull}
    {object_type:notnull}
}

set user_id [auth::require_login]
permission::require_permission -object_id [ad_conn package_id] -privilege admin

acs_object_type::get -object_type $object_type -array type_info
db_1row get_form_name {}

set page_title "[_ dynamic-types.add_element]"
set context [list [list [export_vars -base dtype {object_type}] $type_info(pretty_name)] [list [export_vars -base form {object_type form_id}] "[_ dynamic-types.form_one]"] $page_title]

set attribute_options [db_list_of_lists get_attributes {}]
set boolean_options [list [list "[_ acs-kernel.common_Yes]" 1] [list "[_ acs-kernel.common_no]" 0]]
set widget_options [concat [list [list "[_ dynamic-types.widget_default]" ""]] [db_list_of_lists get_widgets {}]]

ad_form -name element_form -export {object_type} -form {
    {form_id:key}
    {attribute_id:text(select) {label "[_ dynamic-types.attribute_name]"} {options $attribute_options} {help_text "[_ dynamic-types.element_name_help]"}}
    {widget:text(select) {label "[_ dynamic-types.widget]"} {options $widget_options} {help_text "[_ dynamic-types.widget_help]"}}
    {required_p:text(select) {label "[_ dynamic-types.required_p]"} {options $boolean_options} {help_text "[_ dynamic-types.required_p_help]"}}
} -edit_request {
    set attribute_id ""
    set required_p t
} -edit_data {
    db_1row attribute_widget {}

    if {[empty_string_p $widget]} {
	set widget $default_widget
    }

    dtype::form::metadata::create_widget \
	-object_type $object_type \
	-dform $form_name \
	-attribute_name $attribute_name \
	-widget $widget \
	-required_p $required_p
} -after_submit {
    ad_returnredirect [export_vars -base form {object_type form_id}]
    ad_script_abort
}

ad_return_template
