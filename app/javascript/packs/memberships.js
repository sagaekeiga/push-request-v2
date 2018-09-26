$(document).on('keyup keydown keypress change', '.membership-input', function () {
  suggestMembers($(this));
})

$(document).on('click', '.add-member-btn', function () {
  $(this).attr('disabled', true)
  inviteMember($(this));
})

function suggestMembers(elem) {
  $.ajax({
    type: 'POST',
    url: `/reviewees/memberships/suggest`,
    dataType: 'JSON',
    data: { keyword: elem.val() },
    element: elem,
    success: function(data) {
      console.log(data)
      if ($.isEmptyObject(data.github_accounts)) {
        $('.members-table').addClass('hidden')
        $('.members-tbody').empty()
        return
      }
      $('.members-table').removeClass('hidden')
      $('.members-tbody').empty()
      $.each(data.github_accounts, function(i, github_account) {
        $('.members-tbody').append(`<tr>
            <td class='col-sm-1'><img src=${github_account.avatar_url} class='img-responsive'/></td>
            <td class='col-sm-7 text-left'>${github_account.email}</td>
            <td class='col-sm-4'><button class='btn btn-block btn-outline-primary add-member-btn' github-account-id=${github_account.id} type='button'>追加</button></td>
          </tr>`
        )
      });
    }
  });
};

// @FIXME Reactに移行して対応
function inviteMember(elem) {
  $.ajax({
    type: 'POST',
    url: `/reviewees/memberships`,
    dataType: 'JSON',
    data: { github_account_id: elem.attr('github-account-id') },
    element: elem,
    success: function(data) {
      $(elem.element).closest('tr').remove()
    }
  });
};
