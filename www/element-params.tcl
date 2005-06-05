ad_page_contract {

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-05
    @cvs-id $Id$

} {
    {object_type:notnull}
    {form_id:notnull}
    {element_id:notnull}
}

set user_id [auth::require_login]
permission::require_permission -object_id [ad_conn package_id] -privilege admin

acs_object_type::get -object_type $object_type -array type_info
db_1row get_data {}

set page_title "[_ dynamic-types.parameters]"
set context [list [list [export_vars -base dtype {object_type}] $type_info(pretty_name)] [list [export_vars -base form {object_type form_id}] "[_ dynamic-types.form_one]"] $page_title]

# Parameters of this form element

list::create \
    -name parameters \
    -multirow parameters \
    -key param_id \
    -row_pretty_plural "[_ dynamic-types.params]" \
    -pass_properties {
        object_type form_id element_id
    } -elements {
        param_name {
            label "[_ dynamic-types.param_name]"
            link_url_eval $param_url
        }
        param_type {
            label "[_ dynamic-types.param_type]"
        }
        param_source {
            label "[_ dynamic-types.param_source]"
        }
        param_value {
            label "[_ dynamic-types.param_value]"
        }
    } -filters {
        object_type {}
	form_id {}
	element_id {}
    }

db_multirow -extend { param_url } parameters get_parameters {} {
    set param_url [export_vars -base element-param {object_type form_id element_id param_id}]
}

ad_return_template
