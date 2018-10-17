$(document).on('click', '#reviewSubmit', function () {
  showModal('#reviewSubmitModal')
})

$(document).on('click', '#import', function () {
  showModal('#importModal')
})

$(document).on('click', '.close-comment-btn', function () {
  $('.comment-list').empty();
})

$(document).on('click', '.open-comment-btn', function () {
  showCommentModal($(this));
})

function showCommentModal(element) {
  var changed_file_id = $(element).attr('changed_file_id');
  var path = $(element).attr('com_path');
  var position = $(element).attr('position');

  $(function(){
    $.ajax({
      type: 'GET',
      url: '/reviewers/review_comments',
      dataType: 'JSON',
      cache: false,
      data: {
        changed_file_id: `${changed_file_id}`,
        position: `${position}`,
        comm_path: `${path}`
      },
      success: function(data){
        var comments = data.review_comments
        var assign_code = $(`tr[data-line-number=${position}]`).find($('pre'))[0];
        $('.comment-list').empty();

        $.each(assign_code,
          function(index, elem) {
            if (typeof elem === "string" && elem.indexOf('<pre>') != -1){
              $('.comment-list')
                .append(elem);
            }
          }
        );

        $.each(comments,
          function(index, elem) {
            $('.comment-list')
              .append(`<tr><td>${elem}</td></tr>`);
          }
        );
        showModal('#commentModal');
      },
      error:function(){console.log('Miss..');}
    });
  });
}

function showModal(idName) {
  $(idName).modal('show')
}
