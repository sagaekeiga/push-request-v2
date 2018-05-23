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
});

function hoverColor() {
  $('.hljs-addition').each(function(i, elem) {
    $(elem).css("cursor","pointer");
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
    var path = $(elem).closest('.card').find('.card-header').text();
    var changed_file_id = $(elem).closest('.file-border').attr('changed-file-id');
    var input = $('<input>').attr({
        type: 'text_area',
        name: 'reviews[body][]',
        value: '',
        class: 'form-control body'
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
    $('<div class="card card-body review-comments"></div>').insertAfter($(elem).closest('.code-tr'));
    $(elem).closest('.code-tr').nextAll('.card').wrapInner(input);
    // @TODO widthを横幅いっぱいにする
    $('<a class="btn btn-danger cancel-trigger">Cancel</a>').insertAfter($(elem).closest('.code-tr').nextAll('.card').find('input'));
    $('<a class="btn btn-success review-trigger">Start a review</a>').insertAfter($(elem).closest('.code-tr').nextAll('.card').find('a'));
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
      body: elem.prevAll('.body').val(),
      reviewer_id: $('.data_id').attr('reviewer-id')
    },
    element: elem,
    success: function(data) {
      if (data.status === 'success') {
        var card = elem.closest('.card');
        card.empty();
        card.wrapInner(`<p class="card-text" review-comment-id=${data.review_comment_id} />`);
        var cardText = card.find('.card-text')
        card.prepend('<h4 class="card-title"><span class="label label-warning">Pending</h4>')
        cardText.text(data.body);
        $('<a class="btn btn-success edit-trigger">UPDATE</a>').insertAfter(cardText);
        $('<a class="btn btn-danger destroy-trigger">DELETE</a>').insertAfter(cardText);
      }
    }
  });
};

function destroyReviewComment(elem) {
  $.ajax({
    type: 'DELETE',
    url: `/reviewers/review_comments/${elem.prevAll('.card-text').attr('review-comment-id')}`,
    dataType: 'JSON',
    element: elem,
    success: function(data) {
      if (data.status === 'success') {
        elem.closest('.card').prevAll('tr').find('.add-form').removeClass('add-form');
        elem.closest('.card').remove();
      }
    }
  });
};

function editReviewCommentForm(elem) {
  var input = $('<input>').attr({
      type: 'text_area',
      name: 'reviews[body][]',
      value: elem.prevAll('.card-text').text(),
      class: 'form-control'
  });
  elem.prevAll('.destroy-trigger').remove();
  $('<a class="btn btn-default cancel-update-trigger">Cancel</a>').insertAfter(elem.prevAll('p'));
  elem.removeClass('edit-trigger').addClass('update-trigger');
  elem.prevAll('.card-text').html(input);
};

function cancelUpdateReviewComment(elem) {
  $.ajax({
    type: 'GET',
    url: `/reviewers/review_comments/${elem.prevAll('.card-text').attr('review-comment-id')}`,
    dataType: 'JSON',
    element: elem,
    success: function(data) {
      elem.removeClass('cancel-update-trigger btn-default').addClass('destroy-trigger btn-danger').text('DELETE');
      elem.nextAll('.update-trigger').removeClass('update-trigger').addClass('edit-trigger');
      elem.prevAll('p').find('input').remove();
      elem.prevAll('p').text(data.body);
    }
  });
};

function updateReviewComment(elem) {
  $.ajax({
    type: 'PUT',
    url: `/reviewers/review_comments/${elem.prevAll('.card-text').attr('review-comment-id')}`,
    dataType: 'JSON',
    data: { body: elem.prevAll('.card-text').find('input').val() },
    element: elem,
    success: function(data) {
      if (data.status === 'success') {
        elem.prevAll('.cancel-update-trigger').removeClass('cancel-update-trigger btn-default').addClass('destroy-trigger btn-danger').text('DELETE');
        elem.removeClass('update-trigger').addClass('edit-trigger');
        elem.prevAll('p').find('input').remove();
        elem.prevAll('p').text(data.body);
      }
    }
  });
};
