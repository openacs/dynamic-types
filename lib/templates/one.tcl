ad_page_contract {

} -query {
    id_column:integer,notnull,optional
} -properties {
    page_title
    context
    header_stuff
    focus
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

permission::require_permission \
    -party_id $user_id \
    -object_id $package_id \
    -privilege "read"

dtype::form::add_elements \
    -object_id $id_column \
    -form display \
    -dform standard

template::form::set_properties \
    display \
    -action "edit" \
    -mode display


set page_title "One pretty name"
set context [list $page_title]
set header_stuff ""
set focus ""

ad_return_template