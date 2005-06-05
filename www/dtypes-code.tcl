ad_page_contract {

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-04
    @cvs-id $Id$

} {
    {object_type:multiple}
}

set user_id [auth::require_login]
permission::require_permission -object_id [ad_conn package_id] -privilege admin

set page_title "[_ dynamic-types.code_export]"
set context [list $page_title]

multirow create types object_type
foreach type $object_type {
    multirow append types $type
}

ad_return_template
