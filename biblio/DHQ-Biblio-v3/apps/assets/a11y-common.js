// Common functions for web accessibility

// Set up namespace for DHQ functions
var bibjs = bibjs || {};
bibjs.a11y = {};

// Create an anonymous function to hold functions to be namespaced.
(function() {
  /* Capture the current context so these functions can refer to themselves even 
    when the context changes. */
  var that = this;
  
  /*** Private functions ***/
  
  var getAriaControlTargets = function(el) {
    var idrefs, targetList,
        ariaControls = el.attributes['aria-controls'],
        targetElList = [];
    if ( ariaControls !== undefined ) {
      idrefs = ariaControls.value;
      targetList = idrefs.split(/\s+/);
      targetList.forEach( function(idref) {
        var refEl = document.getElementById(idref);
        if ( refEl !== null ) {
          targetElList.push(refEl);
        }
      });
    }
    return targetElList;
  };
  
  
  /*** Public functions ***/
  
  this.hideBlock = function(el) {
    el.classList.add('noshow');
    el.attributes['aria-hidden'] = true;
  }; // this.hideBlock()
  
  this.showBlock = function(el) {
    el.classList.remove('noshow');
    el.attributes['aria-hidden'] = false;
  }; // this.showBlock()
  
  this.signalAjaxResponse = function(el, jxhr, statusStr) {
    var statusMsg;
    if ( el.attributes['role'].value === 'status' ) {
      switch (statusStr) {
        case 'success':
          statusMsg = "Success!"; break;
        case 'error':
        case 'timeout':
        case 'abort':
        case 'parsererror':
          statusMsg = "Error.";
          console.warn(jxhr);
          break;
        default:
          statusMsg = "Finished."
      }
      statusMsg += " " + new Date();
      $(el).html(statusMsg);
    }
  }; // this.signalAjaxResponse()
  
  this.toggleCollapsible = function(el, doExpand) {
    var ariaControls = getAriaControlTargets(el),
        ariaExpanded = el.attributes['aria-expanded'],
        isExpanded = ariaExpanded.value;
    if ( ariaExpanded !== undefined ) {
      var isCollapsed = isExpanded === 'true' ? 'false' : 'true';
      //console.log('Expand? '+doExpand);
      //console.log('Already expanded? '+isExpanded);
      if ( doExpand !== isExpanded ) {
        if ( isCollapsed === 'true' ) {
          // this.updateControlTargets( function(target) { ... });
          ariaControls.forEach( function(target) {
            that.showBlock(target);
          })
          ariaExpanded.value = 'true';
        } else {
          ariaControls.forEach( function(target) {
            that.hideBlock(target);
          })
          ariaExpanded.value = 'false';
        }
      }
    }
  }; // this.toggleCollapsible()
  
  this.toggleCollapsibleEvent = function(event) {
    var el = event['target'];
    this.toggleCollapsible(el);
  }; // this.toggleCollapsibleEvent()
  
  this.updateControlTargets = function(el, callback) {
    var defaultCallback = function(target) {
          console.warn("No callback function provided to "
            + "bibjs.a11y.updateControlTargets().");
          console.log(target);
        },
        ariaControls = getAriaControlTargets(el),
        callback = callback ? callback : defaultCallback;
    ariaControls.forEach(callback);
  }; // this.updateControlTargets()
  
}).apply(bibjs.a11y); // Apply the namespace to the anonymous function.
