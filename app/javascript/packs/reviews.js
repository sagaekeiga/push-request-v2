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
    startReview($(this));
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
    var parentTr = $(elem).parent().parent().parent();
    var CloenedTr = parentTr.clone();
    var position = $(elem).parent().parent().parent().find('.hljs-ln-n').attr('data-line-number');
    var path = $(elem).closest('.file-border').find('.card-title').text();
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
    $(CloenedTr).insertAfter(parentTr);
    $('<td>').attr({
        colspan: '3'
    }).insertAfter(parentTr.next().children('td').filter(':last').wrapInner());
    parentTr.next().children('td').filter(':first').remove();
    parentTr.next().children('td').filter(':first').remove();
    parentTr.next().children('td').wrapInner(input);
    // @TODO widthを横幅いっぱいにする
    parentTr.next().children('td').wrapInner('<div class="card"><div class="card-body"></div></div>');
    $('<a class="btn btn-deep-orange cancel-trigger">Cancel</a>').insertAfter($(elem).parent().parent().parent().next().find('input'));
    positionHiddenField.insertAfter(parentTr.next().find('a'));
    pathHiddenField.insertAfter(parentTr.next().find('a'));
    changedFileIdHiddenField.insertAfter(parentTr.next().find('a'));
    $('<a class="btn btn-deep-orange review-trigger">Start a review</a>').insertAfter($(elem).parent().parent().parent().next().find('a'));
    $(elem).addClass('add-form');
  }
};

function removeForm(elem) {
  elem.closest('tr').prev().find('span').removeClass('add-form');
  elem.closest('tr').remove();
};

function startReview(elem) {
  console.log(elem.nextAll('.path').val());
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
    success: function(data) {
    }
  });
};
