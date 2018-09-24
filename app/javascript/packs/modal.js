$(document).on('click', '#reviewSubmit', function () {
  showModal('#reviewSubmitModal')
})

$(document).on('click', '#import', function () {
  showModal('#importModal')
})

function showModal(idName) {
  $(idName).modal('show')
}
