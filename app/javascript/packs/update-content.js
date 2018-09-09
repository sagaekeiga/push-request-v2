$('.update-dir-file-button').on('click', function(e) {
  $.ajax({
    type: 'PUT',
    url: `/reviewees/repos/${$(this).attr('repo-id')}/contents/${$(this).attr('content-id')}`,
    dataType: 'JSON',
    element: $(this),
    success: function(data) {
      // $(this.element).
      if (data.status == 'hidden') {
        $(this.element).text('公開する')
        $(this.element).removeClass('btn-outline-danger').addClass('btn-outline-primary')
      } else {
        $(this.element).text('非公開にする')
        $(this.element).removeClass('btn-outline-primary').addClass('btn-outline-danger')
      }
    }
  });
});
