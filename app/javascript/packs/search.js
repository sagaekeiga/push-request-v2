$(document).on('keyup keydown keypress change', '.search-input', function () {
  searchFiles($(this));
})

function searchFiles(elem) {
  $.ajax({
    type: 'POST',
    url: `/reviewers/repos/${elem.attr('repo-id')}/contents/search`,
    dataType: 'JSON',
    data: {
      keyword: elem.val()
      // position: elem.nextAll('.position').val(),
      // changed_file_id: elem.nextAll('.changed_file_id').val(),
      // body: elem.closest('.flex-row').prevAll('textarea').val(),
      // reviewer_id: $('.data_id').attr('reviewer-id')
    },
    element: elem,
    success: function(data) {
      console.log(data.contents);
      // if (data.status === 'success') {
      //   var panel = elem.closest('.panel');
      //   panel.empty();
      //   panel.prepend(`<div class="panel-heading"><span class="label label-warning">Pending</div>
      //     <div class="panel-body"><p class="panel-text" review-comment-id=${data.review_comment_id} /></div>`);
      //   var panelText = panel.find('.panel-text')
      //   panelText.wrapInner(marked(data.body));
      //   $('<div class="flex-row text-right"></div>').insertAfter(panelText);
      //   panelText.nextAll('.flex-row').prepend('<button class="btn btn-primary edit-trigger" type="button"><span class="glyphicon glyphicon-pencil"></span></button>');
      //   panelText.nextAll('.flex-row').prepend('<button class="btn btn-danger destroy-trigger" type="button" data-confirm="本当にキャンセルしてよろしいですか？"><span class="glyphicon glyphicon-trash"></span></button>');
      // }
      // elem.prop('disabled', false);
    }
  });
};
