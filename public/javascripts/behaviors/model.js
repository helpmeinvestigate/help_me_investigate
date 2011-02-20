//Applies behaviour rules to the classes
//Author: Brian R Miedlar (c) 2006

var ModelBehavior = Class.create();

ModelBehavior.SampleCarousel = null;
ModelBehavior.CarouselRules = {
    
    '#Carousel': function(element) {
        //Simple profiles
        ModelBehavior.ProfileCarousel = new Carousel('ProfileCarousel', element, 200, 30, ModelBehavior, {
            'setSize': 5,
            'duration': .5,
            'direction': 'vertical',
            'itemParser': function(item) {
                //Given html element you can build a data object for the item if needed for later activation
                var sKey = item.down('.key').innerHTML;
                var sCaption = item.down('.caption').innerHTML;
                var sEmail = item.down('.email').innerHTML;
                return { name:sCaption, email:sEmail };
            },
            'setItemEvents': function(carousel, itemElement, carouselItem, observer) {
                //This allows you to set events to the item like rollovers/mouse events
                Event.observe(itemElement, 'click', function(){                    
                    carousel.activate(carouselItem);
                });
                Event.observe(itemElement, 'mouseover', function(){                    
                    Element.addClassName(itemElement, 'hover');
                });
                Event.observe(itemElement, 'mouseout', function(){                    
                    Element.removeClassName(itemElement, 'hover');
                });
            }
        });
        ModelBehavior.ProfileCarousel.load();
    },
    '#Carousel2': function(element) {    
        //Pictures
        ModelBehavior.PictureCarousel = new Carousel('PictureCarousel', element, 70, 70, ModelBehavior, {
            'setSize': 3,
            'duration': .5,
            'direction': 'horizontal',
            'itemParser': function(item) {
                //Given html element you can build a data object for the item if needed for later activation
                var sKey = item.down('.key').innerHTML;
                var sCaption = item.down('.caption').innerHTML;
                var sPictureHtml = item.down('.picture').innerHTML;
                return { name:sCaption, pictureHtml:sPictureHtml };
            },
            'setItemEvents': function(carousel, itemElement, carouselItem, observer) {
                //This allows you to set events to the item like rollovers/mouse events
                Event.observe(itemElement, 'click', function(){                    
                    carousel.activate(carouselItem);
                });
            }
        });
        ModelBehavior.PictureCarousel.load();
    },
    '#Carousel3': function(itemElement) {
        //Grouped profiles
        ModelBehavior.PictureCarousel = new Carousel('GroupCarousel', element, 200, 100, ModelBehavior, {
            'setSize': 2,
            'duration': .5,
            'groupSize': 3,
            'direction': 'horizontal',
            'itemParser': function(item) {
                //Given html element you can build a data object for the item if needed for later activation
                var sKey = item.down('.key').innerHTML;
                var sCaption = item.down('.caption').innerHTML;
                var sEmail = item.down('.email').innerHTML;
                return { name:sCaption, email:sEmail };
            },
            'setItemEvents': function(carousel, itemElement, carouselItem, observer) {
                //This allows you to set events to the item like rollovers/mouse events
                Event.observe(itemElement, 'click', function(){                    
                    carousel.activate(carouselItem);
                });
            }
        });
        ModelBehavior.PictureCarousel.load();
    }
}

//EVENT OBSERVATION
ModelBehavior.fireActiveCarouselLoaded = function(carousel) {
}
ModelBehavior.fireActiveCarouselItem = function(carousel, element, item) {
    element.addClassName('selected');

    // Here we can update any part of the DOM to represent our data
    // In this sample we will use the same generic viewer element for all carousels
    switch(carousel.key) {
        case 'ProfileCarousel': 
            $('ViewerCaption').update(item.value.name);
            $('ViewerData').update(item.value.email);
            Element.show('Viewer');
            break;
            
        case 'PictureCarousel':
            $('ViewerCaption').update(item.value.name);
            $('ViewerData').update(item.value.pictureHtml);
            Element.show('Viewer');
            break;

        case 'GroupCarousel':
            $('ViewerCaption').update(item.value.name);
            $('ViewerData').update(item.value.email);
            Element.show('Viewer');
            break;
    }
}
ModelBehavior.fireDeactiveCarouselItem = function(carousel, element, item) {
    element.removeClassName('selected');

    switch(carousel.key) {
        case 'ProfileCarousel': 
            Element.hide('Viewer');
            break;

        case 'PictureCarousel': 
            Element.hide('Viewer');
            break;

        case 'GroupCarousel': 
            Element.hide('Viewer');
            break;
    }
}

/**** Load Dependencies ***/
ModelBehavior.Load = function(){
    var Script_Name = 'behaviors/model.js';
    _os.requireAll(Script_Name, [
            'carousel.js'
        ], { 'onComplete': function() {
                _os.onLoadComplete(Script_Name);
                OS.RegisterBehaviour(ModelBehavior.CarouselRules);
            }
    });
}
ModelBehavior.Load();
	