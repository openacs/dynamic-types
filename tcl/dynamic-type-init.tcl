ad_library {
    Register attribute callbacks.

    @author Lee Denison (lee@xarg.net)
    @creation-date 2004/11/11
    @cvs-id $Id$
} 

util::event::register -event dtype \
    -match { action (updated|deleted) } \
    { dtype::flush_cache -type $type -event event }

util::event::register -event dtype.attribute \
    -match { action (created|updated|deleted) } \
    { dtype::flush_cache -type $type -event event }
