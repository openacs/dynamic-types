ad_page_contract {

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-03
    @cvs-id $Id$

} {
    {form_id:optional}
    {object_type:notnull}
}

set user_id [auth::require_login]
permission::require_permission -object_id [ad_conn package_id] -privilege admin

acs_object_type::get -object_type $object_type -array type_info

if {[info exists form_id]} {
    set page_title "[_ dynamic-types.edit_form]"
} else {
    set page_title "[_ dynamic-types.add_form]"
}

set context [list [list [export_vars -base dtype {object_type}] $type_info(pretty_name)] $page_title]

ad_form -name form_name -export {object_type} -form {
    {form_id:key(t_dtype_seq)}
    {name:text {label "[_ dynamic-types.form_name]"} {html {size 30 maxlength 100}} {help_text "[_ dynamic-types.form_name_help]"}}
} -new_request {
    set name ""
} -edit_request {
    db_1row form_data {}
} -new_data {
    dtype::form::new -object_type $object_type -form_name $name -form_id $form_id
} -edit_data {
    dtype::form::edit -form_name $name -form_id $form_id -object_type $object_type
} -after_submit {
    ad_returnredirect [export_vars -base form {object_type form_id}]
    ad_script_abort
}

ad_return_template
