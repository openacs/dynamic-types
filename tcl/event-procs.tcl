ad_library {
    A library which dispatches tcl callback events.

    Events are assigned heirarchical symbolic names, eg:

        major-type
        major-type.minor-type
        major-type.minor-type.leaf-type

    Event handlers register which types they respond to, eg:

        major-type
          - respond only to exact match 'major-type' events

        major-type.
          - respond to all 'major-type' and subtype events

        major-type.minor-type.
          - respond to only to 'major-type.minor-type' and subtype events

    When an event is triggered an array called 'event' is made available to
    the handler containing information about the event.  At registration time
    a handler can specify criteria which must be matched in the event array 
    for this handler to be triggered.

    Functions that fire events should document what information they include
    in the event array.  They should normally include an action which is a 
    verb in the past tense 'created' for events that have just happened or a
    verb in the present tense 'creating' for events that are about to happen.

    Most events won't need this level of flexibility but I did for the stuff
    I was doing when I wrote this.

    @author Lee Denison (lee@xarg.net)
    @creation-date 2004/11/11
    @cvs-id $Id$
} 

namespace eval util {}
namespace eval util::event {}

ad_proc -public util::event::register {
    {-event:required}
    {-match {}}
    script
} {
    Registers <code>script</code> to be run on <code>event</code> if the 
    criteria in <code>match</code> are satisfied.
} {
    set handler [list $match $script]

    ns_mutex lock [nsv_get util_events lock]
    nsv_lappend util_events $event $handler
    ns_mutex unlock [nsv_get util_events lock]
}

ad_proc -public util::event::unregister {
    {-event:required}
    {-match {}}
    script
} {
    Unregisters <code>script</code> from event <code>event</code> where the
    criteria in <code>match</code> are required.
} {
    ns_mutex lock [nsv_get util_events lock]
    if {[nsv_exists util_events $event]} {
        set handlers [nsv_get util_events $event]

        set result [list]
        foreach handler $handlers {
            set cand_match [lindex $handler 0]
            set cand_script [lindex $handler 1]

            if {![string match $script $cand_scripts] ||
                ![util::event::compare_matches $match $cand_match]} {
                lappend result $handler
            }
        }

        nsv_set util_events $event $result
    }
    ns_mutex unlock [nsv_get util_events lock]
}

ad_proc -private util::event::compare_matches {
    match1
    match2
} {
    Compares two match lists for equality.
} {
    foreach crit1 $match1 {
        foreach crit2 $match2 {
            if {![string equal [lindex $crit1 0] [lindex $crit2 0]] ||
                ![string equal [lindex $crit1 1] [lindex $crit2 1]]} {
                return 0
            }
        }
    }

    return 1
}

ad_proc -public util::event::fire {
    {-event:required}
    data
} {
    Fires any scripts registered to event for which the match criteria are 
    satisfied.

    Each event script is executed with access to an event array containing the
    event data.  Consult the documentation of the function that fires the 
    fires the event to see what data is available in the event.
} {
    set type $event
    set type_elms [split $event "."]
    set type_bins [list $event]
    unset event

    upvar $data event

    for {set i 0} {$i < [llength $type_elms]} {incr i} {
        lappend type_bins "[join [lrange $type_elms 0 $i] "."]."
    }

    set results [list]

    foreach type_bin $type_bins {
        if {[nsv_exists util_events $type_bin]} {
            set handlers [nsv_get util_events $type_bin]

            foreach handler $handlers {
                array set match [lindex $handler 0]
                set script [lindex $handler 1]
                set matches_p 1
               
                foreach key [array names match] {
                    set matches_p \
                        [expr {$matches_p || 
                               [regexp -- $match($key) $event($key)]}]

                }

                if {$matches_p} {
                    lappend results [eval $script]
                }
            }
        }
    }

    return $results
}
