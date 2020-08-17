// Accessible navigation menu (with tabs)

$(document).ready( function() {
  var tabs = $('button.tab');
  tabs.click( function(e) {
    var thisTab = e.target;
    tabs.each( function() {
      if ( this !== thisTab ) {
        bibjs.a11y.toggleCollapsible(this, 'false');
      }
    });
    bibjs.a11y.toggleCollapsible(thisTab);
  });
});
  