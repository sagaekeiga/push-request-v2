$(document).on('click', '#reviewSubmit', function () {
  showModal('#reviewSubmitModal')
})

$(document).on('click', '#import', function () {
  showModal('#importModal')
})

$(document).on('click', '.open_comment', function () {
  showModal('.commentModal')
})

function showModal(idName) {
  $(idName).modal('show')
}
