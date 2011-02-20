var action, codeDiv, codeType;

function init() {
	tinyMCEPopup.resizeToInnerSize();
  var editor_id = tinyMCE.getWindowArg('editor_id');
	var inst = tinyMCE.getInstanceById(editor_id);
	/*codeDiv = tinyMCE.getParentElement(inst.getFocusElement(), "CODE_HIGHLIGHTING", function(n)
	    {
	        return n.parentNode && n.parentNode.tagName == "CODE_HIGHLIGHTING" && n.parentNode.className == "insert_code";
  });*/

  var focusElm = inst.getFocusElement();
  // If this has <code_highlighting tags already then
  // we are going to use that content
  if (focusElm.nodeName == "CODE_HIGHLIGHTING") {
    action = 'update';
    // Put text in editor
    document.forms[0].codeType.value = focusElm.getAttributeNode('type').nodeValue
    //alert("code: " + focusElm.textContent);
    document.forms[0].codeContent.value = focusElm.textContent;
  } else {
    var selectedText = inst.selection.getSelectedText();
    selectedText = selectedText.replace(/\n\n/g,"\n");
    //alert("text: " + selectedText);
    document.forms[0].codeContent.value = selectedText;
	  action = 'insert';
  }

	document.forms[0].insert.value = tinyMCE.getLang('lang_' + action, 'Insert', true);
	resizeInputs();
}

function insertCode() {
	var codeType = document.forms[0].codeType.options[document.forms[0].codeType.selectedIndex].value;
	var code = document.forms[0].codeContent.value;

  doInsertCode(codeType,code);
}

function doInsertCode(codeType,code) {
	var inst = tinyMCE.getInstanceById(tinyMCE.getWindowArg('editor_id'));
  var codeDiv = inst.getFocusElement(); 
	tinyMCEPopup.execCommand("mceBeginUndoLevel");

	if (action == "update") {
    codeDiv.getAttributeNode('type').nodeValue = codeType
		codeDiv.innerHTML = formatCode(code);
    //alert("code: " + formatCode(code));
	} else {
    code = formatCode(code);
		fullCode = '<code_highlighting type="' + codeType + '">\n' + code + '\n</code_highlighting>';
    //alert("full code: \n" + fullCode);

		tinyMCE.selectedInstance.execCommand("mceInsertContent", false, fullCode);
		tinyMCE.handleVisualAid(inst.getBody(), true, inst.visualAid, inst);
	}

	tinyMCEPopup.execCommand("mceEndUndoLevel");

	tinyMCE.triggerNodeChange();
	if(tinyMCE.isGecko) {
	   // workaround a FF bug   
	   setTimeout(function(){tinyMCEPopup.close();},1000);
	} else {
	   tinyMCEPopup.close();
	}
}

function formatCode(code) {
  code = code.replace(/ /g,"&nbsp;");
  code = code.replace(/\t/g,"&nbsp;&nbsp;");
  code = code.replace(/</g,"&lt;");
  code = code.replace(/>/g,"&gt;");
  code = code.replace(/\n/g,"<br />\n");

  return code;
}

/*function formatHTML(html) {
  html = html.replace(/<br>/g, "\n");
  html = html.replace(/&nbsp;/g, " ");
  html = html.replace(/&lt;/g, "<");
  html = html.replace(/&gt;/g, ">");

  return html;
}*/

var wHeight=0, wWidth=0;

function resizeInputs() {
	if (!tinyMCE.isMSIE) {
		 wHeight = self.innerHeight-140;
		 wWidth = self.innerWidth-16;
	} else {
		 wHeight = document.body.clientHeight - 165;
		 wWidth = document.body.clientWidth - 16;
	}

	document.forms[0].codeContent.style.height = Math.abs(wHeight) + 'px';
	document.forms[0].codeContent.style.width  = Math.abs(wWidth) + 'px';
}

function deleteHighlighting(withTags) {
    
    var stripped = withTags.replace(/\n/gi, "");
    var stripped = stripped.replace(/\r/gi, "");
    
    // Remove very first <li >
    var stripped = stripped.replace(/\<li[^\>]*\>/i, "");

    // Replace following <li >'s with newlines.    
    var stripped = stripped.replace(/\<li[^\>]*\>/gi, "\n");
    
    // Remove all remaining tags
    var stripped = stripped.replace(/\<[^\>]*\>/gi, "");
    
    var stripped = stripped.replace(/\&nbsp\;/gi, " ");
    var stripped = stripped.replace(/\&amp\;/gi, "&");
    var stripped = stripped.replace(/\&lt\;/gi, "<");
    var stripped = stripped.replace(/\&gt\;/gi, ">");
    var stripped = stripped.replace(/\&quot\;/gi, "\"");
    
    document.forms[0].codeContent.value = stripped;
    return true;
}
