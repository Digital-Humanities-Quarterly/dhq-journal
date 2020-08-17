$(document).ready(function(){
  $("button.toggle").click(function()  {
     $(this).parent().children(".toggle").toggle();
     $(this).parent().next(".toggle").toggle();
   });
});
