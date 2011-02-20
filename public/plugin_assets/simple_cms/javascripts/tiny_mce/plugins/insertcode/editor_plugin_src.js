/* Import plugin specific language pack */
tinyMCE.importPluginLanguagePack('insertcode');

// InsertCode Plugin
var TinyMCE_InsertCodePlugin = {
  /**
   * Information about the plugin.
   */
  getInfo : function () {
    return {
      longname : 'insertcode plugin',
      author : 'Sean Naegle',
      authorurl : '',
      infourl : '',
      version : "1.0"
    };
  },

  /**
   * Gets executed when a editor needs to generate a button.
   */
  getControlHTML : function (cn) {
    switch (cn) {
      case "insertcode":
        return tinyMCE.getButtonHTML(cn, 'lang_insertcode_desc', '{$pluginurl}/images/insertcode.gif', 'mceInsertCode');
    }

    return "";
  },

  /**
   * Gets executed when a command is called.
   */
  execCommand : function(editor_id, element, command, user_interface, value) {
    // Handle commands
    switch (command) {
      // Remember to have the "mce" prefix for commands so they don't intersect with built in ones in the browser.
      case "mceInsertCode":
        // Open a popup window
        tinyMCE.openWindow({
            file : '../../plugins/insertcode/insertcode.htm',
            width : 550 + tinyMCE.getLang('lang_advmedia_delta_width', 0),
            height : 500 + tinyMCE.getLang('lang_advmedia_delta_height', 0)
          }, {
            editor_id : editor_id,
            resizable : "yes",
            scrollbars : "no"
        });
        
        return true;
    }

    // Pass to next handler in chain
    return false;
  },

  /**
   * Gets executed when the selection/cursor position was changed.
   */
  handleNodeChange : function(editor_id, node, undo_index, undo_levels, visual_aid, any_selection) {
    // Deselect insertcode button
    tinyMCE.switchClass(editor_id + '_insertcode', 'mceButtonNormal');

    // Select insertcode button if parent node is a pre
    if (tinyMCE.getParentElement(node, "code_highlighting"))
      tinyMCE.switchClass(editor_id + '_insertcode', 'mceButtonSelected');

    return true;
  }

  /*
  handleEvent : function(e) {
    var inst = tinyMCE.selectedInstance;
    var w = inst.getWin(), le = inst._lastStyleElm, e;

    if (tinyMCE.isGecko) {
      e = inst.getFocusElement();

      if (e) {
        if (!inst.
    }
  }
  */

  /**
   * displays the outline box
  handleVisualAid : function(el, deep, state, inst) {
    var nl = inst.getDoc().getElementsByTagName("code_highlighting"), i;
    alert("You are in the handleVisualAid() function");
    alert("nl: " + nl);

    for(i=0; i<nl.length; i++) {
      if (new RegExp('absolute|relative|static', 'gi').test(nl[i].style.position)) {
        if (state)
          tinyMCE.addCSSClass(nl[i], 'mceVisualAid');
        else
          tinyMCE.removeCSSClass(nl[i], 'mceVisualAid');
      }
    }
  }
   */
};

tinyMCE.addPlugin("insertcode", TinyMCE_InsertCodePlugin);
