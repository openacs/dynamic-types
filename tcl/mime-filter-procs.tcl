ad_library {
    A library of functions to transform uploaded content submissions based on
    mime types.
}

namespace eval dtype {}
namespace eval dtype::mime_filters {}

ad_proc -public dtype::mime_filters::text_html {
    content
} {
    Grabs the content of a the body tags in an html file.  Returns the content
    unchanged if it doesn't contain body tags.
} {
    if { [regexp {<body[^>]*>(.*?)</body>} $content match body] } {
        return $body
    } else {
        return $content
    }
}
