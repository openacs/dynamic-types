ad_library {
    A library of functions to create and manipulate attribute enumerations.

    @author Rob Denison (rob@xarg.net)
    @creation-date 2004/10/12
    @cvs-id $Id$
} 

namespace eval dtype {}
namespace eval dtype::enum {}

ad_proc -public dtype::enum::add_value {
    {-attribute_id:required}
    {-pretty_name:required}
    {-enum_value:required}
} {
    Creates an item in the select list specified by attribute_id.
} {
    db_dml insert_value {}
}

ad_proc -public dtype::enum::edit_value {
    {-attribute_id:required}
    {-old_pretty_name:required}
    {-new_pretty_name:required}
    {-enum_value:required}
} {
    Sets the details of a select item.
} {
    db_dml update_value {}
}

ad_proc -public dtype::enum::get_values {
    {-attribute_id:required}
    multirow
} {
    Gets all the items in a select list.
} {
    db_multirow $multirow select_values {}
}

ad_proc -public dtype::enum::delete_value {
    {-attribute_id:required}
    {-pretty_name:required}
} {
    Deletes an item from a select list
} {
    db_dml delete_value {}
}

ad_proc -public dtype::enum::value_exists_p {
  {-attribute_id:required}
  {-pretty_name:required}
} {
  select the list item matching this attribute_id and pretty_name,
  return 1 if found 0 if not.
} {
  return [db_0or1row select_value_exists {}]
}
