//Builds a carousel model
//License: This file is entirely BSD licensed.
//Author: Brian R Miedlar (c) 2004-2008 miedlar.com
//Dependencies: prototype.js, behaviour.js

var CarouselItem = Class.create();
CarouselItem.prototype = {
    initialize: function() {
        this.key = null;		
        this.value = null;
        this.element = null;
    }
};
var Carousel = Class.create();
Carousel.prototype = {
    initialize: function(key, carouselElement, itemWidth, itemHeight, observer, options) {
        this.key = key;
        this.observer = observer;
        this.items = [];
        this.activeItem = null;
        this.activeIndex = 0;
        this.navScrollIndex = 0;
        this.duration = 1.0;
        if(options.duration) this.duration = options.duration;
        this.options = options;
        this.direction = 'vertical';
        if(options.direction) this.direction = options.direction;
        this.itemHeight = itemHeight;
        this.itemWidth = itemWidth;
        this.moveOpacity = .6;
        this.setSize = 4;
        if(options.setSize) this.setSize = options.setSize;
        this.carouselElement = $(carouselElement);
        if(!this.carouselElement) { alert('Warning: Invalid carousel element: ' + carouselElement); return; }
        this.itemsElement = this.carouselElement.down('.items');
        if(!this.itemsElement) { alert('Warning: Class \'items\' does not exist as a child element in carousel: ' + carouselElement); return; }
        this.backElement = this.carouselElement.down('.navButton.previous');
        this.forwardElement = this.carouselElement.down('.navButton.next');
        Event.observe(this.backElement, 'click', function(){
            this.scrollBack();
        }.bind(this));
        Event.observe(this.forwardElement, 'click', function(){
            this.scrollForward();
        }.bind(this));
    },
    load: function() {
        var eList = this.itemsElement;
        this.items.clear();
        eList.select('.item').each(function(item) {
            item.carouselKey = null;
            var sKey = '';
            try {
                sKey = item.down('.key').innerHTML;
            } catch(e) {
                alert('Warning: Carousel Items require a child with classname [key]');
                return;            
            }
            
            var oCarouselItem = new CarouselItem();
            if(this.options.itemParser) oCarouselItem.value = this.options.itemParser(item);
            oCarouselItem.index = this.items.length;
            oCarouselItem.key = sKey;
            oCarouselItem.element = item;
            this.items.push(oCarouselItem);
            
            //Store default selection
            if(item.hasClassName('selected')) {
                this.activeItem = oCarouselItem;
                this.activeIndex = this.items.size() - 1;
            }

            if(this.options.setItemEvents) this.options.setItemEvents(this, item, oCarouselItem, this.observer);            
        }.bind(this));
        
        //Post processing        
        this.afterLoad();
    },
    afterLoad: function() {
        if(this.items.length == 0) {
            //console.log('Warning: No Carousel Items Exist');
            return;
        }
        
        //Change the following line to moveToIndex if you do 
        //not want the load animation on default selected items
        //this.moveToIndex(this.activeIndex);        
        this.scrollToIndex(this.activeIndex);        

        if(this.activeItem) this.activate(this.activeItem);
        if(this.observer.fireActiveCarouselLoaded) this.observer.fireActiveCarouselLoaded(this);
    },
    scrollForward: function() {    
        //setsize-1 at a time scrolling 
        if(this.navScrollIndex > this.items.length - (this.setSize+1)) return;
        var iIndex = this.navScrollIndex + (this.setSize-1);
        this.scrollToIndex(iIndex);
        this.activeIndex = iIndex;
    },
    scrollBack: function() {
        var iIndex = this.navScrollIndex - (this.setSize-1);
        if(iIndex < 0) iIndex  = 0;
        this.scrollToIndex(iIndex);
        this.activeIndex = iIndex;
    },
    getLeft: function(index) {
        return index * (-this.itemWidth);
    },
    getTop: function(index) {
        return index * (-this.itemHeight);
    },
    activate: function(carouselItem) {
        if(this.activeItem) this.observer.fireDeactiveCarouselItem(this, this.activeItem.element, this.activeItem);
        if(carouselItem == null) return; 
        this.activeItem = carouselItem;
        if(this.observer.fireActiveCarouselItem) this.observer.fireActiveCarouselItem(this, carouselItem.element, carouselItem);
    },
    next: function() {
        if(this.activeItem == null) { this.activate(this.items[0]); return; }
        var iIndex = this.activeItem.index + 1;
        if(iIndex >= this.items.length) iIndex = 0;
        this.activate(this.items[iIndex]);
        this.activeIndex = iIndex;
    },
    previous: function() {
        if(this.activeItem == null) { this.activate(this.items[0]); return; }
        var iIndex = this.activeItem.index - 1;
        if(iIndex < 0) iIndex = 0;
        this.activate(this.items[iIndex]);
        this.activeIndex = iIndex;
    },
    scrollToIndex: function(index) {        
        if(this.direction == 'vertical') {
            var iPreviousTop = this.getTop(this.navScrollIndex);
            var iTop = this.getTop(index);
            var iCurrentTop = parseInt(Element.getStyle(this.itemsElement, 'top')) || 0;
            var offset = iPreviousTop-iCurrentTop;
            var move = iTop - iPreviousTop;
            if(move > 0) {
                move = move + offset;
            } else {
                move = move - offset;
            }
            Element.setOpacity(this.itemsElement, this.moveOpacity);
            var ef = new Effect.Move(this.itemsElement, {
                'duration': this.duration,
                'y': move, 
                'afterFinish': function() { 
                    Element.setStyle(this.itemsElement, {'top':iTop + 'px'});
                    Element.setOpacity(this.itemsElement, 1.0);
                }.bind(this)
            });
            ef = null;
        } else {
            var iPreviousLeft = this.getLeft(this.navScrollIndex);
            var iLeft = this.getLeft(index);
            var iCurrentLeft = parseInt(Element.getStyle(this.itemsElement, 'left')) || 0;
            var offset = iPreviousLeft - iCurrentLeft;
            var move = iLeft - iCurrentLeft;
            if(move > 0) {
                move = move + offset;
            } else {
                move = move - offset;
            }
            Element.setOpacity(this.itemsElement, this.moveOpacity);
            var ef = new Effect.Move(this.itemsElement, {
                'duration': this.duration,
                'x': move, 
                'afterFinish': function() { 
                    Element.setStyle(this.itemsElement, {'left':iLeft + 'px'});
                    Element.setOpacity(this.itemsElement, 1.0);
                }.bind(this)
            });
            ef = null;
        }
        this.navScrollIndex = index;
        Element.display(this.forwardElement, this.navScrollIndex <= this.items.length - (this.setSize+1));
        Element.display(this.backElement, (parseInt(this.navScrollIndex) || 0) != 0);
        if(this.observer.fireCarouselAtIndex) this.observer.fireCarouselAtIndex(this, index);
    },
    moveToIndex: function(index) {
        if(this.direction == 'vertical') {
            var iTop = this.getTop(index);
            Element.setStyle(this.itemsElement, {'top':iTop + 'px'});
            Element.setOpacity(this.itemsElement, 1.0);
        } else {
            var iLeft = this.getLeft(index);
            Element.setStyle(this.itemsElement, {'left':iLeft + 'px'});
            Element.setOpacity(this.itemsElement, 1.0);
        }

        this.navScrollIndex = index;
        Element.display(this.forwardElement, this.navScrollIndex <= this.items.length - (this.setSize+1));
        Element.display(this.backElement, (parseInt(this.navScrollIndex) || 0) != 0);
    }
};

Carousel.Load = function() {
    var Script_Name = 'carousel.js';
    _os.onLoadComplete(Script_Name);    
};

Carousel.Load();
