# 

ad_library {
    
    Procedures to generate tcl/adp pages for dynamic types
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-12
    @arch-tag: 5f74a989-8a4f-4c28-8f8f-deb10e6f5a12
    @cvs-id $Id$
}

namespace eval dtype::page:: {}

ad_proc -public dtype::page::generate_pages {
    -object_type
    -package_key
    {-overwrite "t"}
    {-expand_form "t"}
    {-pages {add}}
} {
     Generate a set of add/edit/delete/index pages
    for a dynamic type
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-12
    
    @param object_type Object type to generate pages for

    @param package_key Package key of package to put pages under

    @param overwrite Overwrite existing pages?

    @return 
    
    @error 
} {
    acs_object_type::get -object_type $object_type -array object_type_info
    set id_column $object_type_info(id_column)
    set pretty_name $object_type_info(pretty_name)
    set dest [file join [acs_root_dir] packages dynamic-types lib ${object_type}]
    if {![file exists $dest]} {
        file mkdir $dest
    }
    foreach page $pages {
        # generate add tcl page
        set fd [open [tcl_template_path -page ${page}]]
        set code [read $fd]
        close $fd
        regsub -all {id_column} $code $id_column code
        regsub -all {pretty_name} $code $pretty_name code
        regsub -all {__object_type} $code $object_type code                
        set fd [open [file join $dest ${page}.tcl] w]
        puts $fd $code
        close $fd
        # generate add adp page
        set fd [open [adp_template_path -page ${page}]]
        set code [read $fd]
        close $fd
        if {$expand_form} {
            set regexp "<formtemplate id=\"${page}\"></formtemplate>"
            set result "<formtemplate id=\"${page}\">[expand_form -object_type $object_type]</formtemplate>"
            regsub $regexp $code $result code
        }
        set fd [open [file join $dest ${page}.adp] w]
        puts $fd $code
        close $fd        
    }
}

ad_proc -public dtype::page::tcl_template_path {
    -page
} {
     Path of templates
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-12
    
    @param page

    @return 
    
    @error 
} {
    return [file join [acs_root_dir] packages dynamic-types lib templates ${page}.tcl]
}

ad_proc -public dtype::page::adp_template_path {
    -page
} {
     Path of templates
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-12
    
    @param page

    @return 
    
    @error 
} {
    return [file join [acs_root_dir] packages dynamic-types lib templates ${page}.adp]
}

ad_proc -public dtype::page::expand_form {
    -object_type
} {
    
    Generate adp for formtemplate
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-12
    
    @param object_type

    @return 
    
    @error 
} {
    set form_id __my_form
    template::form::create $form_id
    dtype::form::add_elements \
        -object_type $object_type \
        -form $form_id
    return [template::form::template $form_id]
}
