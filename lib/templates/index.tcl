# 

ad_page_contract {
    
    List objects
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-17
    @arch-tag: d994f019-d0e5-4ad5-8298-a33dd8d3e075
    @cvs-id $Id$
} {
    
} -properties {
} -validate {
} -errors {
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

set admin_p [permission::permission_p \
                 -object_id $package_id \
                 -party_id $user_id \
                 -privilege "admin"]

set actions [list]
if {$admin_p} {
    set actions [list Add add "Add pretty_name"]
}

db_multirow -extend {url} objects get_objects "select * from table_namei, cr_items ci where table_namei.id_column=ci.latest_revision" {
    set url [export_vars -base one {id_column}]
}

template::list::create \
    -name __object_type \
    -multirow objects \
    -actions $actions \
    -elements {
        title {label "Title" link_url_col url}
    }

set page_title "pretty_plural"
set context [list $page_title]
set focus ""
set header_stuff ""

ad_return_template
