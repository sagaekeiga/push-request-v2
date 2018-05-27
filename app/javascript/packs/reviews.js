// highright.jsを読み込んだあとに関数を走らせる
$(window).on('load', function() {
  hoverColor();

  $('.hljs-addition').click(function() {
    addForm($(this));
  })

  $(document).on('click', '.cancel-trigger', function () {
    removeForm($(this));
  })

  $(document).on('click', '.review-trigger', function () {
    createReviewComment($(this));
  })

  $(document).on('click', '.destroy-trigger', function () {
    destroyReviewComment($(this));
  })

  $(document).on('click', '.edit-trigger', function () {
    editReviewCommentForm($(this));
  })

  $(document).on('click', '.update-trigger', function () {
    updateReviewComment($(this));
  })

  $(document).on('click', '.cancel-update-trigger', function () {
    cancelUpdateReviewComment($(this));
  })

  $(document).on('click', '#submit_review_button', function () {
    $(this).prop('disabled', true);
  })
});

function hoverColor() {
  $('.hljs-addition').each(function(i, elem) {
    $(elem).css('cursor','pointer');
    var color = $(elem).css("color");
    $(elem).hover(
      function(){
        $(this).css({ 'color':'#FFFFFF', 'text-decoration':'none' });
      },
      function(){
        $(this).css({ 'color': color, 'text-decoration':'none' });
      }
    )
  })
};

function addForm(elem) {
  if (!$(elem).hasClass('add-form')) {
    var position = $(elem).closest('.code-tr').attr('data-line-number');
    var path = $(elem).closest('.changed-file-list-wrapper').find('.changed-file-name').text();
    var changed_file_id = $(elem).closest('.file-border').attr('changed-file-id');
    var textarea = $('<textarea>').attr({
        name: 'reviews[body][]',
        class: 'form-control md-textarea body',
        rows: '5'
    });
    var positionHiddenField = $('<input>').attr({
        type: 'hidden',
        name: 'reviews[position][]',
        value: position,
        class: 'position'
    });
    var pathHiddenField = $('<input>').attr({
        type: 'hidden',
        name: 'reviews[path][]',
        value: path,
        class: 'path'
    });
    var changedFileIdHiddenField = $('<input>').attr({
        type: 'hidden',
        name: 'reviews[changed_file_ids][]',
        value: changed_file_id,
        class: 'changed_file_id'
    });
    // input追加
    $('<div class="card new-review-comments"><div class="card-body"></div></div>').insertAfter($(elem).closest('.code-tr'));
    $(elem).closest('.code-tr').nextAll('.card').find('.card-body').prepend(textarea);
    $('<div class="flex-row text-right"></div>').insertAfter($(elem).closest('.code-tr').nextAll('.card').find('textarea'));
    $(elem).closest('.code-tr').nextAll('.card').find('.flex-row').prepend('<button class="btn btn-primary review-trigger" type="button">Start a review</button>');
    $(elem).closest('.code-tr').nextAll('.card').find('.flex-row').prepend('<button class="btn btn-default cancel-trigger" type="button">Cancel</button>');
    positionHiddenField.insertAfter($(elem).closest('.code-tr').nextAll('.card').find('.review-trigger'));
    pathHiddenField.insertAfter($(elem).closest('.code-tr').nextAll('.card').find('.review-trigger'));
    changedFileIdHiddenField.insertAfter($(elem).closest('.code-tr').nextAll('.card').find('.review-trigger'));
    $(elem).addClass('add-form');
  }
};

function removeForm(elem) {
  elem.closest('.card').prevAll('tr').find('.add-form').removeClass('add-form');
  elem.closest('.card').remove();
};

function createReviewComment(elem) {
  $.ajax({
    type: 'POST',
    url: `/reviewers/review_comments`,
    dataType: 'JSON',
    data: {
      path: elem.nextAll('.path').val(),
      position: elem.nextAll('.position').val(),
      changed_file_id: elem.nextAll('.changed_file_id').val(),
      body: elem.closest('.flex-row').prevAll('textarea').val(),
      reviewer_id: $('.data_id').attr('reviewer-id')
    },
    element: elem,
    success: function(data) {
      if (data.status === 'success') {
        var card = elem.closest('.card');
        card.empty();
        card.prepend(`<div class="card-header"><span class="label label-warning">Pending</div>
          <div class="card-body"><p class="card-text" review-comment-id=${data.review_comment_id} /></div>`);
        var cardText = card.find('.card-text')
        cardText.text(data.body);
        $('<div class="flex-row text-right"></div>').insertAfter(cardText);
        cardText.nextAll('.flex-row').prepend('<button class="btn btn-primary edit-trigger" type="button"><span class="glyphicon glyphicon-pencil"></span></button>');
        cardText.nextAll('.flex-row').prepend('<button class="btn btn-danger destroy-trigger" type="button" data-confirm="本当にキャンセルしてよろしいですか？"><span class="glyphicon glyphicon-trash"></span></button>');
      }
    }
  });
};

function destroyReviewComment(elem) {
  // 「OK」時の処理開始 ＋ 確認ダイアログの表示
	if(window.confirm('本当に削除してよろしいですか？')){
    elem.prop('disabled', true);
    $.ajax({
      type: 'DELETE',
      url: `/reviewers/review_comments/${elem.closest('.card-body').find('.card-text').attr('review-comment-id')}`,
      dataType: 'JSON',
      element: elem,
      success: function(data) {
        if (data.status === 'success') {
          elem.closest('.card').prevAll('tr').find('.add-form').removeClass('add-form');
          elem.closest('.card').remove();
          elem.prop('disabled', false);
        }
      }
    });
	}
};

function editReviewCommentForm(elem) {
  elem.prop('disabled', true);
  var reviewCommentId = elem.closest('.flex-row').prevAll('.card-text').attr('review-comment-id')
  var textarea = $('<textarea>').attr({
    name: 'reviews[body][]',
    class: 'form-control md-textarea',
    'review-comment-id': reviewCommentId
  });
  $('<span class="label label-primary">編集中</span>').insertAfter(elem.closest('.card').find('.card-header').find('span'));
  elem.prevAll('.destroy-trigger').remove();
  elem.closest('.flex-row').prepend('<button class="btn btn-default cancel-update-trigger" type="button">Cancel</button>');
  elem.removeClass('edit-trigger').addClass('update-trigger').text('Update');
  elem.closest('.card-body').prepend(textarea.text(elem.closest('.card-body').find('p').text()));
  elem.closest('.flex-row').prevAll('.card-text').remove();
  elem.prop('disabled', false);
};

function cancelUpdateReviewComment(elem) {
  $.ajax({
    type: 'GET',
    url: `/reviewers/review_comments/${elem.closest('.flex-row').prevAll('textarea').attr('review-comment-id')}`,
    dataType: 'JSON',
    element: elem,
    success: function(data) {
      elem.removeClass('cancel-update-trigger btn-default').addClass('destroy-trigger btn-danger');
      elem.text('');
      $(elem).wrapInner('<span class="glyphicon glyphicon-trash"></span>');
      elem.nextAll('.update-trigger').removeClass('update-trigger').addClass('edit-trigger');
      elem.closest('.card-body').prepend(`<p class="card-text" review-comment-id=${elem.closest('.flex-row').prevAll('textarea').attr('review-comment-id')}></p>`);
      elem.closest('.card-body').find('p').text(data.body);
      elem.closest('.flex-row').prevAll('textarea').remove();
    }
  });
};

function updateReviewComment(elem) {
  elem.prop('disabled', true);
  $.ajax({
    type: 'PUT',
    url: `/reviewers/review_comments/${elem.closest('.card-body').find('textarea').attr('review-comment-id')}`,
    dataType: 'JSON',
    data: { body: elem.closest('.card-body').find('textarea').val() },
    element: elem,
    success: function(data) {
      if (data.status === 'success') {
        $(elem).text('').wrapInner('<span class="glyphicon glyphicon-pencil"></span>');
        elem.prevAll('.cancel-update-trigger').removeClass('cancel-update-trigger btn-default').addClass('destroy-trigger btn-danger').text('');
        $(elem).prevAll('button').wrapInner('<span class="glyphicon glyphicon-trash"></span>');
        elem.removeClass('update-trigger').addClass('edit-trigger');
        elem.closest('.card-body').prepend(`<p class="card-text" review-comment-id=${elem.closest('.flex-row').prevAll('textarea').attr('review-comment-id')}></p>`);
        elem.closest('.card-body').find('p').text(data.body);
        elem.closest('.card-body').find('textarea').remove();
        elem.closest('.card').find('span.label-primary').remove();
        elem.prop('disabled', false);
      }
    }
  });
};
