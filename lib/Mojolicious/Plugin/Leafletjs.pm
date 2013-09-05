package Mojolicious::Plugin::Leafletjs;

use Mojo::Base 'Mojolicious::Plugin';
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use File::ShareDir ':ALL';

our $VERSION = '0.002';

my %defaults = (
    name      => 'map',
    cssid     => 'map',
    longitude => undef,
    latitude  => undef,
    zoomLevel => 13,
    tileLayer =>
      'http://{s}.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/997/256/{z}/{x}/{y}.png',
    maxZoom => 18,
    attribution =>
      'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, '
      . '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, '
      . 'Imagery &copy; <a href="http://cloudmade.com">CloudMade</a>',
);

sub register {
    my ($plugin, $app) = @_;
    my (%conf) = (%defaults, %{$_[2] || {}});
    push @{$app->renderer->paths},
      catdir(dist_dir('Mojolicious-Plugin-Leafletjs'), 'templates');
    push @{$app->static->paths},
      catdir(dist_dir('Mojolicious-Plugin-Leafletjs'), 'public');

    push @{$app->renderer->classes}, __PACKAGE__;
    push @{$app->static->classes},   __PACKAGE__;

    $app->helper(
        leaflet => sub {
            my $self = shift;
            $self->render(
                template => 'leaflet_template',
                partial  => 1,
                attrs    => \%conf,
            );
        }
    );
    $app->helper(
        leaflet_marker => sub {
            my $self        = shift;
            my $marker_name = shift;
            my $longitude   = shift;
            my $latitude    = shift;
            my $parent_name = shift;

            die "Need long/lat coordinates" unless $longitude && $latitude;
            $self->render(
                template    => 'leaflet_marker',
                partial     => 1,
                marker_name => $marker_name,
                longitude   => $longitude,
                latitude    => $latitude,
                parent_map  => $parent_name || $conf{name},
            );
        }
    );
    $app->helper(
        leaflet_popup => sub {
            my $self        = shift;
            my $marker_name = shift;
            my $msg         = shift;

            die "Need marker_name and message" unless $marker_name;
            $self->render(
                template    => 'leaflet_bindpopup',
                partial     => 1,
                marker_name => $marker_name,
                msg         => $msg || "An empty message in popup",
            );
        }
    );

    $app->helper(
        leaflet_include => sub {
            my $self = shift;
            $self->render(
                template => 'leaflet_include',
                partial  => 1,
            );
        }
    );
    $app->hook(
        after_dispatch => sub {
            my $c    = shift;
            my $dom  = $c->res->dom;
            my $head = $dom->at('head') or return;

            my $append = $c->leaflet_include;
            $head->append_content($append);
            $c->tx->res->body($dom->to_xml);
        }
    );
}

1;

__DATA__

@@ leaflet_include.html.ep

%= stylesheet '/leaflet.css'
%= javascript '/leaflet.js'

@@ leaflet_template.html.ep
%= javascript begin
  var <%= $attrs->{name} %> = L.map('<%= $attrs->{cssid} %>').setView([<%= $attrs->{longitude} %>, <%= $attrs->{latitude} %>], <%= $attrs->{zoomLevel} %>);
  L.tileLayer('<%= $attrs->{tileLayer} %>', {
      maxZoom: <%= $attrs->{maxZoom} %>,
      attribution: '<%== $attrs->{attribution} %>'
  }).addTo(<%= $attrs->{name} %>);
%= end

@@ leaflet_marker.html.ep
%= javascript begin
  var <%= $marker_name %> = L.marker([<%= $longitude %>, <%= $latitude %>]).addTo(map);
%= end

@@ leaflet_bindpopup.html.ep
%= javascript begin
  <%= $marker_name %>.bindPopup("<%= $msg %>");
%= end

__END__

=encoding utf-8

=head1 NAME

Mojolicious::Plugin::Leafletjs - A Mojolicious Plugin

=head1 SYNOPSIS

    # Mojolicious
    $self->plugin(
      'Leafletjs' => {
          longitude => '75',
          latitude  => '-0.5'
      }
    );

    # Mojolicious::Lite
    plugin 'Leafletjs',
    { longitude => '75',
      latitude  => '-0.5'
    };
    # In your template
    <%= leaflet %>
    <%= leaflet_marker 'marker1', '75.02', '-35.02' %>

=head1 DESCRIPTION

Mojolicious::Plugin::Leafletjs is helpers for integrating simple maps via leafletjs

=head1 HELPERS

=head2 B<leaflet>

Accepts the following options:

=over

=item name

Name of map variable

=item longitude

Longitude

=item latitude

Latidude

=item cssid

CSS id of map

=item zoomLevel

Map zoomlevel

=item tileLayer

URL of map tile layer, defaults to a cloudmade.com tile

=item maxZoom

Max zoom into the map

=item attribution

Show some love for the leaflet team, openmap, and cloudmade map tiles

=back

=head2 B<leaflet_marker>

Accepts the following positional arguments:

=over

=item marker_name

Name of Map variable

=item longitude

Longitude

=item latitude

Latitude

=item parent_map

Map variable

=back

=head2 B<leaflet_popup>

Accepts the following positional arguments:

=over

=item marker_name

Variable name of marker

=item message

Message to display in popup

=back

=head1 TODO

=over

=item Add circles

=item Add polygons

=back

=head1 CONTRIBUTIONS

Always welcomed! L<https://github.com/battlemidget/Mojolicious-Plugin-Leafletjs>

=head1 AUTHOR

Adam Stokes E<lt>adamjs@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- Adam Stokes

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
