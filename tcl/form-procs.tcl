
ad_library {
    A library of functions to generate forms for acs_objects from stored 
    metadata.
    
    The API manipulates two concepts - forms and widgets.  Forms are 
    mapped to object_types.  Each object_type can have several named forms 
    mapped to it and is always mapped to a form called 'implicit'.  Each 
    form is mapped to several widgets which correspond to the attributes 
    of its object_type.  

    It's possible for example to create two forms 'admin' and 'public'.  
    The public form could contain widgets for the attributes that may be 
    modified by public users whereas the admin form could contain 
    additional elements that admin users can edit.

    The implicit form always contains widgets for all attributes in a type.

    Widgets have associated parameters which control how the html 
    representation is displayed, how values and options are retrieved and
    how submitted values are validated.  Each widget has a default value
    for supported parameters.  Additional default parameter values come in
    to play when a widget is combined a datatype - for example, the 
    default options for a radio widget used for a boolean datatype are 
    'Yes' and 'No'.  Any parameter can, and often should, be overridden 
    for non-implicit forms.
}

namespace eval dtype {}
namespace eval dtype::form {}
namespace eval dtype::form::metadata {}

ad_proc -public dtype::form::add_elements {
    {-object_id ""}
    {-prefix ""}
    {-section ""}
    {-object_type ""}
    {-dform implicit}
    {-dforms {acs_object default content_revision default}}
    {-form:required}
    {-overrides {}}
    {-cr_widget textarea}
    {-cr_widget_options {}}
    {-exclude {}}
    {-exclude_static:boolean}
    {-variables {}}
    {-no_action:boolean}
} {
    Adds the elements of the specified object types dynamic form and all of its
    supertypes dynamic forms to the specified template form.

    This function is used for both add and edit forms.  It determines which is
    appropriate based on whether an object_id or an object_type is supplied.  
    Only one of object_type or object_id may be supplied.

    @param object_id the object represented in the form.  If set the form is
    assumed to be an edit form, otherwise it is assumed to be an object
    create form
    @param object_type the object type whose metadata will define the form
    @param dform specifies the stored object form to use
    @param dforms specifies the stored object form to use for particular object 
    types - used to override the dform parameter
    @param form the name of the template::form to add the elements to (will 
                                                                       create the form if it doesn't already exist)
    @param prefix prefix for each attribute name to avoid collisions
    @param section form section that the elements should be added to
    @param overrides key value pairs that will override the initial value of
    a form element irrespective of the default value in the form 
    metadata of the value in the object being edited
    @param content_widget the widget to use for the content when the 
    object_type is a subtype of content_revision
} {
    if {![template::form exists $form]} {
        template::form create $form
    }

    if {![empty_string_p $object_id]} {
	set object_id [db_string check_object_existence {} -default ""]
    }

    set types [dtype::form::types_list \
                   -object_id $object_id \
                   -object_type $object_type]
    set object_type [lindex $types 0]

    set action edit
    array set type_dforms $dforms
    array set override $overrides

    if {![empty_string_p $object_id] && [info exists override(object_id)]} {
        error "Cannot override object_id for an existing object"
    } elseif {[empty_string_p $object_id]} {
        set action new
        if {![info exists override(object_id)]} {
            set override(object_id) [db_nextval acs_object_id_seq]
        }
    }

    if {!$no_action_p} {
	template::element create $form ${prefix}dform_action \
	    -widget hidden \
	    -datatype text \
	    -sign \
	    -value $action
    }

    foreach type $types {
        if {[info exists type_dforms($type)]} {
            set type_dform $type_dforms($type)
        } else {
            set type_dform $dform
        }

	if {$action != "new"} {
	    dtype::get_object -object_id $object_id \
		-object_type $object_type \
		-array object
	}
        set object(object_id) $object_id

        dtype::form::add_type_elements -object_array object \
            -prefix $prefix \
            -section $section \
            -object_type $type \
            -dform $type_dform \
            -form $form \
            -overrides [array get override] \
            -cr_widget $cr_widget \
            -cr_widget_options $cr_widget_options \
	    -exclude_static_p $exclude_static_p \
	    -exclude $exclude \
	    -variables $variables
    }
}

ad_proc -public dtype::form::process {
    {-prefix ""}
    {-object_type ""}
    {-object_id ""}
    {-dform implicit}
    {-dforms {acs_object default content_revision default}}
    {-form:required}
    {-defaults {}}
    {-default_fields {}}
    {-cr_widget textarea}
    {-cr_storage file}
    {-cr_mime_filters {text/html dtype::mime_filters::text_html}}
    {-exclude {}}
    {-exclude_static:boolean}
    {-dont_publish:boolean}
} {
    Process a dynamic type form submission created by a function such as
    dtype::form::add_elements.  

    @param object_type the object type whose metadata will define the form
    @param dform specifies the stored object form used
    @param dforms specifies the stored object form to use for particular object 
    types - used to override the dform parameter
    @param form the name of the template::form used
    @param prefix the prefix for each attribute name used
    @param defaults default values to use for attributes (this should be used
                                                          to supply values for context_id and the like)
    @param default_fields default columns with values to be used for db insert
    @param cr_widget the input method for the content 
    @param cr_storage the content repository storage method
    @param dont_publish prevents from setting the live_revisions
    
    <p>TODO: Add support for HTMLArea.</p>

    @see dtype::form::add_elements
} {
    # Pull the object_id out of the form - technically a acs_object dform
    # could be created that doesn't include object_id as a field in which
    # case this would just break.
    if {[empty_string_p $object_id]} {
	set object_id [template::element::get_value $form ${prefix}object_id]
    }

    # Pull the action out of the form
    set action [template::element::get_value $form ${prefix}dform_action]
    set new_p [string equal $action "new"]

    if {$new_p} {
        set types [dtype::form::types_list \
                       -object_type $object_type]
    } else {
        set types [dtype::form::types_list \
                       -object_id $object_id]
    }

    set content_type_p [expr {[lsearch $types "content_revision"] >= 0}]

    db_1row get_type_info {} -column_array type_info

    array set type_dforms $dforms
    array set default $defaults

    #######################################################
    # Setup default values for object creation
    #
    set default(object_type) $object_type
    if {![info exists default(creation_user)]} {
	set default(creation_user) [ad_conn user_id]
    }
    if {![info exists default(creation_ip)]} {
	set default(creation_ip) [ad_conn peeraddr]
    }
    if {![info exists default(context_id)]} {
	set default(context_id) [db_null]
    }
    if {![info exists default(package_id)]} {
	set default(package_id) [ad_conn package_id]
    }
    if {![info exists default(parent_id)]} {
	set default(parent_id) [db_null]
    }
    if {![info exists default(nls_language)]} {
	set default(nls_language) [db_null]
    }
    if {![info exists default(publish_date)]} {
	set default(publish_date) [db_null]
    }
    
    #######################################################
    # Content Repository specific preparations
    #
    if {$content_type_p} {
	if {![info exists default(mime_type)]} {
	    set default(mime_type) "text/plain"
	}
        if {$new_p} {
            # We are creating an initial revision of a content item (ie. a new 
            # instance of a subtype of content_revision).  We need to first 
            # create a content_item object.
            set item_id [db_nextval acs_object_id_seq]

            array set item_defaults [list item_id $item_id \
                                         name "item$item_id" \
                                         locale [db_null] \
                                         parent_id [db_null] \
                                         content_type $object_type \
                                         context_id [db_null] \
                                         package_id [ad_conn package_id] \
                                         creation_user [ad_conn user_id] \
                                         creation_ip [ad_conn peeraddr] \
                                         storage_type $cr_storage]
            
            foreach var [array names item_defaults] {
                if {[info exists default($var)]} {
                    set item_$var $default($var)
                } else {
                    set item_$var $item_defaults($var)
                }
            }

            #
            # Create the item for this for this new object
            #
            db_exec_plsql create_item {}
        } else {
            # We are adding a revision to an existing content type - we ignore
            # any passed in storage type and use the one set in the content 
            # item
            set item_id [item::get_item_from_revision $object_id]
            content::item::get -item_id $item_id -array item

            set cr_storage $item(storage_type)
        }

        # Prepare any content in the form and set the mime type
        if {![string equal $cr_widget none]} {
            set content [template::element get_value $form ${prefix}content]
            set tmp_file [ns_queryget ${prefix}content.tmpfile]
            set default(filename) ""

            # Make sure we have a file to upload the content from in utf-8 
            # encoding
            if {![string equal $cr_widget file]} {
                set tmp_file [dtype::write_utf8_file $content]
            } elseif {[regexp {\.(htm|html|txt)$} $content]} {
                # check for a text file based on the extension (not ideal)
                set default(filename) $content
                set content [template::util::read_file $tmpfile]
                set tmp_file [dtype::write_utf8_file $content]
            }

            set default(mime_type) [ns_guesstype $default(filename)]
        }
    }

    #######################################################
    # Build up insert statement from metadata
    #
    set columns [list]
    set values [list]

    # set default fields with provided values
    foreach var_spec $default_fields {
	set var_name [lindex $var_spec 0]
	if {[llength $var_spec] > 1} {
	    set var_value [uplevel subst \{[lindex $var_spec 1]\}]
	} else {
	    upvar 1 $var_name upvar_variable
	    if {[info exists upvar_variable]} {
		set crvd_$var_name $upvar_variable
		set var_value ":crvd_$var_name"
	    } else {
		set var_value "null"
	    }
	}
	lappend columns $var_name
	lappend values $var_value
    }


    # LEED context_id and similar fields should be passed in using the
    # -defaults { context_id 1234 } argument
    
    foreach type $types {
        set missing_columns ""
        # Add attributes to $columns and associated bind variables to $values 
        # for each type
        if {[info exists type_dforms($type)]} {
            set type_dform $type_dforms($type)
        } else {
            set type_dform $dform
        }

        # get the attribute metadata for the object type
        dtype::get_attributes -name $type \
            -start_with $type \
            attributes

        dtype::form::metadata::widgets -object_type $type \
            -dform $type_dform \
	    -exclude_static_p $exclude_static_p \
            -indexed_array widgets

        set size [template::multirow size attributes]
        for {set i 1} {$i <= $size} {incr i} {
            template::multirow get attributes $i
            
	    # exclude specified widgets
            if {[lsearch -exact $exclude $attributes(name)] > -1} {
		continue
	    }

            set crv_$attributes(name) "" 

            ns_log debug "PROCESSING: $attributes(name)"
            if {[info exists widgets($attributes(attribute_id))]} {
                ns_log debug "PROCESSING: found $attributes(name) in form"
                # first check for the attribute in the submitted form
                array set this_widget_info $widgets($attributes(attribute_id))
                switch $this_widget_info(widget) {
                    file {}
		    checkbox - multiselect {
                        set crv_$attributes(name) [template::element::get_values $form ${prefix}$attributes(name)]
                    }
                    default {
                        set crv_$attributes(name) [template::element::get_value $form ${prefix}$attributes(name)]
                    }
                }
            } elseif {[info exists default($attributes(name))]} {
                ns_log debug "PROCESSING: using supplied default for $attributes(name)"
                if {[empty_string_p [set crv_$attributes(name)]]} {
                    # second check if the caller supplied a default value
                    set crv_$attributes(name) $default($attributes(name))
		}

	    } elseif {$new_p && ![empty_string_p $attributes(default_value)]} {
		ns_log debug "PROCESSING: using attribute default for $attributes(name)"

		# if we are inserting a new object then use the attributes 
		# default value
		set crv_$attributes(name) $attributes(default_value)

	    } elseif {!$new_p} {
		ns_log debug "PROCESSING: using existing value for $attributes(name) (ie. adding it to missing columns)"

		# append the column to missing columns so that the value
		# is copied from the previous revision when we are dealing
		# with content types
		if {[lsearch -exact {creation_date last_modified modifying_ip} $attributes(name)] == -1} {
		    lappend missing_columns $attributes(column_name)
		}
	    }

	    if {![empty_string_p [set crv_$attributes(name)]] && [lsearch -exact $columns $attributes(name)] == -1} {
		lappend columns $attributes(column_name)

		# cast the value to the appropriate datatype
		switch $attributes(datatype) {
		    date - time_of_day - timestamp {
			lappend values [template::util::date::get_property sql_date [lindex [set crv_$attributes(name)] 0]]
		    }
		    boolean {
			lappend values [ad_decode [set crv_$attributes(name)] t true false]
		    }
		    default {
			lappend values ":crv_$attributes(name)"
		    }
		}
            }
        }
    }

    #######################################################
    # Perform the insert or update as appropriate
    #

    # the postgres "insert into view" is rewritten by the rule into a "select", so no dml..
    set db_stmt [expr {[db_driverkey ""] eq "postgresql" ? "db_0or1row" : "db_dml"}] 

    # title, description, object_title
    if {$content_type_p} {
	set pos [lsearch -exact $columns package_id]
	set columns [lreplace $columns $pos $pos object_package_id]
	set columns [concat "item_id" "revision_id" $columns]
	set values [concat ":item_id" ":object_id" $values]

	# Make sure not to set the object_package_id as this does not work
	# More important though: The content_revision__new function automatically 
	# detects the package_id of the item.

	# Ideally someone would get rid of object_package_id and :crv_package_id 
	# in columns and values. MS 2006/08/07
	set crv_package_id ""

	db_transaction {
	    if {$new_p} { 
		$db_stmt insert_statement "
                    insert into ${type_info(table_name)}i 
                    ([join $columns ", "])
                    values 
                    ([join $values ", "])"
	    } else { 
		set latest_revision [content::item::get_latest_revision -item_id $item_id]
		set object_id [db_nextval acs_object_id_seq]

		$db_stmt insert_statement "
                    insert into ${type_info(table_name)}i 
                    ([join [concat $columns $missing_columns] ", "])
                    select  
                    [join [concat $values $missing_columns] ", "]
                    from ${type_info(table_name)}i
                    where revision_id = $latest_revision"
	    }

	    if {!$dont_publish_p} {
		content::item::set_live_revision -revision_id $object_id
	    }

	    set revision_ids [db_list get_revision_ids {}]
	    set revision_id [lindex $revision_ids 0]
	    set prev_revision_id [lindex $revision_ids 1]

	    if {[string equal $cr_widget none] ||
		([string equal $cr_widget file] && 
		 [string equal $tmp_file ""])} {

		# either a content widget wasn't included in the form or
		# no new file was uploaded, so we want to preserve the previous
		# revisions content
		if {![string equal $prev_revision_id ""]} {
		    db_dml update_content {}
		}
	    } else {
		dtype::upload_content -item_id $item_id \
		    -revision_id $revision_id \
		    -file $tmp_file \
		    -storage_type $cr_storage

		ns_unlink $tmp_file
	    }
	}
    } else {
	if {$new_p} { 
	    $db_stmt insert_statement "
                insert into ${type_info(table_name)}i ([join $columns ", "])
                values ([join $values ", "])"
	} else {
	    set updates [list]

	    set all_columns [concat $columns $missing_columns]
	    set all_values [concat $values $missing_columns]

	    set length [llength $all_columns]
	    for {set i 0} {$i < $length} {incr i} {
		lappend updates "[lindex $all_columns $i] = [lindex $all_values $i]"
	    }

	    db_dml update_statement "
                update ${type_info(table_name)}i 
                set [join $updates ", "]
                where $type_info(id_column) = :object_id"
	}
    }

    return $object_id
}

ad_proc -private dtype::form::add_type_elements {
    {-object_array ""}
    {-prefix ""}
    {-section ""}
    {-object_type:required}
    {-dform implicit}
    {-form:required}
    {-overrides {}}
    {-cr_widget textarea}
    {-cr_widget_options {}}
    {-exclude_static_p 0}
    {-exclude {}}
    {-variables {}}
} {
    Adds the elements of the specified or implicit object form to the specified
    template form.  

    @param object_array the object for the form (not set for object creation)
    @param object_type the object type whose metadata will define the form
    @param dform specifies the stored object form to use
    @param form the name of the template::form to add the elements to
    @param prefix optional prefix for each attribute name to avoid collisions
    @param section optional form section that the elements should be added to
} {
    upvar $object_array object
    array set override $overrides

    set new_p [string equal $object(object_id) ""]

    ############################################################
    # Get the widget metadata
    #
    dtype::form::metadata::widgets -object_type $object_type \
        -dform $dform \
	-exclude_static_p $exclude_static_p \
        -multirow widgets
    
    dtype::form::metadata::params -object_type $object_type \
        -dform $dform \
        -multirow params \
	-exclude $exclude

    set widget_count [template::multirow size widgets]
    set param_count [template::multirow size params]

    set default_locale [lang::user::site_wide_locale -user_id [ad_conn user_id]]
    set p 1

    # Generate form elements for each attribute / widget
    for {set w 1} {$w <= $widget_count} {incr w} {
        template::multirow get widgets $w 
        set html_options [list]
        set widget_options [list]

	# exclude specified widgets
	if {[lsearch -exact $exclude $widgets(attribute_name)] > -1} {
	    continue
	}

        # set the default values for overridable options
	set overridables(help_text) "[_ acs-translations.$widgets(object_type)\_$widgets(attribute_name)\_help]"
	set message_key "acs-translations.$widgets(object_type)\_$widgets(attribute_name)"
	if {[lang::message::message_exists_p $default_locale $message_key]} {
	    set overridables(label) "[_ $message_key]"
	} else {
	    set overridables(label) $widgets(pretty_name)
	}

        # Create the main element create line
        set element_create_cmd "template::element create \
          \$form \${prefix}\$widgets(attribute_name) \
          -widget \$widgets(widget) \
          -datatype \$widgets(datatype) \
          -section \$section \
          -nospell"

        if {![template::util::is_true $widgets(is_required)]} {
            append element_create_cmd " -optional"
        }

        if {![string equal $widgets(widget) file]} {
            # Append the initial value
            if {[info exists override($widgets(attribute_name))]} {
		regsub -all {\"} $override($widgets(attribute_name)) {\\"} override($widgets(attribute_name)) 
                append element_create_cmd " [dtype::form::value_switch \
                    -widget $widgets(widget) \
                    -value $override($widgets(attribute_name))]"
            } elseif {$new_p} {
                append element_create_cmd " [dtype::form::value_switch \
                    -widget $widgets(widget) \
                    -value $widgets(default_value)]"
            } else {
		regsub -all {\"} $object($widgets(attribute_name)) {\\"} object($widgets(attribute_name)) 
                append element_create_cmd " [dtype::form::value_switch \
                    -widget $widgets(widget) \
                    -value $object($widgets(attribute_name))]"
            }
        }

	ns_log Debug "CREATE::: $element_create_cmd"
        # Get all the params for this element
        for {set p 1} {$p <= $param_count} {incr p} {
            template::multirow get params $p

            if {$params(attribute_id) != $widgets(attribute_id)} {
                # No more parameters for this widget, finish
                # processing this element
                # break;
		continue
            }

            set value [lang::util::localize [dtype::form::parameter_value -parameter params -vars $variables]]

            # determine if the parameter value is null
            switch $params(param_type) {
                onelist -
                multilist {
                    set null_value_p [expr {[llength $value] == 0}]
                }
                default {
                    set null_value_p [string equal $value ""]
                }
            }

            if {$params(param) == "options"} {
		lappend widget_options "-$params(param)"
		lappend widget_options $value
	    }

            if {!$null_value_p || $params(param) == "options"} {
                if {[template::util::is_true $params(is_html)]} {
                    lappend html_options $params(param)
                    lappend html_options $value
                } else {
                    if {[info exists overridables($params(param))]} {
                        set overridables($params(param)) $value
                    } else {
                        lappend widget_options "-$params(param)"
                        lappend widget_options $value
                    }
                }
            }
        }

        set options_line "-html {$html_options} $widget_options"

        # append the overridable options
        foreach name [array names overridables] {
            append options_line " -${name} \$overridables($name)"
        }

        # sign all hidden variables
        if {[string equal $widgets(widget) "hidden"]} {
            append options_line " -sign"
        }

        # Actually create the element
        eval $element_create_cmd $options_line
    }

    ############################################################
    # Add the content widget if it is needed
    #
    array set cr_options_array {
        label     dynamic-types.content
        optional  0
        html      {}
    }

    array set cr_options_array $cr_widget_options
    
    if {[string equal $object_type "content_revision"] &&
        ![string equal $cr_widget "none"]} {

        set element_create_cmd "template::element create \$form \
            \${prefix}content \
            -label \[_ \$cr_options_array(label)\] \
            -widget \$cr_widget \
            -datatype text \
            -html \$cr_options_array(html) \
            -nospell \
            -section \$section"

        if {[template::util::is_true $cr_options_array(optional)]} {
            append element_create_cmd " -optional"
        }

        if {![string equal $cr_widget file]} {
            if {[info exists override($widgets(attribute_name))]} {
                append element_create_cmd " [dtype::form::value_switch \
                    -widget $widgets(widget) \
                    -value $override($widgets(attribute_name))]"
            } elseif {$new_p} {
                # don't try to put content in the form element on new form
                append element_create_cmd " [dtype::form::value_switch \
                    -widget $widgets(widget) \
                    -value $widgets(default_value)]"
            } else {
                # Append the content value
                append element_create_cmd " [dtype::form::value_switch \
                    -widget $cr_widget \
                    -value [cr_write_content -string \
                               -revision_id $object(object_id)]]"
            }
        }

        # Actually create the element
        eval "$element_create_cmd"
    }
}

ad_proc -private dtype::form::value_switch {
    {-widget:required}
    {-value:required}
} {
    Return a -value or -values switch appropriately 
} {
    switch $widget {
        file {}
        checkbox -
        multiselect {
            return "-values \"$value\""
        }
        date {
            return "-value {[template::util::date::from_ansi $value]}"
        }
        default {
            return "-value \"$value\""
        }
    }
}

ad_proc -private dtype::upload_content {
    {-item_id:required}
    {-revision_id:required}
    {-file:required}
    {-storage_type:required}
} {
    Upload the content in file for the specified revision and store using
    the method specified.
} {
    if {[string equal $storage_type file]} {
        set file_path [cr_create_content_file $item_id $revision_id $file]
        set file_size [file size $file]
        db_dml upload_file_revision {}
    } elseif {[string equal $storage_type text]} {
        # upload the file into the revision content
        db_dml upload_text_revision {} -blob_files [list $file]
    } else {
        # upload the file into the revision content
        db_dml upload_revision {} -blob_files [list $file]
    }
}

ad_proc -private dtype::write_utf8_file {
    content
} {
    Write a temporary file in utf-8 character encoding containing the text 
    supplied.
} {
    set tmp_file [ns_tmpnam]

    set fd [open $tmp_file w]
    fconfigure $fd -encoding utf-8

    puts $fd $content
    
    close $fd
    return $tmp_file
}

ad_proc -private dtype::form::types_list {
    {-object_id ""}
    {-object_type ""}
} {
    Returns the type hierarchy for the supplied object_id or object_type.  If 
    both are supplied then the hierarchy of the object_id takes precedence 
    over the supplied type.  When the object_type is used it is included in the
    returned list.
} {
    if {![string equal $object_id ""]} {
        return [db_list instance_supertypes {}]
    } else {
        return [db_list supertypes {}]
    }
}

ad_proc -private dtype::form::parameter_value {
    {-object_type ""}
    {-parameter:required}
    {-vars:required}
} {
    Calculates and returns the current value for the supplied parameter array 
    based on its type, source and default_value attributes.
    Provide variables to tcl-procs by \$variables(--name--)
} {
    upvar $parameter param
    array set variables $vars
    set value ""

    set attribute_id $param(attribute_id)

    if {[string equal $object_type ""]} {
        set object_type [db_string get_object_type {}]
    }
    switch $param(param_source) {
        eval {
            set value [eval $param(value)]
        }
        query {
            if [catch {
                switch $param(param_type) {
                    onevalue {
                        set value [db_string param_query $param(value)]
                    }
                    onelist {
                        set value [db_list param_query $param(value)]
                    }
                    multilist {
                        set value [db_list_of_lists param_query $param(value)]
                        # if the option list is empty, return
                        # somethign the select widget can use
                        if {$value eq ""} {
                            set value [list [list]]
                        }
                    }             
                }
            }] {
                set name $param(param)
                ns_log warning "[_ dynamic-types.unable_to_retrive_param]"
                set value ""
            }
        }
        default {
            set value $param(value)
            if { [template::util::is_nil value] } {
                set value $param(default_value)
            }
        }
    }
    # end switch
    return $value
}

ad_proc -public dtype::form::metadata::widgets {
    {-object_type:required}
    {-dform:required}
    {-multirow {}}
    {-indexed_array {}}
    {-exclude_static_p 0}
} {
    Returns the widget metadata for the specified object_type and dform
    as either a multirow or an indexed array.

    @param object_type the object type whose metadata will define the form
    @param dform specifies the stored object form to use
    @param multirow the name of the multirow to populate
    @param indexed_array an array of row data indexed with attribute_id
} {
    set multirow_p [expr {![string equal $multirow ""]}]

    if {!$multirow_p && [string equal $indexed_array ""]} {
        error [_ dynamic-types.must_supply_either_multirow_or_indexed_array]
    }

    set keys [list \
                  attribute_id \
                  object_type \
                  table_name \
                  attribute_name \
                  pretty_name \
                  pretty_plural \
                  sort_order \
                  datatype \
                  default_value \
                  min_n_values \
                  max_n_values \
                  storage \
                  static_p \
                  column_name \
                  form_id \
                  form_name \
                  element_id \
                  widget \
                  is_required \
                 ]


    if {$multirow_p} {
        eval "template::multirow create \$multirow $keys"
    } else {
        upvar $indexed_array result
    }

    set metadata [dtype::form::metadata::widgets_list \
                      -object_type $object_type \
		      -exclude_static_p $exclude_static_p \
                      -dform $dform]

    foreach widget $metadata {
        if {$multirow_p} {
            eval "template::multirow append \$multirow $widget"
        } else {
            for {set i 0} {$i < [llength $keys]} {incr i} {
                set row([lindex $keys $i]) [lindex $widget $i]
            }
            
            set result([lindex $widget 0]) [array get row]
        }
    }
}

ad_proc -private dtype::form::metadata::widgets_list {
    {-no_cache:boolean}
    {-object_type:required}
    {-dform:required}
    {-exclude_static_p 0}
} {
    Returns a list of lists with the widget metadata for the specified 
    object_type and dform.

    @param object_type the object type whose metadata will define the form
    @param dform specifies the stored object form to use
    @param no_cache does not attempt to use the cache to retrieve the info
} {
    if {$no_cache_p} {
	if {$exclude_static_p} {
	    return [db_list_of_lists select_dform_metadata_dynamic {}]
	} else {
	    return [db_list_of_lists select_dform_metadata {}]
	}
    } else {
        return [util_memoize "dtype::form::metadata::widgets_list -no_cache -object_type \"$object_type\" -dform \"$dform\" -exclude_static_p $exclude_static_p"]
    }
}

ad_proc -public dtype::form::metadata::params {
    {-object_type:required}
    {-dform:required}
    {-multirow {}}
    {-indexed_array {}}
    {-exclude {}}
} {
    Returns the widget metadata for the specified object_type and dform
    as either a local multirow or an indexed array.

    @param object_type the object type whose metadata will define the form
    @param dform specifies the stored object form to use
    @param multirow the name of the multirow to populate
    @param indexed_array an array of rows index with attribute_id,param_name
} {
    set multirow_p [expr {![string equal $multirow ""]}]

    if {!$multirow_p && [string equal $indexed_array ""]} {
        error [_ dynamic-types.must_supply_either_multirow_or_indexed_array]
    }

    set keys [list \
                  element_id \
                  attribute_id \
                  form_id \
                  form_name \
                  param_id \
                  param_type \
                  param_source \
                  value \
                  param \
                  is_required \
                  is_html \
                  default_value \
		  attribute_name
	     ]

    if {$multirow_p} {
        eval "template::multirow create \$multirow $keys"
    } else {
        upvar $indexed_array result
    }

    set metadata [dtype::form::metadata::params_list \
                      -object_type $object_type \
                      -dform $dform]
    
    foreach param $metadata {
	if {[empty_string_p $exclude] || [lsearch -exact $exclude [lindex $param 12]] == -1} {

	    if {$multirow_p} {
		eval "template::multirow append \$multirow $param"
	    } else {
		for {set i 0} {$i < [llength $keys]} {incr i} {
		    set row([lindex $keys $i]) [lindex $param $i]
		}

		set row_key [lindex $param 1],[lindex $param 8]
		set result($row_key) [array get row]
	    }
	}
    }
}

ad_proc -private dtype::form::metadata::params_list {
    {-no_cache:boolean}
    {-object_type:required}
    {-dform:required}
} {
    Returns a list of lists with the widget parameter metadata for the 
    specified object_type and dform.

    @param object_type the object type whose metadata will define the form
    @param dform specifies the stored object form to use
    @param no_cache does not attempt to use the cache to retrieve the info
} {
    if {$no_cache_p} {
        return [db_list_of_lists select_dform_metadata {}]
    } else {
        return [util_memoize "dtype::form::metadata::params_list -no_cache -object_type \"$object_type\" -dform \"$dform\""]
    }
}

ad_proc -private dtype::form::metadata::flush_cache {
    {-type:required}
    {-event:required}
} {
    Flushes the util_memoize cache of dtype::form::metadata calls for a given
    object type.

    event is assumed to contain object_type.
} {
    upvar $event dtype_event

    set function "dtype::form::metadata::\[^ \]*_list -no_cache" 
    set object_type "-object_type \"$dtype_event(object_type)\""

    if {[string equal $type dtype] || [string equal $type dtype.attribute]} {
        # flush the default form
        util_memoize_flush_regexp "$function $object_type -dform \"implicit\".*"
    } else {
        set dform $dtype_event(dform)

        # flush the form specified in the event
        util_memoize_flush_regexp "$function $object_type -dform \"$dform\".*"
    }
}

ad_proc -public dtype::form::metadata::widget_templates {
    {-datatypes {}}
    multirow
} {
    set datatype_clause ""

    if {[llength $datatypes] > 0} {
        set datatype_clause "and wt.datatype in ('[join $datatypes "', '"]')"
    }
    
    db_multirow $multirow select_widget_templates {}
}

ad_proc -public dtype::form::metadata::widget_template {
    {-template:required}
    array
} {
    Get a widget template.
} {
    upvar $array result

    db_1row select_widget_template {} -column_array result
}

ad_proc -public dtype::form::metadata::widget_template_params {
    {-template:required}
    multirow
} {
    db_multirow -local -upvar_level 2 $multirow select_widget_template_params {}
}

ad_proc -public dtype::form::metadata::create_widget {
    {-object_type:required}
    {-dform:required}
    {-attribute_name:required}
    {-widget:required}
    {-required_p 0}
    {-create_form_p 1}
} {
    Creates a widget for the specified form on the specified object type.
} {
    set required_p [db_boolean $required_p]
    set create_form_p [db_boolean $create_form_p]

    db_exec_plsql create_widget {}

    set event(object_type) $object_type
    set event(dform) $dform
    set event(attribute) $attribute_name
    set event(widget) $widget
    set event(action) created
    util::event::fire -event dtype.form.metadata.widget event
}

ad_proc -public dtype::form::metadata::delete_widget {
    {-object_type:required}
    {-dform:required}
    {-attribute_name:required}
    {-delete_form_p 1}
} {
    Creates a widget for the specified form on the specified object type.
} {
    set delete_form_p [db_boolean $delete_form_p]

    db_exec_plsql delete_widget {}

    set event(object_type) $object_type
    set event(dform) $dform
    set event(attribute) $attribute_name
    set event(action) deleted
    util::event::fire -event dtype.form.metadata.widget event
}

ad_proc -public dtype::form::metadata::create_widget_param {
    {-object_type:required}
    {-dform:required}
    {-attribute_name:required}
    {-param_name:required}
    {-type:required}
    {-source:required}
    {-value:required}
} {
    Create a parameter for the specified widget.
} {
    db_exec_plsql create_widget_param {}

    set event(object_type) $object_type
    set event(dform) $dform
    set event(attribute) $attribute_name
    set event(param) $param_name
    set event(action) created
    util::event::fire -event dtype.form.metadata.widget.param event
}

ad_proc -public dtype::form::metadata::clone_widget_template {
    {-object_type:required}
    {-dforms:required}
    {-attribute_name:required}
    {-template_name:required}
    {-required_p 0}
} {
    Create a widget and corresponding parameters according to the
    specified template.
} {
    dtype::form::metadata::widget_template -template $template_name template 
    dtype::form::metadata::widget_template_params -template $template_name \
        template_params

    set size [template::multirow size template_params]

    foreach dform $dforms {
        dtype::form::metadata::create_widget \
            -object_type $object_type \
            -dform $dform \
            -attribute_name $attribute_name \
            -widget $template(widget) \
            -required_p $required_p 

        for {set i 1} {$i <= $size} {incr i} {
            template::multirow get template_params $i

            dtype::form::metadata::create_widget_param \
                -object_type $object_type \
                -dform $dform \
                -attribute_name $attribute_name \
                -param_name $template_params(param) \
                -type $template_params(param_type) \
                -source $template_params(param_source) \
                -value $template_params(value)
        }        
    } 
} 

ad_proc -public dtype::form::metadata::delete_attribute_widgets {
    {-object_type:required}
    {-attribute_name:required}
} {
    Delete widgets associated with a specified attribute.
} {
    db_foreach get_widget_forms {} {
        dtype::form::metadata::delete_widget -object_type $object_type \
            -attribute_name $attribute_name \
            -dform $dform
    }
}

ad_proc -public dtype::form::new {
    {-object_type:required}
    {-form_name:required}
    {-form_id ""}
} {
    Create new dynamic form
} {
    if {[empty_string_p $form_id]} {
	set form_id [db_nextval t_dtype_seq]
    }

    db_dml insert_form {}

    set event(object_type) $object_type
    set event(dform) $form_name
    set event(action) created
    util::event::fire -event dtype.form event
}

ad_proc -public dtype::form::edit {
    {-object_type:required}
    {-form_name:required}
    {-form_id:required}
} {
    Update dynamic form name
} {
    db_dml update_form {}

    set event(object_type) $object_type
    set event(dform) $form_name
    set event(action) updated
    util::event::fire -event dtype.form event
}
