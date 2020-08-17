// DHQ Biblio + Xonomy

// Set up namespace for DHQ functions
var bibjs = bibjs || {};
bibjs.xonomy = {};

// Create an anonymous function to hold Xonomy-specific functions.
(function() {
  /* Capture the current context so these functions can refer to themselves even 
    when the context changes. */
  var that = this;
  
  /*** Private functions ***/
  
  var getAjaxSettingsBase = function(event) {
    return {
      /* By default, JQuery AJAX requests use the same URL as the current page, 
        which is exactly the correct behavior for saving Biblio XML. */
      method: 'POST',
      complete: function(jxhr, statusStr) {
        var outputStatus = function(target) {
          //console.log(target);
          bibjs.a11y.signalAjaxResponse(target, jxhr, statusStr);
        };
        bibjs.a11y.updateControlTargets(event.target, outputStatus);
      },
      statusCode: {
        // If BaseX requests authorization with custom HTTP code 901:
        901: function(jqxhr) {
          var formEl,
              loginForm = jqxhr.responseText;
          console.log(jqxhr);
          // Create a log in form in a modal.
          bibjs.modal.makePerceivableModal(loginForm, event);
          formEl = document.getElementById('login-form');
          /* Intercept the form submission event so the user doesn't leave the 
            current page. Use AJAX for the request instead. */
          $(formEl).submit( function(e) {
            e.preventDefault();
            var form = e.target,
                params = $(form).serialize();
            $.ajax({
              url: bibjs.baseUrl+'biblio-qa/login',
              data: params,
              method: 'POST',
              success: function() {
                // If the user logged in, make the modal inactive.
                bibjs.modal.tearDownModal(event);
              }
            });
          });
        }
      }
    }
  };
  
  var getFormTargetUrl = function(event) {
    return event.target.parentElement.getAttribute('action');
  };
  
  var getSurrogate = function (htmlid) {
    var el = document.getElementById(htmlid);
    return Xonomy.harvestElement(el);
  }; // getSurrogate()
  
  /* Create a form for modifying a BiblioItem's identifier. This can be used to 
    replace a <BiblioItem>-classed element with a <biblioRef>, or to ensure that an 
    item's `@ID` is unique. */
  var idAttrAsker = function (value, askerParams, surrogate) {
    var html, menuList,
        datasetName = "'biblio-ids'",
        escapedVal = Xonomy.xmlEscape(value),
        isIdref = askerParams['type'] === 'idref',
        submitEvent = 'Xonomy.answer(this.val.value);',
        isSubmissible = isIdref ? '' : '!';
    isSubmissible += 'bibjs.data['+datasetName+'].includes(this.val.value)';
    if ( isIdref ) {
      var parentId = surrogate.parent()['htmlID'];
      //console.log(parentId);
      submitEvent = 'bibjs.xonomy.replaceWithBiblioRef('+"'"+ parentId + "'"
        + ', this.val.value);';
    }
    html =
      '<form class="overmenu flex" onsubmit="event.preventDefault(); '
        + 'if ( '+ isSubmissible +' ) '
          + '{ '+ submitEvent + '} '
        + 'return false;">'
      + '<label>'
        + 'Entry identifier: '
        + '<input name="val" class="textbox focusme" '
          + 'value="'+escapedVal+'" />'
      + '</label> '
      + '<button class="search-btn" aria-label="Search"'
        + 'onclick="event.preventDefault(); ' 
        + '$('+"'#xonomyBubble .menu'"+').replaceWith( '
          + 'bibjs.xonomy.makeDataValuesMenu('
            + 'bibjs.data['+datasetName+'], this.form.val.value, '
            + !isIdref
        + '));">&nbsp;</button>'
      + '<button type="submit">OK</button>'
    + '</form>';
    menuList = bibjs.data['biblio-ids'];
    if ( menuList ) {
      html +=  that.makeDataValuesMenu(menuList, value);
    } else {
      html += Xonomy.wyc(bibjs.baseUrl+'biblio-qa/mint', function(list) {
        bibjs.data['biblio-ids'] = list;
        return that.makeDataValuesMenu(list, value, !isIdref);
      });
    }
    return html;
  }; // idAttrAsker()
  
  /* Determine if a given surrogate object has been marked as a duplicate. */
  var isDuplicate = function(jsNode, ifNull = false) {
    var jsEl = jsNode.type === 'element' ? jsNode : jsNode.parent(),
        dupCheck = jsEl.getAttributeValue('duplicate-id', null);
    return dupCheck || ifNull;
  }; // isDuplicate()
  
  /* Determine if a surrogate object has text characters which are not whitespace. */
  var isNotWhitespaceOnlyText = function (jsEl) {
    var type = jsEl.type,
        nonspace = /\S/m;
    if ( type !== 'text' )
      return false;
    return nonspace.test(jsEl.value);
  }; // isNotWhitespaceOnlyText()
  
  
  /*** Public functions ***/
  
  this.askIdPicklist = function(htmlid, params) {
    var popupContent, useHtmlId,
        surrogate = getSurrogate(htmlid),
        surrogateType = surrogate.type,
        askerParam = params || { 'type': 'id' };
    if ( surrogateType == 'element' ) {
      if ( surrogate.hasAttribute('ID') ) {
        console.log("ID");
        surrogate = surrogate.getAttribute('ID');
      } else if ( surrogate.hasAttribute('key') ) {
        surrogate = surrogate.getAttribute('key');
      } else {
        console.warn("Could not find an ID/IDREF attribute on "+htmlid);
      }
    }
    useHtmlId = surrogate['htmlID'];
    popupContent = idAttrAsker(surrogate.value, askerParam, surrogate);
    // Create an Xonomy-flavored popup, anchored to the clicked @ID.
    document.body.appendChild(Xonomy.makeBubble(popupContent));
    Xonomy.showBubble($('#'+useHtmlId+' > .valueContainer > .value'));
    Xonomy.answer = function(val) {
      $('#xonomyBubble form input.textbox').val(val);
    };
    //console.log(popupContent);
  }; // this.askIdPicklist()
  
  this.clearTextChildren = function (htmlid) {
    var surrogate = getSurrogate(htmlid);
    console.log(surrogate.children);
    surrogate.children.forEach(function (child, index, arr) {
      if ( child.type === 'text' /*&& isNotWhitespaceOnlyText(child)*/ ) {
        child.value = '';
        arr[index] = child;
      }
    });
    Xonomy.replace(htmlid, surrogate);
  }; // this.clearTextChildren()
  
  this.deleteChildren = function(htmlid) {
    var surrogate = getSurrogate(htmlid);
    surrogate.children = [];
    Xonomy.replace(htmlid, surrogate);
  }; // this.deleteChildren()
  
  this.getCorrespHtmlElement = function(xmlid) {
    var htmlid = null,
        htmlEl = $('.xonomy .attribute[data-name="ID"][data-value="'+xmlid+'"]');
    if ( htmlEl.length > 0 ) {
      htmlEl = htmlEl[0];
    } else {
      htmlEl = null;
    }
    return htmlEl;
  }; // this.getCorrespHtmlElement()
  
  this.getCorrespHtmlId = function(xmlid) {
    var htmlid = null,
        htmlEl = this.getCorrespHtmlElement(xmlid);
    if ( htmlEl ) {
      htmlid = htmlEl.id;
    }
    return htmlid;
  }; // this.getCorrespHtmlId()
  
  this.elementsByClass = function() {
    return {
      "ElSpec": [
        "etal",
        "givenName",
        "familyName",
        "fullName",
        "corporateName",
        "username",
        "volume",
        "issue",
        "place",
        "publisher",
        "archive",
        "date",
        "startingPage",
        "endingPage",
        "totalPages",
        "runningTime",
        "url",
        "note"
       ],
      "BiblioItem": [
        "Other",
        "ArchivalItem",
        "Artwork",
        "BlogEntry",
        "Book",
        "BookInSeries",
        "BookSection",
        "ConferencePaper",
        "JournalArticle",
        "PhysicalMedia",
        "Posting",
        "PublicGov",
        "Report",
        "Series",
        "Thesis",
        "VideoGame",
        "WebSite"
       ],
      "Title": [
        "title",
        "additionalTitle"
       ],
      "SearchableField": [
        "formalID"
       ],
      "Contributor": [
        "author",
        "editor",
        "translator",
        "creator"
       ],
      "MacroItem": [
        "book",
        "series",
        "conference",
        "journal",
        "publication"
       ],
       "BiblioRef": [
         "biblioRef"
       ]
    };
  }; // this.elementsByClass()
  
  this.harvestNamespacedElement = function (htmlid) {
    var surrogate = getSurrogate(htmlid),
        /* Just getting an Xonomy surrogate isn't enough here, because we don't want 
          the namespace to be visible in the editor. Instead, jQuery's function 
          extend() creates a deep copy of the surrogate. The copy can then be 
          augmented with the namespace before being harvested. */
        copy = $.extend(true, {}, surrogate);
    // The following was copied with slight modifications from Xonomy.harvest():
    for (var ns in Xonomy.namespaces) {
      if ( !copy.hasAttribute(ns) ) copy.attributes.push({
        type: 'attribute',
        name: ns,
        value: Xonomy.namespaces[ns],
        parent: copy
      });
    }
    return Xonomy.js2xml(copy);
  }; // this.harvestNamespacedElement()
  
  this.hasNonspacingText = function (htmlid) {
    var surrogate = getSurrogate(htmlid);
    return surrogate.children.some(isNotWhitespaceOnlyText);
  }; // this.hasNonspacingText()
  
  this.makeDataValuesMenu = function (list, value, disableClick=false) {
    var pickerMenu, pickerMenuEl,
        regexible = /([\^\$\.\[\]\(\)\?\*\+\\])/
        regexibleVal = value.replace(regexible, '\$1'),
        onClickFnDefault = new RegExp('Xonomy\.answer', 'gm'),
        onClickFnReplacement = '\$\("#xonomyBubbleContent form input\.textbox"\).val';
    list = !value ? list : list.filter( function(item) {
      return item.includes(value);
    });
    pickerHtmlStr = Xonomy.pickerMenu(list, value);
    /* If the menu options are only there as reference, not for picking, then remove 
      the onclick event. */
    if ( disableClick ) {
      pickerMenuEl = $(pickerHtmlStr);
      pickerMenuEl = pickerMenuEl.find('.menuItem')
          .removeAttr('onclick')
          .removeAttr('tabindex')
          .addClass('menuItem-disabled')
          .end();
      pickerHtmlStr = pickerMenuEl[0].outerHTML;
    } else {
      /* Make sure Xonomy's pickerMenu does not apply the clicked value as an edit. 
        Instead, use that value to populate the form input. */
      pickerHtmlStr = pickerHtmlStr.replace(onClickFnDefault, onClickFnReplacement);
    }
    return pickerHtmlStr;
  }; // this.makeDataValuesMenu()
  
  this.renameElement = function (htmlid, param) {
    var surrogate = getSurrogate(htmlid);
    surrogate.name = param;
    Xonomy.replace(htmlid, surrogate);
  }; // this.renameElement()
  
  this.replaceWithBiblioRef = function(htmlid, idref) {
    var surrogate = getSurrogate(htmlid),
        useId = idref ? idref : surrogate.getAttribute('ID').value;
    // Request a new <biblioRef> which should replace the BiblioItem.
    $.ajax({
      url: bibjs.baseUrl+'biblio-qa/workbench/record/'+useId+'/reference',
      success: function(biblioref) {
        var bibRef = biblioref.children[0].outerHTML;
        Xonomy.newElementBefore(htmlid, bibRef);
        Xonomy.deleteElement(htmlid);
      }
    }).done( function() {
      Xonomy.changed();
    });
    console.log(useId);
  }; // this.replaceWithBiblioRef()
  
  this.rearrangeData = function(event) {
    event.preventDefault();
    var xml = Xonomy.harvest(),
        url = event.target.parentElement.getAttribute('action'),
        ajaxSettings = getAjaxSettingsBase(event);
    ajaxSettings['url'] = url;
    ajaxSettings['data'] = xml;
    //console.log(xml);
    $.ajax(ajaxSettings).done(that.rerenderEditor);
  }; // this.rearrangeData()
  
  /* Replace the contents of the Xonomy editor. */
  this.rerenderEditor = function(data) {
    console.log(data);
    var editor =  document.getElementById('xonomy-editor');
    /* Disable the editor. */
    /* Tell Xonomy to render the editor again. */
    Xonomy.render(data, editor, new that.DocSpec);
  };
  
  this.saveAndHarvestXml = function(event) {
    event.preventDefault();
    var xml = Xonomy.harvest(),
        //setName = document.getElementById('set-name').getAttribute('value'),
        ajaxSettings = getAjaxSettingsBase(event);
    ajaxSettings['url'] = getFormTargetUrl(event);
    ajaxSettings['data'] = xml;
    console.log(ajaxSettings);
    $.ajax(ajaxSettings).done(that.rerenderEditor);
  }; // this.saveAndHarvestXml()
  
  this.saveAsPublicXml = function(event) {
    event.preventDefault();
    var xml = Xonomy.harvest(),
        ajaxSettings = getAjaxSettingsBase(event);
    ajaxSettings['data'] = xml;
    ajaxSettings['dataType'] = 'html';
    ajaxSettings['url'] = getFormTargetUrl(event);
    $.ajax(ajaxSettings).done(that.shareValidationResults);
  }; // this.saveAsPublicXml()
  
  /* Without navigating away from the current page, harvest the workbench XML and 
    ask BaseX to save it. */
  this.saveXml = function(event) {
    event.preventDefault();
    var xml = Xonomy.harvest(),
        ajaxSettings = getAjaxSettingsBase(event);
    ajaxSettings['data'] = xml;
    ajaxSettings['dataType'] = 'html';
    ajaxSettings['processData'] = false;
    ajaxSettings['contentType'] = 'text/xml; charset=UTF-8';
    //console.log(xml);
    $.ajax(ajaxSettings);
  }; // this.saveXml()
  
  /*  */
  this.shareValidationResults = function(data) {
    document.getElementById('validation-results').innerHTML = data;
  }; // this.shareValidationResults()
  
  /*  */
  this.validateXml = function(event) {
    event.preventDefault();
    var xml = Xonomy.harvest(),
        editor = document.getElementById('xonomy-editor'),
        ajaxSettings = getAjaxSettingsBase(event);
    ajaxSettings['data'] = xml;
    ajaxSettings['url'] = getFormTargetUrl(event);
    $.ajax(ajaxSettings).done(that.shareValidationResults);
  }; // this.validateXml()
  
  
  /*** Class definitions ***/
  
  this.SubMenuElementOption = class {
    constructor (gi, applyProperties) {
      var giProps = applyProperties(gi);
      this.caption = gi;
      this.action = giProps['action'] || function() { return; };
      this.actionParameter = giProps['actionParameter'] || {};
      this.hideIf = giProps['hideIf'] || function() { return false; };
      return this;
    }
  }; // end SubMenuElementOption class
  
  this.ComplexMenu = class {
    constructor (optArray, caption) {
      this.caption = caption || '';
      this.expanded = false;
      this.menu = optArray.length >= 1 ? this.insertElementOptions(optArray) : [];
    }
    
    // The generic function applyProperties() is a no-op.
    applyProperties (opt) {
      return {};
    }
    
    insertElementOptions (optArray) {
      var opts = [];
      for (var n = 0; n < optArray.length; n++) {
        var optValue = optArray[n],
            newOpt = new that.SubMenuElementOption(optValue, this.applyProperties);
        opts.push(newOpt);
      }
      return opts;
    }
  }; // end ComplexMenu class
  
  this.InlineWrapMenu = class extends this.ComplexMenu {
    applyProperties(gi) {
      return {
          action: Xonomy.wrap,
          actionParameter: {
            template: "<"+gi+">$</"+gi+">",
            placeholder: "$"
          }
        };
    }
  }; // end InlineWrapMenu class
  
  this.NewChildMenu = class extends this.ComplexMenu {
    applyProperties (gi) {
      return {
          action: Xonomy.newElementChild,
          actionParameter: "<"+gi+"> </"+gi+">",
          hideIf: function (jsEl) {
            return jsEl.hasChildElement(gi);
          }
        };
    }
  }; // end NewChildMenu class
  
  this.ChangeGiMenu = class extends this.ComplexMenu {
    applyProperties (gi) {
      return {
          action: that.renameElement,
          actionParameter: gi,
          hideIf: function (jsEl) {
            return jsEl.name === gi;
          }
        };
    }
  }; // end ChangeGenreMenu class
  
  this.ElSpec = class {
    constructor () {
      // Define defaults for element specification classes.
      this.actions = []; // used to populate the menu getter function
      this.attributes = {};
      var elClasses = that.elementsByClass(),
          itemGenres = elClasses['BiblioItem'],
          macroGenres = elClasses['MacroItem'],
          dropList = ['BiblioItem', 'macroItem'];
      dropList = dropList.concat(macroGenres, itemGenres);
      this.canDropTo = dropList;
      this.caption = function(jsEl) { return ''; };
      this.localDropOnly = false;
      this.hasText = true;
      this.oneliner = true;
      this.validate = function(jsEl) {
        // Use the value of @validation-message as an Xonomy warning.
        if ( jsEl.hasAttribute('validation-message') ) {
          Xonomy.warnings.push({
            htmlID: jsEl.htmlID,
            text: jsEl.getAttributeValue('validation-message')
          })
        }
      }
    }
    
    get menu() {
      var standardActions = [
        {
          caption: "Remove tags",
          action: Xonomy.unwrap
        },{
          caption: "Add language attribute",
          action: Xonomy.newAttribute,
          actionParameter: 
            { name: 'xml:lang', value: '' },
          hideIf: function (jsEl) {
            return jsEl.hasAttribute('xml:lang');
          }
        }];
      return this.actions.concat(standardActions);
    }
    
    get inlineMenu() {
      return [];
    }
    
    get elSpec() {
      var spec,
          attrGlobalPlus = this.attributes;
      attrGlobalPlus['xml:lang'] = {
        asker: Xonomy.askOpenPicklist,
        askerParameter: [ /* ISO 639-1 codes */
          { value: 'en', caption: 'English' },
          { value: 'nl', caption: 'Dutch, Flemish' },
          { value: 'fi', caption: 'Finnish' },
          { value: 'fr', caption: 'French' },
          { value: 'de', caption: 'German' },
          { value: 'el', caption: 'Greek, Modern' },
          { value: 'it', caption: 'Italian' },
          { value: 'ja', caption: 'Japanese' },
          { value: 'la', caption: 'Latin' },
          { value: 'es', caption: 'Spanish' }
        ]
      };
      attrGlobalPlus['validation-message'] = {
        isInvisible: true
      };
      spec = {
        attributes: attrGlobalPlus,
        canDropTo: this.canDropTo,
        caption: this.caption,
        hasText: this.hasText,
        inlineMenu: this.inlineMenu,
        localDropOnly: this.localDropOnly,
        menu: this.menu,
        oneliner: this.oneliner,
        validate: this.validate
      };
      return spec;
    }
  }; // end ElSpec class
  
  this.BiblioItem = class extends this.ElSpec {
    constructor () {
      super();
      var insertMacro,
          elClasses = that.elementsByClass(),
          itemGenres = elClasses['BiblioItem'],
          macroGenres = Array.from(elClasses['MacroItem']);
      /* <biblioRef> is allowed as an alternative to a macroItem, and it should have 
        @key already on it. */
      insertMacro = new that.NewChildMenu(macroGenres, "Insert macro item");
      insertMacro.menu.push({
          caption: 'biblioRef',
          action: Xonomy.newElementChild,
          actionParameter: "<biblioRef key=''> </biblioRef>",
          hideIf: function (jsEl) {
            return jsEl.hasChildElement('biblioRef');
          }
        });
        
      this.actions = [{
          caption: "Add @ID",
          action: Xonomy.newAttribute,
          actionParameter: 
            { name: 'ID', value: '' },
          hideIf: function (jsEl) {
            return jsEl.hasAttribute('ID');
          }
        },{
          caption: "Add URL",
          action: Xonomy.newElementChild,
          actionParameter: "<url></url>"
        },{
          caption: "Add note",
          action: Xonomy.newElementChild,
          actionParameter: "<note></note>"
        },
        insertMacro
      ];
      //this.actions.push(insertMacro);
      this.attributes = {
          'ID': {
            asker: idAttrAsker,
            askerParameter: { 'type': 'id' },
            /* If the ID value has been flagged as a duplicate, fire off a 
              validation warning. */
            validate: function(jsAttr) {
              var currentID,
                  isDup = isDuplicate(jsAttr);
              if ( isDup ) {
                currentID = jsAttr.parent().getAttributeValue('ID', '');
                Xonomy.warnings.push({
                  htmlID: jsAttr.htmlID,
                  text: "ID “"+currentID+"” matches existing item: "+isDup
                });
              }
            },
            menu: [{
              caption: "Mark entry as duplicate",
              action: that.askIdPicklist,
              actionParameter: { 'type': 'idref' }
            },{
              caption: "Edit existing entry",
              // TODO: open a window for editing the existing entry
              hideIf: function(jsAttr) {
                return !isDuplicate(jsAttr);
              }
            }]
          },
          'dhqID': { isReadOnly: true },
          'issuance': {
            asker: Xonomy.askPicklist,
            askerParameter: [
              { value: 'monographic', caption: '' },
              { value: 'continuing', caption: '' }
            ]
          },
          'duplicate-id': { isInvisible: true }
        };
      this.canDropTo = ['BiblioSet'];
      this.hasText = false;
      this.inlineOpts = elClasses['Contributor'].concat(
        elClasses['Title'], elClasses['ElSpec'], elClasses['SearchableField']
      );
      this.oneliner = false;
      this.reclassOpts = itemGenres;
    }
    
    get menu() {
      var standardActions, reclassifyMenu;
      reclassifyMenu = new that.ChangeGiMenu(this.reclassOpts, "Change genre");
      standardActions = [{
          caption: "Add issuance attribute",
          action: Xonomy.newAttribute,
          actionParameter: 
            { name: 'issuance', value: '' },
          hideIf: function (jsEl) {
            return jsEl.hasAttribute('issuance');
          }
        },{
          caption: "Remove text children",
          action: that.clearTextChildren,
          hideIf: function (jsEl) {
            var actionNeeded = that.hasNonspacingText(jsEl.htmlID);
            //console.log(actionNeeded);
            return !actionNeeded;
          }
        },
        reclassifyMenu,
        {
          caption: "Mark entry as duplicate",
          action: that.askIdPicklist,
          actionParameter: { 'type': 'idref' }
        },{
          caption: "Delete element",
          action: Xonomy.deleteElement
        }
      ];
      return this.actions.concat(standardActions);
    }
    
    get inlineMenu() {
      var wrapMenu,
          inlineMenu = [];
      wrapMenu = new that.InlineWrapMenu(this.inlineOpts, "Wrap");
      inlineMenu.push(wrapMenu);
      return inlineMenu;
    }
  }; // end BiblioItem class
  
  this.MacroItem = class extends this.BiblioItem {
    constructor () {
      super();
      var elClasses = that.elementsByClass(),
          itemGenres = elClasses['BiblioItem'],
          macroGenres = elClasses['MacroItem'];
      this.actions = [];
      this.canDropTo = ['BiblioItem'].concat(itemGenres);
      this.reclassOpts = macroGenres;
    }
  }; // end MacroItem class
  
  this.BiblioRef = class extends this.ElSpec {
    constructor () {
      super();
      var elClasses = that.elementsByClass(),
          itemGenres = elClasses['BiblioItem'];
      this.canDropTo = ['BiblioSet','BiblioItem'].concat(itemGenres);
      this.attributes = {
        'key': {
          asker: idAttrAsker,
          askerParameter: { 'type': 'idref' },
          /* If the ID value has been flagged as a duplicate, fire off a 
            validation warning. */
          validate: function(jsAttr) {
            var currentIDREF,
                isDup = isDuplicate(jsAttr, true);
            if ( isDup !== true ) {
              currentIDREF = jsAttr.parent().getAttributeValue('key', '');
              Xonomy.warnings.push({
                htmlID: jsAttr.htmlID,
                text: "Key “"+currentIDREF+"” does not match an existing Biblio item."
              });
            }
          }
        },
        'duplicate-id': { isInvisible: true }
      };
      //console.log(this);
    }
    
    get menu() {
      var standardActions = [{
          caption: "Edit key",
          action: that.askIdPicklist,
          actionParameter: { 'type': 'idref' }
        },{
          caption: "Delete element",
          action: Xonomy.deleteElement
        }];
      return this.actions.concat(standardActions);
    }
  }; // end BiblioRef class
  
  this.SearchableField = class extends this.ElSpec {
    constructor () {
      super();
      this.actions = [{
        caption: "Search Biblio for matches",
        action: function(htmlid) {
          Xonomy.clickoff();
          var jsEl = getSurrogate(htmlid),
              params = { fields: 'citation' },
              field = jsEl.name;
          params[field] = jsEl.getText();
          bibjs.search.requestBiblioResults(params);
        }
      }];
      this.inlineOpts = [];
      this.reclassOpts = [];
    }
    
    get menu() {
      var reclassifyMenu,
          inheritedMenu = super.menu;
      if ( this.reclassOpts.length > 0 ) {
        reclassifyMenu = new that.ChangeGiMenu(this.reclassOpts, "Change tag name");
        inheritedMenu.push(reclassifyMenu);
      }
      return inheritedMenu;
    }
    
    get inlineMenu() {
      if ( this.inlineOpts.length <= 0 ) {
        return undefined;
      }
      var wrapMenu,
          inlineMenu = [];
      wrapMenu = new that.InlineWrapMenu(this.inlineOpts, "Wrap");
      inlineMenu.push(wrapMenu);
      return inlineMenu;
    }
  }; // end SearchableField class
  
  this.Contributor = class extends this.SearchableField {
    constructor () {
      super();
      var contribTypes = that.elementsByClass()['Contributor'],
          contribActions = [{
            caption: 'Add "et al." marker',
            action: Xonomy.newElementAfter,
            actionParameter: '<etal />',
            hideIf: function(jsEl) {
              var nextNode = jsEl.getFollowingSibling();
              return nextNode.type === 'text' 
                  || contribTypes.indexOf(nextNode.name) !== -1;
            }
          },{
            caption: "Remove text children",
            action: that.clearTextChildren,
            hideIf: function (jsEl) {
              var actionNeeded = that.hasNonspacingText(jsEl.htmlID);
              console.log(actionNeeded);
              return !actionNeeded;
            }
          }];
      this.actions = contribActions.concat(this.actions);
      this.caption = function(jsEl) {
        var cap = '',
            lastNode = jsEl.getPrecedingSibling();
        if ( lastNode === null ) {
          cap = "Primary contributor";
        }
        return cap;
      };
      this.inlineOpts = ['givenName', 'familyName', 'fullName', 'corporateName', 'username'];
      this.oneliner = false;
      this.hasText = false;
      this.reclassOpts = contribTypes;
      this.validate = function (jsEl) {
        var hID = jsEl.htmlID,
            gi = jsEl.name;
        if ( that.hasNonspacingText(hID) ) {
          Xonomy.warnings.push({
            htmlID: hID,
            text: "There should be no text content of "+gi
          })
        }
      }
    }
  }; // end Contributor class
  
  this.Title = class extends this.SearchableField {
    constructor () {
      super();
      this.inlineOpts = ['i', 'q'];
      this.reclassOpts = ['title', 'additionalTitle'];
    }
  }; // end Title class
  
  
  this.DocSpec = class {
    constructor() {
      var genItem = new that.BiblioItem,
          macroItem = new that.MacroItem,
          searchableField = new that.SearchableField,
          isSetReady = function(jsEl) {
            return jsEl.getAttributeValue('ready', false);
          };
      // Set the properties for generic Biblio elements.
      var elObj = {
        'BiblioSet': { 
          'hasText': false,
          'backgroundColour': '#e2f3f9',
          'caption': function(jsEl) {
            var cap = '';
            if ( isSetReady(jsEl) ) {
              cap = "<span class='caption-instructive'>Drop finished entries here!</span>";
            }
            return cap;
          },
          'collapsoid': function(jsEl) {
            var collapseBox = '';
            if ( isSetReady(jsEl) ) {
              collapseBox = collapseBox + '';
            }
            collapseBox = collapseBox /*+ ' TEST '*/;
            return collapseBox;
          },
          'menu': []
        },
        'BiblioItem': genItem.elSpec,
        'macroItem': macroItem.elSpec
      };
      // Programmatically create new class objects for Biblio elements.
      var elList = that.elementsByClass(),
          classes = Object.keys(elList);
      //console.log(classes);
      classes.forEach( function(className) {
        var members = elList[className];
        //console.log(className);
        members.forEach( function(gi) {
          var instantiation =  new bibjs.xonomy[className]();
          elObj[gi] = instantiation.elSpec;
        }, this);
      });
      this.elSpec = elObj;
      return this.docSpec;
    }
    
    get docSpec() {
      var validation,
          elSpec = this.elSpec;
      validation = function(jsEl) {
        // Validate the top-level element.
        var myGi = jsEl.name,
            mySpec = elSpec[myGi],
            myAttrs = jsEl.attributes,
            myChildren = jsEl.children;
        
        if ( mySpec ) {
          if ( mySpec.validate ) { 
            mySpec.validate(jsEl);
          }
          /* Validate the element's attributes. Since attributes are defined per 
            element specification, if an element has no specification, its 
            attributes can't be validated. */
          var myAttrsSpec = mySpec.attributes;
          for (var i = 0; i < myAttrs.length; i++ ) {
            var jsAttr = myAttrs[i],
                attrSpec = myAttrsSpec ? myAttrsSpec[jsAttr.name] : undefined;
            if ( myAttrsSpec && attrSpec && attrSpec.validate ) {
              attrSpec.validate(jsAttr);
            }
          }
        } else {
          console.log("No validation function for "+myGi)
        }
        // Validate the element's children (recursing).
        for (var i = 0; i < myChildren.length; i++ ) {
          var jsChild = myChildren[i];
          if ( jsChild.type === 'element' ) {
            validation(jsChild);
          }
        }
      };
      return {
        'allowLayby': true,
        'elements': this.elSpec,
        'laybyMessage': "Temp space!",
        'unknownElement': new that.ElSpec().elSpec,
        'unknownAttribute': {
          asker: Xonomy.askString
        },
        'validate': validation
      }
    }
  }; // end DocSpec class
}).apply(bibjs.xonomy); // Apply the "bibjs.xonomy" namespace to the anonymous function.


$(document).ready( function() {
  // If bibjs.data doesn't already exist, create it.
  bibjs.data = bibjs.data || {};
  var editor, docSpec, unmatchedIds,
      xml = document.getElementById('xonomy-source');
  // Only render Xonomy if there is actually XML to edit.
  if ( xml ) {
    xml = xml.textContent;
    editor = document.getElementById('xonomy-editor');
    docSpec = new bibjs.xonomy.DocSpec;
    unmatchedIds = $("a.xonomy-match-id");
    Xonomy.render(xml, editor, docSpec);
  
    // Create links to Xonomy representations of Biblio Items with duplicate ids.
    unmatchedIds.attr('href', function(index) {
      var xmlid = unmatchedIds[index].textContent,
          htmlid = bibjs.xonomy.getCorrespHtmlId(xmlid) || '';
      return '#'+htmlid;
    });
  }
});