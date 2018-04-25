# 

ad_library {
    
    Helper procs to infer type definition from a table definition
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-12
    @arch-tag: 89c94863-0000-485f-a889-db6922a19187
    @cvs-id $Id$
}

namespace eval dtype {}
namespace eval dtype::table {}

ad_proc -public dtype::table::get_db_type_map {
} {
     
    List of database datatypes mapped to acs datatypes
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-12
    
    @return List of database_datatype acs_datatype pairs
    
    @error 
} {
    # TODO DAVEB check foreign keys to determine enumeration
    # or keyword types?
    return [db_map get_type_map]
}

ad_proc -public dtype::table::get_table_array {
    -table
} {
     Get a list of columns and datatypes
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-12
    
    @param table Name of table

    @return List in array get format of column name and datatype
    
    @error 
} {
    set cols_lists [db_list_of_lists get_cols ""]
    set cols {}
    foreach l $cols_lists {
        lappend cols [lindex $l 0] [lindex $l 1]
    }
    return $cols
}

ad_proc -public dtype::table::pretty_name {
    name
} {
    
    Generate a pretty name from database name
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-12
    
    @param name Database name

    @return Pretty name
    
    @error 
} {
    # TODO make smarter
    set name [string map {_ " "} $name]
    set name [string totitle $name]
    return $name
}

ad_proc -public dtype::table::pretty_plural {
    name
} {
    
    Generate a pretty plural name from database name
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-12
    
    @param name Database name
 
    @return Pretty plural name
    
    @error 
} {
    # TODO make smarter
    return [en_pl [pretty_name $name]]
}

ad_proc -public dtype::table::id_column {
    -table
} {
      Get the name of the primary key column for the table
    
     @author Dave Bauer (dave@thedesignexperience.org)
     @creation-date 2005-02-12
    
     @param table Name of table

     @return Name of primary key column. If no primary key on this #
      table, return empty string
    
     @error 
} {
    # TODO check if primary key is compound key
    # since I have no idea how to map that to an object type!
    return [db_string get_id_column "" -default ""]
}

ad_proc -public dtype::table::supertype {
    -table
    -id_column
} {
    Guess supertype from table definition. Find foreign key 
    constraint on primary key column
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-02-12
    
    @param table Name of table

    @param id_column Primary key column

    @return Object type of supertype for table or empty string if none
    
    @error 
} {
    return [db_string get_supertype "" -default ""]
}

ad_proc -public dtype::table::get_fk {
    -table
} {
      Get a list of foreign keys
    
     @author Dave Bauer (dave@thedesignexperience.org)
     @creation-date 2005-02-14
    
     @param table Name of table

     @return List of lists of foreign key information column name, 
 foreign key column name, foreign key table name, object_p where
 object_p is true if foreign key table refers to an acs_object_type
    
     @error 
} {
    return [db_list_of_lists get_fk ""]
}

ad_proc dtype::table::en_pl {
    word
} {
    Generate english plurals
    From http://wiki.tcl.tk/2662

    @param word Word to pluralize

    @return Plural form of word
} {
    switch -- $word {
        man   {return men}
        foot  {return feet}
        goose {return geese}
        louse {return lice}
        mouse {return mice}
        ox    {return oxen}
        tooth {return teeth}
        calf - elf - half - hoof - leaf - loaf - scarf
        - self - sheaf - thief - wolf
              {return [string range $word 0 end-1]ves}
        knife - life - wife
              {return [string range $word 0 end-2]ves}
        auto - kangaroo - kilo - memo
        - photo - piano - pimento - pro - solo - soprano - studio
        - tattoo - video - zoo
              {return ${word}s}
        cod - deer - fish - offspring - perch - sheep - trout
        - species
              {return $word}
        genus {return genera}
        phylum {return phyla}
        radius {return radii}
        cherub {return cherubim}
        mythos {return mythoi}
        phenomenon {return phenomena}
        formula {return formulae}
    }
    switch -regexp -- $word {
      {[ei]x$}                  {return [string range $word 0 end-2]ices}
      {[sc]h$} - {[soxz]$}      {return ${word}es}
      {[bcdfghjklmnprstvwxz]y$} {return [string range $word 0 end-1]ies}
      {child$}                  {return ${word}ren}
      {eau$}                    {return ${word}x}
      {is$}                     {return [string range $word 0 end-2]es}
      {woman$}                  {return [string range $word 0 end-2]en}
    }
    return ${word}s
 }
