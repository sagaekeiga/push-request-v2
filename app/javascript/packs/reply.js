$(document).on('click', '.input-reply', function () {
  switchTextarea($(this));
})

$(document).on('click', '.reply-cancel-btn', function () {
  cancelReply($(this));
})

$(document).on('click', '.reply-submit-btn', function () {
  submitReply($(this));
})

function switchTextarea(elem) {
  replyWrapper = elem.closest('.reply-wrapper');
  replyWrapper.find('.reply-hidden-target-element').addClass('hidden');
  replyWrapper.find('.reply-show-target-element').removeClass('hidden');
};

function cancelReply(elem) {
  replyWrapper = elem.closest('.reply-wrapper');
  replyWrapper.find('.reply-hidden-target-element').removeClass('hidden');
  replyWrapper.find('.reply-show-target-element').addClass('hidden').val('');
};

function submitReply(elem) {
  $.ajax({
    type: 'POST',
    url: `/reviewers/review_comments`,
    dataType: 'JSON',
    data: {
      path: elem.nextAll('.path').val(),
      position: elem.nextAll('.position').val(),
      changed_file_id: elem.nextAll('.changed_file_id').val(),
      body: elem.closest('.text-right').prevAll('textarea').val(),
      reviewer_id: elem.nextAll('.reviewer_id').val(),
      commit_id: elem.nextAll('.commit_id').val(),
      status: 'commented',
      github_id: elem.nextAll('.github_id').val()
    },
    element: elem,
    success: function(data) {
      if (data.status === 'success') {
        replyWrapper = elem.closest('.reply-wrapper');
        $(`<div class="col-xs-1 comment-img"><img class="review-comment-img avatar img-responsive rounded-circle" src="${data.img}"></div>`).insertAfter(replyWrapper.prev('.comment-body'));
        $(`<div class="col-xs-11 comment-body">
            <div class="nickname">${data.name}</div>
            <small class="text-muted">${data.time}</small>
            <div class="col-xs-12">
              <p>
                ${data.body}
              </p>
            </div>
          </div>`).insertAfter(replyWrapper.prev('.comment-img'));
        replyWrapper.find('.reply-hidden-target-element').removeClass('hidden');
        replyWrapper.find('.reply-show-target-element').addClass('hidden')
        replyWrapper.find('.reply-show-target-element').find('textarea').val('');
        replyWrapper.find('.reply-show-target-element').find('.github_id').val(data.github_id);
      }
    }
  });
};
