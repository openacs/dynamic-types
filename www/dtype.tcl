ad_page_contract {

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-05-02
    @cvs-id $Id$

} {
    {object_type:notnull}
}

acs_object_type::get -object_type $object_type -array type_info

set page_title $type_info(pretty_name)
set context [list $page_title]

list::create \
    -name attributes \
    -multirow attributes \
    -key attribute_name \
    -row_pretty_plural "[_ dynamic-types.attributes]" \
    -pass_properties {
        object_type
    } -actions [list "[_ dynamic-types.add]" [export_vars -base attribute {object_type}] "[_ dynamic-types.add_attribute]"] \
    -bulk_actions {
    } -elements {
        pretty_name {
            label "[_ dynamic-types.pretty_name]"
            link_url_eval $attribute_url
        }
        attribute_name {
            label "[_ dynamic-types.attribute]"
        }
        datatype {
            label "[_ dynamic-types.datatype]"
        }
    } -filters {
        object_type {}
    }

db_multirow -extend { attribute_url } attributes get_attributes {} {
    set attribute_url [export_vars -base attribute {object_type attribute_id}]
}

# Forms associated with this object type

list::create \
    -name forms \
    -multirow forms \
    -key form_id \
    -row_pretty_plural "[_ dynamic-types.forms]" \
    -pass_properties {
        object_type
    } -actions [list "[_ dynamic-types.add]" [export_vars -base form-ae {object_type}] "[_ dynamic-types.add_form]"] \
    -bulk_actions {
    } -elements {
	name {
	    label "[_ dynamic-types.form_name]"
	    link_url_eval $form_url
	}
    } -filters {
        object_type {}
    }

db_multirow -extend { form_url } forms get_forms {} {
    set form_url [export_vars -base form {object_type form_id}]
}

ad_return_template
