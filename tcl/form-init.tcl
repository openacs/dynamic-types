ad_library {
    Register attribute callbacks.

    @author Lee Denison (lee@xarg.net)
    @creation-date 2004/11/11
    @cvs-id $Id$
} 

util::event::register -event dtype \
    -match { action deleted } \
    { dtype::form::metadata::flush_cache -type $type -event event }

util::event::register -event dtype.attribute \
    -match { action (created|updated|deleted) } \
    { dtype::form::metadata::flush_cache -type $type -event event }

util::event::register -event dtype.form.metadata. \
    -match { action (created|updated|deleted) } \
    { dtype::form::metadata::flush_cache -type $type -event event }
