tinyMCE.init({
  mode : "textareas",
  theme : "advanced",
  plugins : "devkit,style,layer,table,save,advhr,emotions,ts_advimage,iespell,preview,advmedia,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,insertcode",
  theme_advanced_disable : "image",
  theme_advanced_buttons1_add_before : "save,newdocument,|",
  theme_advanced_buttons1_add : "fontselect,fontsizeselect",
  theme_advanced_buttons2_add_before: "cut,copy,paste,pastetext,pasteword,|",
  theme_advanced_buttons2_add : "|,preview,|,print,|,fullscreen",
  theme_advanced_buttons3_add_before : "tablecontrols,|",
  theme_advanced_buttons3_add : "emotions,ts_image,advmedia,|,forecolor,backcolor",
  theme_advanced_buttons4 : "insertlayer,moveforward,movebackward,absolute,|,styleprops,|,cite,abbr,acronym,del,ins,attribs,|,insertcode",
  theme_advanced_toolbar_location : "top",
  theme_advanced_toolbar_align : "left",
  theme_advanced_path_location : "bottom",
  extended_valid_elements : "a[name|href|target|title|onclick],img[class|src|style|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style],code_highlighting[type]",
  file_browser_callback : "fileBrowserCallBack",
  theme_advanced_resizing : true,
  nonbreaking_force_tab : true,
  apply_source_formatting : true,
  template_replace_values : {
    username : "Jack Black",
    staffid : "991234"
  },
  relative_urls : false,
  remove_script_host : false
});

function fileBrowserCallBack(field_name, url, type, win) {
  // This is where you insert your custom filebrowser logic
  alert("Example of filebrowser callback: field_name: " + field_name + ", url: " + url + ", type: " + type + ", win: " + win);

  // Insert new URL, this would normaly be done in a popup
  //win.document.forms[0].elements[field_name].value = "someurl.htm";
}
