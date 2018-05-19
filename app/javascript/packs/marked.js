console.log('marked');
$.ajax({
  type: 'GET',
  url: `/reviewers/pulls/${$('.page-header').attr('pull-id')}`,
  dataType: 'JSON',
  data: { pull_id: $('.page-header').attr('pull-id') },
  success: function(data) {
    document.getElementById('marked-body').innerHTML =
      marked(data.body);
  }
});
