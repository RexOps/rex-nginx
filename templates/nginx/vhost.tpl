#
# This file is managed by rex
#

server {
    listen       <%= $listen %>;
    server_name  <%= $server_name %>;

    access_log  <%= $access_log %>  <%= $access_log_format %>;

% for my $location (sort keys %{ $locations }) {
    location <%= $location %> {
%   for my $option ( sort keys %{ $locations->{$location} } ) {
      <%= $option %> <%= $locations->{$location}->{$option} %>;
%   }
    }
% }    

% for my $error_page (sort keys %{ $error_pages }) {
    error_page <%= $error_page %> <%= $error_pages->{$error_page} %>;
% }

}
