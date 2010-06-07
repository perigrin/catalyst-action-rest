package Catalyst::ActionRole::SerializeblePlugins::ForBrowsers;
use Moose::Role;
use namespace::autoclean;

use Catalyst::Request::REST::ForBrowsers;
use Catalyst::Utils ();

our $VERSION = '0.85';
$VERSION = eval $VERSION;

with qw(SerializeBase);

sub _find_accepted_content_types {
    my ( $self, $c, $config ) = @_;

    # pick preferred content type
    my @accepted_types;    # priority order, best first

    # give top priority to content type specified by stash, if any
    my $content_type_stash_key = $config->{content_type_stash_key};
    if ( $content_type_stash_key
        and my $stashed = $c->stash->{$content_type_stash_key} )
    {

        # convert to array if not already a ref
        $stashed = [$stashed] if not ref $stashed;
        push @accepted_types, @$stashed;
    }

    # then sniff the browser, becasue we don't trust them
    # I'm looking at you WebKit
    if ( $c->request->does('Catalyst::TraitFor::Request::REST::ForBrowsers') ) {
        push @accepted_types, 'text/html' if $c->request->looks_like_browser;
    }

    # then content types requested
    push @accepted_types, @{ $c->request->accepted_content_types };

    # then the default
    push @accepted_types, $config->{'default'} if $config->{'default'};
    return @accepted_types;
}

1;
