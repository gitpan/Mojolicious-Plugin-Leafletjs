#!/usr/bin/env perl
use Mojolicious::Lite;

# Documentation browser under "/perldoc"
plugin 'Leafletjs',
  { longitude => '35.9239',
    latitude  => '-78.4611',
    zoomLevel => 18,
  };

app->secret('testing a mojolicious plugin yo');

get '/' => sub {
    my $self = shift;
    $self->render('index');
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<div>Showing a simple map with marker</div>
<div id="map"></div>
<%= leaflet %>
<%= leaflet_marker 'marker1', '35.9239', '-78.4611' %>
<%= leaflet_marker 'marker2', '35.9235', '-78.4610' %>
<%= leaflet_popup 'marker1', 'I really made this popup marker!' %>
<%= leaflet_popup 'marker2', 'OMG a second popup!' %>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
%= stylesheet begin
#map {
    height: 600px;
    width: 760px;
    border-radius: 5px;
}
%= end
  <body><%= content %></body>
</html>
