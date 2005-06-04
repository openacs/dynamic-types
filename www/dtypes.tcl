ad_page_contract {

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-05-02
    @cvs-id $Id$
} {
    {orderby "pretty_name,asc"}
}

set page_title "[_ dynamic-types.dynamic_types]"
set context [list $page_title]

list::create \
    -name dtypes \
    -multirow dtypes \
    -key object_type \
    -row_pretty_plural "[_ dynamic-types.dynamic_types]" \
    -elements {
        pretty_name {
            label "[_ dynamic-types.pretty_name]"
            link_url_eval $dtype_url
	    orderby "lower(pretty_name)"
        }
        object_type {
            label "[_ dynamic-types.object_type]"
	    orderby "object_type"
        }
    }

set orderby_clause [list::orderby_clause -orderby -name dtypes]

db_multirow -extend { dtype_url } dtypes select_dtypes {} {
    set dtype_url [export_vars -base dtype {object_type}]
}

ad_return_template
