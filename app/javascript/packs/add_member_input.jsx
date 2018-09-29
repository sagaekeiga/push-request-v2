import React from 'react'
import PropTypes from 'prop-types'

class AddMemberInput extends React.Component {
  constructor (props) {
    super (props);
    // this.state = {
    //   shortMessage: this.props.short_message
    // }
    this.handleChange = this.handleChange.bind(this);
  };

  handleChange(e) {
    // this.setState({shortMessage: e.target.value});
    // this.countupChars(e.target.value);
    // $(window).unbind();
    // $(window).on('beforeunload', onBeforeunloadHandler);
    console.log(111111)
    $.ajax({
      type: 'POST',
      url: `/reviewees/memberships/suggest`,
      dataType: 'JSON',
      data: { keyword: e.currentTarget.val() },
      success: function(data) {
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
  }


  // countupChars(shortMessage) {
  //   var charsCount = shortMessage.length + this.props.chars_count
  //   $('.count').text(charsCount + '文字/70文字');
  //   if (charsCount > 69) {
  //     $('.count').addClass('over-chars-count');
  //   } else {
  //     $('.count').removeClass('over-chars-count');
  //   }
  //   if (charsCount > 70) {
  //     alert('文字数を超過しています。');
  //     this.setState({shortMessage: shortMessage.slice(0, -1)});
  //     charsCount = shortMessage.slice(0, -1).length + this.props.chars_count
  //     $('.count').text(charsCount + '文字/70文字');
  //   }
  // }

  render () {
    return (
      <React.Fragment>
        <input type='text' className='form-control membership-input' placeholder='Githubのメールアドレスかニックネーム' onChange={ this.handleChange } />
      </React.Fragment>
    );
  }
}

AddMemberInput.propTypes = {
};
export default AddMemberInput
