// Accessible modal

// Set up namespace for DHQ functions
var bibjs = bibjs || {};
bibjs.modal = {};

// Create an anonymous function to hold functions to be namespaced.
(function() {
  /* Capture the current context so these functions can refer to themselves even 
    when the context changes. */
  var that = this;
  
  var closeBtn = function() { 
        return document.getElementById('modal-close-button'); },
      modal = function() { 
        return document.getElementById('modal'); },
      modalDoc = function() { 
        return document.getElementById('modal-doc'); },
      mainDoc = function() { 
        return document.querySelector('div.main'); },
      modalOverlay = function() { 
        return document.getElementById('modal-overlay'); };
  
  
  /*** Private functions ***/
  
  var getCurrentFocus = function() {
    return document.querySelector(':focus');
  };
  
  var getFoci = function(node = document) {
    var fociQueryStr =
      'a[href], button:not([disabled]), *[role="button"]:not([disabled]), '
    + 'input:not([disabled]), textarea:not([disabled]) '
    + '*[tabindex]';
    return node.querySelectorAll(fociQueryStr);
  };
  
  var setFocusInModal = function() {
    var useFocus = getFoci(modalDoc());
    useFocus = useFocus.length > 0 ? useFocus[0] : closeBtn;
    useFocus.focus();
  };
  
  
  /*** Public functions ***/
  
  this.makePerceivableModal = function(content, event) {
    var useLabel;
    $(modalDoc()).html(content);
    // Add aria-labelledby pointing to an <h1>, if possible.
    useLabel = $(modalDoc()).find('h1[id]');
    if ( useLabel.length !== 0 ) {
      useLabel = useLabel[0].id;
      modal().setAttribute('aria-labelledby', useLabel);
    }
    // Make the modal active, viewable, and accessible to screenreaders.
    bibjs.a11y.showBlock(modal());
    bibjs.a11y.showBlock(modalOverlay());
    // Hide the main content from screenreaders while the modal is open.
    mainDoc().setAttribute('aria-hidden', 'true');
    // Focus on modal and keep focus there.
    setFocusInModal();
    mainDoc().addEventListener('focusin', setFocusInModal);
    closeBtn().addEventListener('click', function() {
      that.tearDownModal(event);
    }, { once: true });
  }; // this.makePerceivableModal()
  
  this.tearDownModal = function(event) {
    var prevFocus = event.target;
    // Hide the modal container and overlay.
    bibjs.a11y.hideBlock(modal());
    bibjs.a11y.hideBlock(modalOverlay());
    modal().removeAttribute('aria-labelledby');
    // Bring the main content back into screenreaders' scope.
    mainDoc().setAttribute('aria-hidden', 'false');
    // Delete the content of the modal.
    $(modalDoc()).html();
    // Move focus back to triggering element.
    mainDoc().removeEventListener('focusin', setFocusInModal);
    prevFocus.focus();
  }; // this.tearDownModal()
  
}).apply(bibjs.modal); // Apply the namespace to the anonymous function.
