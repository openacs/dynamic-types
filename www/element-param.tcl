ad_page_contract {

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-05
    @cvs-id $Id$

} {
    {form_id:notnull}
    {object_type:notnull}
    {element_id:notnull}
    {param_id:notnull}
}

acs_object_type::get -object_type $object_type -array type_info
db_1row get_data {}

set page_title "[_ dynamic-types.param_one]"
set context [list [list [export_vars -base dtype {object_type}] $type_info(pretty_name)] [list [export_vars -base form {object_type form_id}] "[_ dynamic-types.form_one]"] [list [export_vars -base element-params {object_type form_id element_id}] "[_ dynamic-types.parameters]"] $page_title]

set type_options [list [list "[_ dynamic-types.param_type_onevalue]" onevalue] [list "[_ dynamic-types.param_type_onelist]" onelist] [list "[_ dynamic-types.param_type_multilist]" multilist]]

set source_options [list [list "[_ dynamic-types.param_source_literal]" literal] [list "[_ dynamic-types.param_source_query]" query] [list "[_ dynamic-types.param_source_eval]" eval]]


ad_form -name parameter_form -export {object_type form_id element_id} -form {
    {param_id:key}
    {param_type:text(select) {label "[_ dynamic-types.param_type]"} {options $type_options} {help_text "[_ dynamic-types.param_type_help]"}}
    {param_source:text(select) {label "[_ dynamic-types.param_source]"} {options $source_options} {help_text "[_ dynamic-types.param_source_help]"}}
    {value:text(textarea) {label "[_ dynamic-types.param_value]"} {html {rows 5 cols 80}} {help_text "[_ dynamic-types.param_value_help]"}}
} -edit_request {
    db_1row get_param_data {}
} -edit_data {
    dtype::form::metadata::create_widget_param \
	-object_type $object_type \
	-dform $form_name \
	-attribute_name $attribute_name \
	-param_name $param \
	-type $param_type \
	-source $param_source \
	-value $value
} -after_submit {
    ad_returnredirect [export_vars -base element-params {object_type form_id element_id}]
    ad_script_abort
}

ad_return_template
