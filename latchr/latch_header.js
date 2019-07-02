var ello = "govna";

var latch_enabled = true;
var latch_api_header = "/usr/local/include/latch.h";
var class_prefix = "_";
var class_suffix = "$";
var compiled_class_prefix = "example_";

function hookwr(cls)
{
    log("we are wrapping the hook fn for this message. ("+ cls +")");
    hook(cls);
}
