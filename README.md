# Rex Nginx module

This module setup nginx.

## Tasks

### setup

Call this task to install nginx on your system.

#### Parameters

* ensure - Default: latest
* conf_ensure, Create configuration - Default: present
* service_ensure, Start service - Default: running
* nginx_conf, Location of nginx.conf file - Default: /etc/nginx/nginx.conf
* nginx_conf_template, Which template to use for nginx.conf - Default: templates/nginx/nginx.conf.tpl
* mime_type_conf, Location of mime.types file - Default: /etc/nginx/mime.types
* mime_type_conf_template, Which template to use for mime.types file. - Default: templates/nginx/mime.types.tpl
* user - Default: nginx
* worker_processes, How many worker processes - Default: 1
* error_log_file, Where to log error messages - Default: /var/log/nginx/error.log
* error_log_level - Default: warn
* pid_file - Default: /var/run/nginx.pid
* worker_connections, How many worker connections - Default: 1024
* mime_type_file - Default: /etc/nginx/mime.types
* default_type, Default mimetype to deliver - Default: application/octet-stream
* log_format_main - Default: `$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$http_x_forwarded_for"`
* access_log - Default: /var/log/nginx/access.log
* sendfile - Default: on
* keepalive_timeout - Default: 65
* gzip - Default: on
* http_options, an array to add additional http options - Default: `[]`
* http_include_files, Include configuration files - Default: `["/etc/nginx/conf.d/*.conf"]`
* events_options, Additional options for the events section. - Default: `[]`
* main_options, Additional options for the main section. - Default: `[]`

#### Example

```perl
use Nginx;

task "setup", sub {
  Nginx::setup;
};
```

```perl
use Nginx;

task "setup", sub {
  Nginx::setup {
    ensure => 'present',
    user => 'nobody',
    http_options => [
      'tcp_nopush on',
      'foobar off',
    ],
    events_options => [
      'xyz off',
    ],
    main_options => [
      'abc 123',
    ],
  };
};
```


## Resources

### vhost

Create a virtual host.

#### Parameters

* ensure - Default: present
* configuration_dir, Directory where to store the configuration file for this vhost - Default: /etc/nginx/conf.d
* on_change, Hook to execute when this vhost changed - Default: `sub { service nginx => "reload"; }`
* listen, Which ip:port to listen on - Default: 80
* server_name, Virtualhost name - Default: localhost
* access_log - Default: /var/log/nginx/log/$resource_name.access.log
* access_log_format - Default: main
* locations, HashRef to configure locations - Default:
```perl
{
  '/' => {
    root  => '/usr/share/nginx/html',
    index => 'index.html index.htm',
  },
  '~ /\.ht' => {
    deny => 'all',
  },
}
```

* error_pages, HashRef to configure error pages - Default:
```perl
{
  404               => '/404.html',
  '500 502 503 504' => '/50x.html',
};
```
* configuration, Which template to use for vhost generation - Default: templates/nginx/vhost.tpl


#### Example

```perl
Nginx::vhost "ci.rexify.org",
  ensure => "present";
```

```perl
Nginx::vhost "ci.rexify.org",
  ensure => "present",
  locations => {
    '/' => {
      root  => '/usr/share/nginx/html',
      index => 'index.html index.htm',
    },
    '~ /\.ht' => {
      deny => 'all',
    },
  };
```
