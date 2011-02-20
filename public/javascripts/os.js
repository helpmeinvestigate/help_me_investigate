//Defines an Operating System level controller for the Web OS
//Author: Brian R Miedlar (c) 2006-2007 (miedlar.com)

//Globals
var _os = null;

var OS = Class.create({
    'initialize': function() {
        this.appVersion = '0';
        this.sources = [];
        this.scriptsToLoad = [];    //stack to load
        this.loadedScripts = [];    //loaded by onloadcomplete
        this.completedScripts = []; //fired the oncomplete events
        this.completeCallbacks = []; //oncomplete events
        this.scriptLoadListeners = [];
        this.pageLoading = true;
    },
    'addScriptLoadListener': function(listenerCallback, associatedScripts) {
        var loadListener = new Object();
        loadListener.callback = listenerCallback;
        loadListener.associatedScripts = associatedScripts;
        this.scriptLoadListeners.push(loadListener);
    },
    'requireAll': function(caller, scripts, options) {
        options = options || {};
        if(options.onComplete) {
            this.scriptsToLoad.push(options.onComplete);
        }            
        var loadScripts = scripts;
        if(options.extendedWatchScripts) {
            var extendedScripts = options.extendedWatchScripts;
            for(var i = 0; i < extendedScripts.length; i++) {
                loadScripts.push(extendedScripts[i]);
            }
        }
        if(options.scriptLoadListener) this.addScriptLoadListener(options.scriptLoadListener, loadScripts);
        if(typeof scripts == 'string') {
            this.scriptsToLoad.push(scripts);
        } else {
            $A(scripts.reverse()).each(function(script) { //turn stack into queue so order is preserved
                if(!this.sources[script]) this.scriptsToLoad.push(script);
            }.bind(this));
        }        
        this.load();
    },
    'scriptLoaded': function(script) {
        var scripts = [];
        $A(this.scriptsToLoad).each(function(src) {
            if(src != script) scripts.push(src);
        });
        this.scriptsToLoad = scripts;
        if(this.completeCallbacks[script]) {
            this.completeCallbacks[script]();
            this.completeCallbacks[script] = false;
        }
        //broadcast to load listeners
        $A(this.scriptLoadListeners).each(function(listener) {
            var iTotal = 0;
            var iComplete = 0;
            $A(listener.associatedScripts).each(function(script) {
                if(this.completedScripts[script]) iComplete++;
                iTotal++;
            }.bind(this));
            try { listener.callback(iComplete, iTotal);} catch(ex){}
        }.bind(this));
    },
    'loadNext': function() {
        if(!this.queueLoading) return;
        this.requireNext();
        setTimeout(function() { this.loadNext(); }.bind(this), 50);
    },
    'load': function() {
        if(this.queueLoading) return;
        this.queueLoading = true;
        this.loadNext();
    },
    'loadComplete': function() {
        this.queueLoading = false;
    },
    'requireNext': function() {
        if(this.scriptLoadListener) this.scriptLoadListener(this.scriptsToLoad.length);
        if(this.scriptsToLoad.length == 0) { this.loadComplete(); return; }
        var next = this.scriptsToLoad[this.scriptsToLoad.length-1];
        if(typeof next == 'function') {
            next();
            this.scriptsToLoad.pop();
            this.load();
            return;
        } 
        this.require(next, function() { this.load(); }.bind(this));
    },
    'require':  function(src, onComplete) {
        if(this.sources[src]) {
            if(onComplete) setTimeout(onComplete, 10);
            return;   //do not load twice
        }
        this.sources[src] = true;
        
        //insert the script
        if(!OS.Path) { _os.showMessage('Error: Unknown JsOS'); return; }
        var headTag = document.getElementsByTagName("head").item(0); 
        var scriptTag = document.createElement("script"); 
	    scriptTag.setAttribute('type', 'text/javascript');
	    scriptTag.setAttribute('src', OS.Path() + src); 
        headTag.appendChild(scriptTag);
        
        this.waitForLoadComplete(src, onComplete);
    },
    'waitForLoadComplete':  function(script, onComplete) {
        if(this.isQueueLoading(script)) {
            setTimeout(function() { 
                this.waitForLoadComplete(script, onComplete); 
            }.bind(this), 10); 
            return;
        }
        if(this.completedScripts[script]) return;
        this.completedScripts[script] = true;
        if(onComplete) setTimeout(onComplete, 10);
    },
    'isQueueLoading':  function(script) {
        if (!this.loadedScripts[script]) return true;
        return false;
    },
    'onLoadComplete':  function(script) {
        this.loadedScripts[script] = true;
        this.scriptLoaded(script); 
    }
});

OS.Path = function() { return 'clientscript/'; }
OS.Load = function() {
    _os = new OS();
    OS.OnLoadComplete();
};
OS.CreateElement = function(type, parent, id) {
    if(!$(parent)) return;
    var element = document.createElement(type);
    var eElement = $(parent).appendChild(element);
    if(id) eElement.id = id;
    return eElement;
};
OS.CreateDiv = function(parent, id) {
    var eDiv = OS.CreateElement('div', parent, id);
    return eDiv;
};
OS.CreateList = function(parent, id) {
    var eList = OS.CreateElement('ul', parent, id);
    return eList;
};
OS.AddListItem = function(parent, id) {
    var eItem = OS.CreateElement('li', parent, id);
    return eItem;
};
OS.OnLoadComplete = function() {
    if(!Prototype || !Element) {
        setTimeout(OS.OnLoadComplete, 300);
        return;
    }

    _os.onLoadComplete('os.js');
};
OS.PageLoadComplete = function() {
    _os.pageLoading = false;
    $A(OS.BehaviourQueue).each(function(selectors) {
        OS.ApplyBehaviour(selectors);
    });
    OS.BehaviourQueue = [];
};
Event.observe(document, 'dom:loaded', function() {
    OS.PageLoadComplete();
});
OS.BehaviourQueue = [];
OS.RegisterBehaviour = function(selectors) {
    if(!_os.pageLoading) { OS.ApplyBehaviour(selectors); return; }
    OS.BehaviourQueue.push(selectors);    
}
OS.ApplyBehaviour = function(selectors) {
    $H(selectors).each(function(item) {
        $$(item.key).each(function(element) {
            item.value(element);
        });
    });
};
OS.Load();

