ad_library {
    A library of templating functions for datatypes not already supported by 
    acs-templating.  
}

namespace eval template {}
namespace eval template::data {}
namespace eval template::data::validate {}

ad_proc -public template::data::validate::enumeration {
    value_ref
    message_ref
} {
    Always returns true because this function has no way to know which 
    enumeration is being referred to.
} {
    return 1
}
