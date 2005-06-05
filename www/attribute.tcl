ad_page_contract {

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-05-02
    @cvs-id $Id$

} {
    {attribute_id:optional}
    {object_type:notnull}
}

set user_id [auth::require_login]
permission::require_permission -object_id [ad_conn package_id] -privilege admin

acs_object_type::get -object_type $object_type -array type_info

if {[info exists attribute_id]} {
    set page_title "[_ dynamic-types.attribute_edit]"
} else {
    set page_title "[_ dynamic-types.attribute_add]"
}

set context [list [list [export_vars -base dtype {object_type}] $type_info(pretty_name)] $page_title]
set table_name $type_info(table_name)
set datatype_options [db_list_of_lists get_datatypes {}]

ad_form -name attribute_form -export {object_type} -form {
    {attribute_id:key}
    {attribute_name:text {label "[_ dynamic-types.attribute_name]"} {html {size 30 maxlength 100}} {help_text "[_ dynamic-types.attribute_name_help]"}}
    {pretty_name:text,optional {label "[_ dynamic-types.pretty_name]"} {html {size 30 maxlength 100}} {help_text "[_ dynamic-types.attribute_pname_help]"}}
    {pretty_plural:text,optional {label "[_ dynamic-types.pretty_plural]"} {html {size 30 maxlength 100}} {help_text "[_ dynamic-types.attribute_pplural_help]"}}
}

if {![ad_form_new_p -key attribute_id]} {
    ad_form -extend -name attribute_form -form {
	{datatype:text(inform) {label "[_ dynamic-types.datatype]"} {options $datatype_options} {help_text "[_ dynamic-types.datatype_help]"}}
    }
} else {
    ad_form -extend -name attribute_form -form {
	{datatype:text(select) {label "[_ dynamic-types.datatype]"} {options $datatype_options} {help_text "[_ dynamic-types.datatype_help]"}}
    }
}

ad_form -extend -name attribute_form -form {
    {default_value:text(textarea),optional {label "[_ dynamic-types.attribute_default]"} {html {rows 3 cols 40}} {help_text "[_ dynamic-types.attribute_default_help]"}}
} -new_request {
    set attribute_name ""
    set pretty_name ""
    set pretty_plural ""
    set datatype string
    set default_value ""
} -edit_request {
    db_1row attribute_data {}
} -on_submit {
    if {[empty_string_p $pretty_name]} {
	foreach word [split $attribute_name] {
	    lappend pretty_name [string totitle $word]
	}
	set pretty_name [join $pretty_name]
    }
    if {[empty_string_p $pretty_name]} {
	set pretty_plural "${pretty_name}s"
    }
    set default_locale [lang::system::site_wide_locale]
} -new_data {
    dtype::create_attribute \
	-name $attribute_name \
	-object_type $object_type \
	-data_type $datatype \
	-pretty_name $pretty_name \
	-pretty_plural $pretty_plural \
	-default_value $default_value
} -edit_data {
    dtype::edit_attribute \
	-name $attribute_name \
	-object_type $object_type \
	-pretty_name $pretty_name \
	-pretty_plural $pretty_plural \
	-default_value $default_value
} -after_submit {
    lang::message::register -update_sync $default_locale acs-translations "${object_type}_$attribute_name" $pretty_name
    lang::message::register -update_sync $default_locale acs-translations "${object_type}_${attribute_name}s" $pretty_plural

    util_memoize_flush "dtype::form::metadata::widgets_list -no_cache -object_type \"$object_type\" -dform \"implicit\" -exclude_static_p 0"
    util_memoize_flush "dtype::form::metadata::widgets_list -no_cache -object_type \"$object_type\" -dform \"implicit\" -exclude_static_p 1"

    ad_returnredirect [export_vars -base dtype {object_type}]
    ad_script_abort
}

ad_return_template
