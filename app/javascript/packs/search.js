$(document).on('keyup keydown keypress change', '.search-input', function () {
  $.each($('ul.nav.nav-tabs > li'), function(i, elem) {
    $(elem).removeClass('active')
  });
  $.each($('.tab-content > .tab-pane'), function(i, elem) {
    $(elem).removeClass('active')
  });
  $('#searchTab').addClass('active')
  $('#searchList').addClass('active')
  searchFiles($(this));
})

function searchFiles(elem) {
  $.ajax({
    type: 'POST',
    url: `/reviewers/repos/${elem.attr('repo-id')}/contents/search`,
    dataType: 'JSON',
    data: { keyword: elem.val() },
    element: elem,
    success: function(data) {
      $('#result').empty()
      $('#result').text(data.message)
      $.each(data.contents, function(i, content) {
        var index = `<h6 class='file' content-id=${content[0]}>${content[1]}</h6>`;
        var subIndex = '';
        $.each(content[2], function(i, line) {
          subIndex = subIndex + `<li><a href='/reviewers/repos/${data.repo_id}/contents/${content[0]}' data-remote=true class='file' content-id=${content[0]}><small>${line}</small></a></li>`;
        });
        $('#result').append(`<p>${index}<ul>${subIndex}</ul></p>`)
      });
    }
  });
};
