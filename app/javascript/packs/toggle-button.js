hoverColor();

function hoverColor() {
  $('.btn-success').each(function(i, elem) {
    $(elem).css('cursor','pointer');
    var color = $(elem).css('color');
    $(elem).hover(
      function(){
        $(this).text('Cancel')
      },
      function(){
        $(this).text('In Progress')
      }
    )
  })
};
