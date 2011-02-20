function show_simple_cms_controls(obj) {
  obj.addClassName('over_simple_cms');
}
function hide_simple_cms_controls(obj) {
  obj.removeClassName('over_simple_cms');
}
function edit_simple_cms_item(simple_cms_item_id, prefix) {
  var base = document.location.href;
  if (prefix != "") {
    //alert("base: " + base);
    base = base.substring(0,base.indexOf("/",base.indexOf("://")+3));
    //alert("modified base: " + base);
    //alert("prefix: " + prefix);
    if (prefix.charAt(0) != "/")
      prefix = "/" + prefix;
    if (prefix.charAt(prefix.length-1) == "/")
      prefix = prefix.substring(0,prefix.lastIndexOf("/"));
    //alert("modified prefix: " + prefix);
    base = base + prefix;
    //alert("full base path: " + base);
    
    if (base.indexOf("/simple_cms_items/edit/") == -1)
        base = base + "/simple_cms_items/edit/" + simple_cms_item_id;
    document.location.href = base;
  } else {
    document.location.href = "/simple_cms_items/edit/" + simple_cms_item_id;
  }
}
