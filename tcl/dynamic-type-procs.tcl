ad_library {
    A library of functions to create and manipulate dynamic object types.

    Creating a type through this api ensures that the necessary datamodel is in
    place for the type and that a subtype of acs_object and corresponding 
    acs_attribute metadata has been recorded.  

    Currently (2004/10/12) only 'type_specific' attribute storage is supported,
    although the API could be extended to support 'generic' skinny table 
    storage.

    Special code handles subtypes of 'content_revision' so that dynamic content
    types may be created for storage in the content repository.

    @author Rob Denison (rob@xarg.net)
    @creation-date 2004/10/12
    @cvs-id $Id$
} 

namespace eval dtype {}

ad_proc -public dtype::get_object {
    {-object_id:required}
    {-object_type:required}
    {-array:required}
} {
    Populates array with the data for the object specified.
} {
    set attributes_list [dtype::get_attributes_list -name $object_type -start_with acs_object -storage_types type_specific]

    upvar $array local
    set columns [list]

    foreach attribute_info $attributes_list {
        foreach {name pretty_name attribute_id datatype table_name column_name default_value min_n_values max_n_values static_p} $attribute_info break
	if {$column_name == "package_id"} {
	    continue
	}
        switch $datatype {
              date -
              timestamp -
              time_of_day {
                  set format "'YYYY-MM-DD HH24:MI:SS'"
                  lappend columns "to_char($column_name, $format) as $name"
              }
              default {
                  lappend columns "$column_name as $name"
              }
        }
    }
    db_1row select_table_name {}
    set columns [join $columns ", "]
    db_0or1row select_object {} -column_array local
}

ad_proc -public dtype::create {
    {-name:required}
    {-supertype "acs_object"}
    {-pretty_name:required}
    {-pretty_plural:required}
    {-table_name:required}
    {-id_column "XXX"}
    {-name_method ""}
} {
    Creates a content type with consolidated view (see plpgsql function 
    dynamic_type__create_type).
} {
    if {[string equal $name_method ""]} {
        set name_method [db_null]
    }

    ns_log Debug "DYNAMIC TYPES: Creating Object $name with Pretty Name $pretty_name"
    db_exec_plsql create_type {}
}

ad_proc -public dtype::delete {
    {-name:required}
    {-drop_children:boolean}
    {-drop_table:boolean}
} {
    Delete a dynamically created content type.
} {
    set drop_children [db_boolean $drop_children_p]
    set drop_table [db_boolean $drop_table_p]

    db_exec_plsql drop_type {}

    set event(object_type) $name
    set event(action) deleted
    util::event::fire -event dtype event
}

ad_proc -public dtype::create_attribute {
    {-name:required}
    {-object_type:required}
    {-data_type:required}
    {-pretty_name:required}
    {-pretty_plural ""}
    {-sort_order ""}
    {-default_value ""}
} {
    Creates an attribute on a content type.
} {
    if {[string equal $pretty_plural ""]} {
        set pretty_plural [db_null]
    }

    if {[string equal $sort_order ""]} {
        set sort_order [db_null]
    }

    if {[string equal $default_value ""]} {
        set default_value [db_null]
    }
    
    if {![db_0or1row select_column_spec {}]} {
        set column_spec ""
    }

    db_exec_plsql create_attr {}
    
    set event(object_type) $object_type
    set event(attribute) $name
    set event(action) created
    util::event::fire -event dtype.attribute event
}

ad_proc -public dtype::get_attributes {
    {-name:required}
    {-start_with "acs_object"}
    {-storage_types "type_specific"}
    {-list "f"}
    multirow
} {
    Gets all the attributes of a object_type.  Optionally
    it can return only those attributes after a given name.
} {

    set attributes [dtype::get_attributes_list \
        -name $name \
        -start_with $start_with \
        -storage_types $storage_types]

    if {!$list} {
    
        template::multirow create $multirow \
            name \
            pretty_name \
            attribute_id \
            datatype \
            table_name \
            column_name \
            default_value \
            min_n_values \
            max_n_values \
            storage \
            static_p
        
        foreach attribute $attributes {
            template::multirow append $multirow \
                [lindex $attribute 0] \
                [lindex $attribute 1] \
                [lindex $attribute 2] \
                [lindex $attribute 3] \
                [lindex $attribute 4] \
                [lindex $attribute 5] \
                [lindex $attribute 6] \
                [lindex $attribute 7] \
                [lindex $attribute 8] \
                [lindex $attribute 9] \
                [lindex $attribute 10]
        }
    } else {
        return $attributes
    } 
}

ad_proc -private dtype::get_attributes_list {
    {-no_cache:boolean}
    {-name:required}
    {-start_with:required}
    {-storage_types:required}
} {
    Gets all the attributes of a object_type.  
} {
    if {$no_cache_p} {
        set storage_clause "and a.storage in ('[join $storage_types "', '"]')"

        return [db_list_of_lists select_attributes {}]
    } else {
        return [util_memoize "dtype::get_attributes_list -no_cache -name \"$name\" -start_with \"$start_with\" -storage_types \"$storage_types\""]
    }
}

ad_proc -private dtype::flush_cache {
   {-type:required}
   {-event:required}
} {
    Flushes the util_memoize cache of dtype calls for a given object type.
    
    event is assumed to contain object_type and action
} {
    upvar $event dtype_event

    util_memoize_flush_regexp "dtype::get_attributes_list -no_cache -name \"$dtype_event(object_type)\".*"
}

ad_proc -public dtype::edit_attribute {
    {-name:required}
    {-object_type:required}
    {-pretty_name:required}
    {-pretty_plural:required}
    {-default_value ""}
} {
    Sets the details of an attribute.
} {
    db_dml update_attribute {}

    set event(object_type) $object_type
    set event(attribute) $name
    set event(action) updated
    util::event::fire -event dtype.attribute event
}

ad_proc -public dtype::get_attribute {
    {-name:required}
    {-object_type:required}
} {
    Gets all the details of an attribute.
} {
    db_1row select_attribute {} -column_array array
    return [array get array]
}

ad_proc -public dtype::delete_attribute {
    {-name:required}
    {-object_type:required}
    {-drop_column:boolean}
} {
    Drops an attribute on a content type.
} {
    set drop_column [db_boolean $drop_column_p]

    db_exec_plsql drop_attr {}

    set event(object_type) $object_type
    set event(attribute) $name
    set event(action) deleted
    util::event::fire -event dtype.attribute event
}


ad_proc -public dtype::def_from_table {
    {-supertype "acs_object"}
    {-table_name:required}
    {-name_method ""}
} {
    Creates an object type defintion from table defintion. Adds all
    attributes based on reasonable defaults. The table
    must already exist in the database

    @return Tcl code block to generate object type definition
    @see dtype::table::get_db_type_map
} {

    # find primary key for id_column
    set id_column [dtype::table::id_column \
                       -table $table_name]
    # find supertype from foreign key on id_column
    set supertype [dtype::table::supertype \
                       -table $table_name \
                       -id_column $id_column]
    # name from table name
    set name $table_name
    set pretty_name [dtype::table::pretty_name $name]
    # table name is usually already plural
    set pretty_plural $pretty_name
    # FIXME do we want a default name method?
    set name_method ""
    
    set code {}
    append code "
        dtype::create \
            -name \"${table_name}\" \
            -supertype \"${supertype}\" \
            -pretty_name \"${pretty_name}\" \
            -pretty_plural \"${pretty_plural}\" \
            -table_name \"${table_name}\" \
            -id_column \"${id_column}\" \
            -name_method \"${name_method}\"
    "

    # get columns from table
    array set cols [dtype::table::get_table_array -table $table_name]
    set fks [dtype::table::get_fk -table $table_name]
    foreach l $fks {
        foreach {col fk_col fk_table object_p} $l break
        # if columns has a foreign key and its not referrign to an
        # acs_object, its probably a lookup table
        if {!$object_p} {
            set cols($col) "enumeration"
        }
    }
    set type_map [dtype::table::get_db_type_map]
ns_log notice "
DB --------------------------------------------------------------------------------
DB DAVE debugging procedure dtype::def_from_table
DB --------------------------------------------------------------------------------
DB fks = '${fks}'
DB [array names cols]
DB --------------------------------------------------------------------------------"
    foreach col [array names cols] {
        set type $cols($col)
        # append create attribute code
        if {$col != $id_column} {
            # if foreign key and foreign key is not an object
            append code "
dtype::create_attribute \
    -name \"${col}\" \
    -object_type \"${name}\" \
    -data_type \"[string map $type_map $type]\" \
    -pretty_name \"[dtype::table::pretty_name $col]\" \
    -pretty_plural \"[dtype::table::pretty_plural $col]\" \
    -sort_order \"\" \
    -default_value \"\"
"
            }
        }
    
    return $code
}

ad_proc -public dtype::create_form {
    -object_type
    {-dform "standard"}
    {-dforms {content_revision standard acs_object empty_acs_object}}
    {-exclude ""}
    {-spec ""}
    {-evaluate "t"}
} {
     Create a dynamic types form for object type based on type
     definition using intelligent defaults.
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-14
    
    @param object_type Object type form is for

    @param dform Name of form. We can't use 'default' because that is
    reserved for the unspecificed form.

    @param exclude Attributes to exclude from automatically generated form.

    @param spec Declarative specification for form defintion. Optional
    instead of calling dtype::form::generate_widget repeatedly

    @param evaluate T or F, whether to evalute the code or just
    return it 

    @return If evaluate is false, return code generated.
    
    @error 
} {
    set code ""
    # get widget defaults

    # get all types
    set types [dtype::form::types_list \
        -object_id "" \
        -object_type $object_type]
    set object_type [lindex $types 0]
    
    array set type_dforms $dforms

    # FIXME use spec if available!
    
    # get default widgets
    foreach type $types {
	if {[info exists type_dforms($type)]} {
	    set type_dform $type_dforms($type)
	} else {
	    set type_dform "implicit"
	}
        
        dtype::form::metadata::widgets -object_type $type \
                                   -dform $type_dform \
                                   -multirow widgets
        set fks [dtype::table::get_fk -table [dtype::get_table_name -object_type $type]]
        foreach l $fks {
            set fk_array([lindex $l 0]) [lrange $l 1 end]
        }
        template::multirow foreach widgets {
            append code "
            dtype::form::metadata::create_widget \
                -object_type $object_type \
                -dform $dform \
                -attribute_name $attribute_name \
                -widget $widget \
                -required_p 0 \
                -create_form_p 1
"
            # check attribute datatype
            # for foreign keys, if should be enumeration
            # if so, we want to create a select widget
            # that queries the fk table
            if {$datatype == "enumeration" && [info exists fk_array($attribute_name)]} {
                set object_p [lindex $fk_array($attribute_name) 2]
                if {!$object_p} {
                    # create widget param for select list
                    # if type of the foreign key table is a subtype of
                    # content revision, use the i view
                    # also check if its a dtype
                    
                    append code "
                    dtype::form::metadata::create_widget_param \
                        -object_type $object_type \
                        -dform $dform \
                        -attribute_name $attribute_name \
                        -param_name options \
                        -type multilist \
                        -source query \
                        -value \"select title, [lindex $fk_array($attribute_name) 0] from [lindex $fk_array($attribute_name) 1]\"
                        "
                 }

            }

            
        }
    }
    if {$evaluate} {
        eval $code
    } else {
        return $code
    }
}

ad_proc -public dtype::get_table_name {
    -object_type
} {
    
    Get name of type specicifc storage table
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-14
    
    @param object_type Object type

    @return Table Name
    
    @error 
} {
    return [db_string get_table_name "" -default ""]
}

ad_proc -public dtype::get_id_column {
    -object_type
} {
    
    Get name of type specicifc storage table
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-14
    
    @param object_type Object type

    @return Table Name
    
    @error 
} {
    return [db_string get_id_column "" -default ""]
}

