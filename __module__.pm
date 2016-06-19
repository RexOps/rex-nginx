#
# (c) 2016 Jan Gehring
#

package Nginx;

use strict;
use warnings;

use Rex -minimal;
use Rex::Resource::Common;

use Rex::Commands::Pkg;
use Rex::Commands::Service;
use Rex::Commands::File;
use Rex::Helper::Rexfile::ParamLookup;

eval {
  # For Rex > 1
  use Rex::Commands::Template;
  use Rex::Commands::Task;
};

task "setup", sub {
  my $ensure = param_lookup "ensure", "latest";
  my $conf_ensure = param_lookup "conf_ensure",
    ( $ensure ne "absent" ? "present" : "absent" );
  my $service_ensure = param_lookup "service_ensure", "running";
  my $nginx_conf     = param_lookup "nginx_conf",     "/etc/nginx/nginx.conf";
  my $nginx_conf_template = param_lookup "nginx_conf_template",
    "templates/nginx/nginx.conf.tpl";
  my $mime_type_conf = param_lookup "mime_type_conf", "/etc/nginx/mime.types";
  my $mime_type_conf_template = param_lookup "mime_type_conf_template",
    "templates/nginx/mime.types.tpl";

  my $user             = param_lookup "user",             "nginx";
  my $worker_processes = param_lookup "worker_processes", 1;
  my $error_log_file   = param_lookup "error_log_file",
    "/var/log/nginx/error.log";
  my $error_log_level = param_lookup "error_log_level", "warn";
  my $pid_file        = param_lookup "pid_file",        "/var/run/nginx.pid";
  my $worker_connections = param_lookup "worker_connections", 1024;
  my $mime_type_file = param_lookup "mime_type_file", "/etc/nginx/mime.types";
  my $default_type = param_lookup "default_type", "application/octet-stream";
  my $log_format_main = param_lookup "log_format_main",
    '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$http_x_forwarded_for"';
  my $access_log = param_lookup "access_log", "/var/log/nginx/access.log";
  my $sendfile   = param_lookup "sendfile",   "on";
  my $keepalive_timeout = param_lookup "keepalive_timeout", 65;
  my $gzip = param_lookup "gzip", "on";

  my $http_options = param_lookup "http_options", [];
  my $http_include_files = param_lookup "http_include_files",
    ["/etc/nginx/conf.d/*.conf"];
  my $events_options = param_lookup "events_options", [];
  my $main_options   = param_lookup "main_options",   [];

  pkg "nginx",
    ensure    => $ensure,
    on_change => sub { service nginx => "restart"; };

  file $nginx_conf,
    ensure    => $conf_ensure,
    content   => template($nginx_conf_template),
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    on_change => sub {
    if ( $ensure ne "absent" ) {
      service nginx => "reload";
    }
    };

  file $mime_type_conf,
    ensure    => $conf_ensure,
    content   => template($mime_type_conf_template),
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    on_change => sub {
    if ( $ensure ne "absent" ) {
      service nginx => "reload";
    }
    };

  service "nginx", ensure => $service_ensure
    if ( $ensure ne "absent" );
};

resource "vhost", sub {
  my $name = resource_name;

  my $ensure   = param_lookup "ensure",            "latest";
  my $conf_dir = param_lookup "configuration_dir", "/etc/nginx/conf.d";
  my $on_change = param_lookup "on_change", sub { service nginx => "reload"; };

  my $listen      = param_lookup "listen",      80;
  my $server_name = param_lookup "server_name", $name;
  my $access_log = param_lookup "access_log", "/var/log/nginx/$name.access.log";
  my $access_log_format = param_lookup "access_log_format", "main";
  my $locations = param_lookup "locations",
    {
    '/' => {
      root  => '/usr/share/nginx/html',
      index => 'index.html index.htm',
    },
    '~ /\.ht' => {
      deny => 'all',
    },
    };
  my $error_pages = param_lookup "error_pages",
    {
    404               => '/404.html',
    '500 502 503 504' => '/50x.html',
    };

  my $conf = param_lookup "configuration",
    template("templates/nginx/vhost.tpl");

  file "$conf_dir",
    ensure => "directory",
    owner  => 'root',
    group  => 'root',
    mode   => '0755';

  file "$conf_dir/$name.conf",
    content   => $conf,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    on_change => $on_change;
};

1;
