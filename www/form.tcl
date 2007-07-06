ad_page_contract {

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-04
    @cvs-id $Id$

} {
    {object_type:notnull}
    {form_id:optional 0}
}

set user_id [auth::require_login]
permission::require_permission -object_id [ad_conn package_id] -privilege admin

acs_object_type::get -object_type $object_type -array type_info
db_1row get_form_name {}

set page_title "[_ dynamic-types.form_one]"
set context [list [list [export_vars -base dtype {object_type}] $type_info(pretty_name)] $page_title]
set edit_form_url [export_vars -base form-ae {object_type form_id}]

# Form associated with this object type

list::create \
    -name elements \
    -multirow elements \
    -key element_id \
    -row_pretty_plural "[_ dynamic-types.elements]" \
    -pass_properties {
        object_type form_id
    } -actions [list "[_ dynamic-types.add]" [export_vars -base element {object_type form_id}] "[_ dynamic-types.add_element]"] \
    -bulk_action_export_vars {object_type form_id} \
    -bulk_actions [list "[_ dynamic-types.remove]" element-remove "[_ dynamic-types.remove_element]"] \
    -elements {
        pretty_name {
            label "[_ dynamic-types.pretty_name]"
            link_url_eval $element_url
        }
        attribute_name {
            label "[_ dynamic-types.attribute]"
        }
        datatype {
            label "[_ dynamic-types.datatype]"
        }
        widget {
            label "[_ dynamic-types.widget]"
            link_url_eval $param_url
        }
        is_required {
            label "[_ dynamic-types.required_p]"
        }
    } -filters {
        object_type {}
	form_id {}
    }

db_multirow -extend { element_url param_url } elements get_elements {} {
    set element_url [export_vars -base element {object_type form_id element_id}]
    set param_url [export_vars -base element-params {object_type form_id element_id}]
    set is_required [ad_decode $is_required t "[_ acs-kernel.common_Yes]" "[_ acs-kernel.common_No]"]
}

ad_return_template
