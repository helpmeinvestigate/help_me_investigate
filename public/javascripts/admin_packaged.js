function show_simple_cms_controls(obj){obj.addClassName('over_simple_cms');}
function hide_simple_cms_controls(obj){obj.removeClassName('over_simple_cms');}
function edit_simple_cms_item(simple_cms_item_id,prefix){var base=document.location.href;if(prefix!=""){base=base.substring(0,base.indexOf("/",base.indexOf("://")+3));if(prefix.charAt(0)!="/")
prefix="/"+prefix;if(prefix.charAt(prefix.length-1)=="/")
prefix=prefix.substring(0,prefix.lastIndexOf("/"));base=base+prefix;if(base.indexOf("/simple_cms_items/edit/")==-1)
base=base+"/simple_cms_items/edit/"+simple_cms_item_id;document.location.href=base;}else{document.location.href="/simple_cms_items/edit/"+simple_cms_item_id;}}