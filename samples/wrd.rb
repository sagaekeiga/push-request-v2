require 'rubypress'
@@hostname = 'pushrequest.jp'
@@username = 'pushrequest'
@@password = 's19930528'
wp_client = Rubypress::Client.new(
  host: @@hostname,
  path: '/xmlrpc.php',
  username: @@username,
  password: @@password,
)
puts wp_client.getPosts(fields: %i(post_title post_date post_content post_title post_name))
