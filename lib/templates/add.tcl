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
    -privilege "create"

if {[info exists id_column] && $id_column ne ""} {
    dtype::form::add_elements \
        -dform __dform \
        -object_id $id_column \
        -form add
} else {
    dtype::form::add_elements \
        -form add \
        -dform __dform \
        -object_type __object_type
}
if {[template::form::is_submission add]} {
    dtype::form::process \
        -form add \
        -dform __dform \
        -object_type __object_type
}

set page_title "Add pretty_name"
set context [list $page_title]
set header_stuff ""
set focus ""

ad_return_template

