ad_page_contract {

} -query {
    object_id:integer,notnull
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
    -object_id $object_id \
    -privilege "write"

if {[info exists object_id] && $object_id ne ""} {
    dtype::form::add_elements \
        -object_id $object_id \
        -form edit \
        -dform __dform
} else {
    dtype::form::add_elements \
        -form edit \
        -object_type __object_type \
        -dform __dform
}
if {[template::form::is_submission edit]} {
    dtype::form::process \
        -form edit \
        -object_type __object_type \
        -dform __dform
}

set page_title "Edit pretty_name"
set context [list $page_title]
set header_stuff ""
set focus ""

ad_return_template

