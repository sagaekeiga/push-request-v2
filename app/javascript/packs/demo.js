$(document).on('click', '.demo-request-btn', function () {
  $('#demo_img').removeClass('hidden');
})

var now = new Date().getTime();

$(window).scroll(function (){
  var dockerHeight = $('.docker').offset().top;
  var scroll = $(window).scrollTop();
  var windowHeight = $(window).height();
  if ((scroll > dockerHeight - windowHeight + 300)){
    $('img.docker').attr('src', `/assets/docker.mov.gif?' + ${(new Date).getTime()}`);
  }
});
