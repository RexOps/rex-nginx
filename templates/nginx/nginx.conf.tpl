#
# This file is managed by rex
#

user  <%= $user %>;
worker_processes  <%= $worker_processes %>;

error_log  <%= $error_log_file %> <%= $error_log_level %>;
pid        <%= $pid_file %>;

% for my $option (@{ $main_options }) {
<%= $option %>;
% }


events {
    worker_connections  <%= $worker_connections %>;

% for my $option (@{ $events_options }) {
    <%= $option %>;
% }
}


http {
    include       <%= $mime_type_file %>;
    default_type  <%= $default_type %>;

    log_format  main  '<%= $log_format_main %>';

    access_log  <%= $access_log %>  main;

% for my $option (@{ $http_options }) {
    <%= $option %>;
% }

    sendfile        <%= $sendfile %>
    keepalive_timeout  <%= $keepalive_timeout %>;
    gzip  <%= $gzip %>;

% for my $include_file (@{ $http_include_files }) {
    include <%= $include_file %>;
% }
}
