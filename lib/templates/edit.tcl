ad_page_contract {

} -query {
    id_column:integer,notnull
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
    -object_id $id_column \
    -privilege "write"

if {[info exists id_column] && $id_column ne ""} {
    dtype::form::add_elements \
        -object_id $id_column \
        -form edit
} else {
    dtype::form::add_elements \
        -form edit \
        -object_type __object_type
}
if {[template::form::is_submission edit]} {
    dtype::form::process \
        -form edit \
        -object_type __object_type
}

set page_title "Edit pretty_name"
set context [list $page_title]
set header_stuff ""
set focus ""

ad_return_template

