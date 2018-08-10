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

marked.setOptions({
  // Githubっぽいmd形式にするか
  gfm: true,
  // Githubっぽいmdの表にするか
  tables: true,
  // Githubっぽいmdの改行形式にするか
  breaks: true,
  // Markdownのバグを修正する？（よく分からなかったので、とりあえずdefaultのfalseで）
  pedantic: false,
  // HTML文字をエスケープするか
  sanitize: true,
  // スマートなリストにするか。pedanticと関わりがあるようなので、こちらもdefaultのtrueで。
  smartLists: true,
  // クオートやダッシュの使い方。
  smartypants: true,
});
