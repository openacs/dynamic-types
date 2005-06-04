ad_page_contract {

    @author Timo Hentschel (timo@timohentschel.de)
    @creation-date 2005-06-03
    @cvs-id $Id$

} {
    {form_id:notnull}
    {object_type:notnull}
    {element_id:multiple}
}

db_1row get_form_name {}

db_transaction {
    foreach e_id $element_id {
	db_1row attribute_name {}

	dtype::form::metadata::delete_widget \
	    -object_type $object_type \
	    -dform $form_name \
	    -attribute_name $attribute_name \
	    -delete_form_p 0
    }
}

ad_returnredirect [export_vars -base form {object_type form_id}]
