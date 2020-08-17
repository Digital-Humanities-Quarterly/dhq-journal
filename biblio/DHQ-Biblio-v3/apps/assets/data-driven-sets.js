// Data-driven document sets

// Set up namespace for DHQ functions
var bibjs = bibjs || {};
bibjs.d3set = {};


// Create an anonymous function to hold functions to be namespaced.
(function() {
  /* Capture the current context so these functions can refer to themselves even 
    when the context changes. */
  var that = this;
  
  var dragEvent = d3.drag().subject( function() {
    return d3.select(this.parentNode).datum();
  });
  
  /*** Private functions ***/
  
  var addMemberRef = function(selection, setName) {
    selection.select('.set-member-refs')
        .style('display', null)
        .classed('set-member-refs-empty', false)
      .select('ul')
      .append('li')
        .classed('set-ref', true)
        .text(setName);
  }; // addMemberRef()
  
  var getKeyedMembers = function(key) {
    return d3.selectAll('.set-member')
      .filter( function(d) {
        return key !== undefined ? d['value'] === key : true;
      });
  }; // getKeyedMembers()
  
  var getSetContainer = function(el) {
    var isContainer,
        container = null;
    if ( el !== null ) {
      isContainer = d3.select(el).classed('set-container');
      container = isContainer ? el : getSetContainer(el.parentElement);
    }
    return container;
  }; // getSetContainer()
  
  
  var getSetReferences = function(key) {
    var refs = d3.selectAll('.set-ref');
    if ( key ) {
      refs = refs.filter( function() {
        return this.textContent === key;
      });
    }
    return refs;
  }; // getSetReferences()
  
  
  var isDroppableTarget = function(el, dropRef) {
    var elExists = el !== undefined && el !== null,
        existingMember = d3.select(el)
          .selectAll('.set-member')
          .filter( function(d) { return d['value'] === dropRef; });
    return elExists && existingMember.size() === 0;
  }; // isDroppableTarget()
  
  
  var testDraggingKeydown = function(d) {
    //console.log(d3.event);
    var keydownCode = d3.event.keyCode;
    if ( keydownCode === 27 ) {
      // Escape: reset focus, tear down drag event
      
    } else if ( keydownCode === 32 || keydownCode === 13 ) {
      // Space or Enter: check the current selection, tear down event
      var selection = d3.select(this),
          targetSet = d3.event.target,
          handle = document.querySelector('.drag-handle[aria-selected="true"]');
      d3.event.preventDefault();
      selection.attr('aria-checked', 'true');
      d3.selectAll('.kbd-instructions')
          .style('display', 'none');
      d3.customEvent(new Event('kbddragged'), that.dragTearDownEvent, handle);
    }
  }; // testDraggingKeydown()
  
  
  
  /*** Public functions ***/
  
  /* Given a d3 selection of elements with `@data-key` attributes, assign each 
    element with data matching the value of its key. */
  this.bindDataByKey = function(keyedSelection, array) {
    keyedSelection.data(array, function(d) {
      var key = d ? d.value : this.dataset['key'];
      if ( !d ) { key = that.expandHtmlEntities(key); }
      return key;
    });
  }; // this.bindDataByKey()
  
  
  /* Prepare the DOM for the current drag event. */
  this.dragInitEvent = function(/*el, clicked*/) {
    console.log(d3.event);
    var handle = d3.select(this),
        setsGrid = d3.select(document.getElementById('sets')),
        setContainers = setsGrid.selectAll('.set-container'),
        setMembers = setContainers.selectAll('.set-member');
    console.log("Begin drag event.");
    handle.attr('aria-selected', 'true');
    setsGrid.classed('dragging', true)
        .attr('aria-role', 'radiogroup');
    setContainers.attr('aria-role', 'radio')
        .attr('aria-checked', 'false')
        .attr('aria-label', function(d) {
          return "Container '" + d['name'] + "': drop here";
        })
        .attr('tabindex', 0)
        .on('keydown', testDraggingKeydown)
      .select('.handle')
        .attr('tabindex', -1);
    setMembers.selectAll('input.membership-flag, button.drag-handle:not([aria-selected="true"])')
        .attr('tabindex', -1);
    if ( d3.event.type === 'click' ) {
      d3.selectAll('.kbd-instructions')
          .style('display', null);
      handle.on('kbddragged', that.dragTearDownEvent);
    } else {
      d3.event.on('start drag', that.dragMouseEvent);
    }
  }; // this.dragInitEvent()
  
  
  /* During a 'drag' event, move the selected button alongside the mouse cursor. 
    When the button is dropped, clone its parent set member to the target set. */
  this.dragMouseEvent = function() {
    var el = d3.select(this),
        pageCoords = d3.mouse(document.querySelector('body')),
        x = pageCoords[0] + 2,
        y = pageCoords[1] + 2;
    // Move the dragged element alongside the mouse.
    el.style('position', 'absolute')
        .style('top', y)
        .style('left', x);
    // When the drag event stops, remove special styling.
    d3.event.on('end', that.dragTearDownEvent);
  }; // this.dragMouseEvent()
  
  
  /* When the drag event has concluded with a drop, remove affordances and styling. 
    If applicable, add a clone of the initiating set member to the drop target. */
  this.dragTearDownEvent = function() {
    var el = d3.select(this),
        setsGrid = d3.select(document.getElementById('sets')),
        newContainer = getSetContainer(d3.event.sourceEvent.target),
        valDatum = d3.event.subject;
    // Reset styling specific to a traditional mouse-driven drag event.
    if ( d3.event.type !== 'kbddragged' ) {
      el.classed('dragging', false)
          .style('position', null)
          .style('top', null)
          .style('left', null);
    }
    /* Reset styles and ARIA attributes which were set during that.dragInitEvent(). */
    el.attr('aria-selected', 'false');
    setsGrid.attr('aria-role', null)
        .classed('dragging', false);
    setsGrid.selectAll('.set-container')
        .attr('aria-role', null)
        .attr('aria-checked', null)
        .attr('aria-label', null)
        .attr('tabindex', null)
        .on('keydown', null)
      .select('.handle')
        .attr('tabindex', null);
    setsGrid.selectAll('.set-member')
      .selectAll('input.membership-flag, button.drag-handle:not([aria-selected="true"])')
        .attr('tabindex', null);
    valDatum = valDatum ? valDatum : d3.select(this.parentNode).datum();
    /* If the element is dropped onto a "set"-classed node, add the selection's 
      clone to the proposed set. */
    if ( isDroppableTarget(newContainer, valDatum['value']) ) {
      var setMember = d3.select(this.parentNode.cloneNode(true)),
          origSet = getSetContainer(this),
          origSetName = origSet.dataset['set'],
          setName = newContainer.dataset['set'],
          setId = newContainer.dataset['setId'];
      d3.select(origSet)
        .selectAll('.membership-flag:checked')
          .property('checked', false);
      newContainer = d3.select(newContainer);
      /* Add a reference to the new set to existing set members matching this value. */
      getKeyedMembers(valDatum['value'])
          .call(addMemberRef, setName);
      /* The cloned member needs a reference to the set from which it was cloned. */
      setMember = newContainer.select('.set-member-group')
        .append( function(d) {
          var newMember;
          setMember.datum(valDatum)
              .call(addMemberRef, origSetName)
            .select('input.membership-flag')
              .property('checked', false)
              .attr('name', setId+'-members[]')
              .on('change', that.toggleMembershipFlag);
          newMember = setMember.node();
          newMember.dataset['setRef'] = setName;
          return newMember;
        });
      setMember.datum(valDatum);
      that.initializeSetMembers(setMember);
      setMember.select('input.membership-flag')
          .property('checked', true)
          .dispatch('change');
    }
    console.log("End drag event.");
  }; // this.dragTearDownEvent()
  
  
  /*  */
  this.expandHtmlEntities = function(str) {
    var ampRegex = /&/g,
        str = str ? str : '';
    return str.replace(ampRegex, '&amp;');
  }; // this.expandHtmlEntities()
  
  
  /* Define event handlers for manipulating the members of sets. */
  this.initializeSetMembers = function(selection) {
    selection.select('input[type="checkbox"].membership-flag')
        .on('change', this.toggleMembershipFlag);
    // Define the drag event.
    selection.select('.drag-handle')
        .call(dragEvent.on('start', that.dragInitEvent))
        .on('click', that.dragInitEvent);
  }; // this.initializeSetMembers()
  
  
  /* Bind data to set containers, and define event handlers for set identity 
    purposes. */
  this.initializeSets = function(selection, bibjsData) {
    var setsData = bibjsData['sets'],
        valKeys;
    if ( setsData !== undefined ) {
      console.log(setsData);
      // Create a d3.map of the existing data.
      // Make sure HTML elements are linked to existing data.
      
    } else {
      console.log("No existing sets found.");
      bibjsData['sets'] = [];
      setsData = bibjsData['sets'];
      // Create the sets data using the HTML data-* attributes.
      selection.filter('*[data-set]')
          .datum( function() {
            var setName = this.dataset['set'],
                thisSet = {};
            d3.select(this)
              .selectAll('.membership-flag:checked')
                .property('checked', false);
            setName = that.expandHtmlEntities(setName);
            thisSet['name'] = setName;
            thisSet['variations'] = [];
            setsData.push(thisSet);
            return thisSet;
          });
      console.log(bibjsData['sets']);
    }
    selection.selectAll('.canonical-flag')
        .property('checked', true);
    // Bind data to the text box as well.
    selection.select('.set-name > .handle')
        .datum(function(d) {
          if ( !d ) { console.warn(this); }
          return d;
        })
        //.property('value', function(d) { return this.defaultValue; })
        /* When the set name changes, update the underlying datum and any references
          to it. */
        .on('change', function(d) {
          var newVal = this.value,
              invalid = /^\s*$/;
          if ( invalid.test(newVal) ) {
            this.value = d['name'];
          } else {
            that.updateSetRefs(d['name'], newVal);
            d['name'] = newVal;
          }
        });
  }; // this.initializeSets()
  
  
  /* Remove all references to a specified set. */
  this.removeSetRefs = function(key) {
    getSetReferences(key)
        .remove();
  }; // this.removeSetRefs()
  
  
  /* Modify the membership state of a given value. When the field value is marked as 
    elonging to a set, it cannot belong to any other and so the other references are 
    disabled and hidden from view. */
  this.toggleMembershipFlag = function(d, i, nodes) {
    var keyedEls, keyedInputs,
        thisMember = this.parentNode.parentNode,
        key = d['value'],
        thisSetName = thisMember.dataset['setRef'],
        thisSet = d3.select('.set-container[data-set="'+thisSetName+'"]'),
        currentMembers = thisSet.datum()['variations'];
    thisMember = d3.select(thisMember);
    //console.log(thisMember.datum());
    key = key !== undefined ? key : thisMember.datum()['value'];
    keyedEls = getKeyedMembers(key)
      .filter( function(d) { 
        return this.dataset['setRef'] !== thisSetName;
      });
    //console.log(keyedEls.size());
    keyedInputs = keyedEls
      .selectAll('input[type="checkbox"].membership-flag, button.drag-handle');
    /* If the current value is a new member of the set, hide references to it 
      elsewhere. */
    if ( this.checked ) {
      currentMembers.push(key);
      thisMember.select('.set-member-refs')
          .style('display', 'none');
      keyedInputs.property('disabled', true);
      thisMember.select('button.drag-handle')
        .property('disabled', true);
    /* If the current value is removed from the set, restore references to it
      elsewhere. */
    } else {
      var useKey = that.expandHtmlEntities(key),
          index = currentMembers.indexOf(useKey);
      if ( index ) { currentMembers.splice(index, 1); }
      thisMember.select('.set-member-refs')
          .style('display', null);
      keyedInputs.property('disabled', false);
      thisMember.select('button.drag-handle')
        .property('disabled', false);
    }
  }; // this.toggleMembershipFlag()
  
  
  /* Update text references to a set with a changed name. */
  this.updateSetRefs = function(key, newKey) {
    getSetReferences(key)
        .text(newKey);
    d3.selectAll('[data-set-ref="'+key+'"]')
        .datum( function(d) {
          this.dataset['setRef'] = newKey;
          return d;
        });
    d3.select('[data-set="'+key+'"]')
        .datum( function(d) {
          this.dataset['set'] = newKey;
          d['name'] = newKey;
          console.log(d);
          return d;
        });
  }; // this.updateSetRefs()
}).apply(bibjs.d3set); // Apply the namespace to the anonymous function.


$(document).ready( function() {
  // If bibjs.data doesn't already exist, create it.
  bibjs.data = bibjs.data || {};
  //console.log(bibjs.data);
  var setsElGroup = d3.selectAll('.set-container'),
      valueInstances = setsElGroup.selectAll('*[data-key]'),
      authForm = d3.select('#authentry');
  // Bind bibjs.data to elements in the DOM, and define event handlers.
  bibjs.d3set.initializeSets(setsElGroup, bibjs.data);
  bibjs.d3set.bindDataByKey(valueInstances, bibjs.data['entries-by-value']);
  bibjs.d3set.initializeSetMembers(valueInstances);
  /* On form submission but before sending the data, add a hidden field containing 
    JSON serialized from the set containers. */
  authForm.on('submit', function() {
    //d3.event.preventDefault();
    var ajaxReqObj,
        postData = JSON.stringify(setsElGroup.data());
    authForm.insert('input', ':first-child')
        .attr('type', 'hidden')
        .attr('name', 'json')
        .property('value', postData);
    /*$.ajax({
      datatype: 'json',
      method: 'POST',
      success: function (fragment, status, xhr) {
        console.log('success!')
      },
      error: function () {
        console.log('Something went wrong!');
      }
    });*/
  });
  
  console.log(authForm);
});
