package Catalyst::Action::Deserialize;

use Moose;
extends 'Catalyst::Action';
with 'Catalyst::ActionRole::SerializeBase' => {
  namespace_suffix => 'Deserializer'
};
use Catalyst::RequestRole::Deserialize;
use namespace::clean -except => 'meta';

around execute => sub {
  my $next = shift;
  my $self = shift;
  my ( $controller, $c ) = @_;

  my @demethods = qw(POST PUT OPTIONS);
  my $method    = $c->request->method;
  if ( grep /^$method$/, @demethods ) {
    Catalyst::RequestRole::Deserialize->meta->apply($c->request);

    my ($content_type, $component, $arg) =
      $self->resolve_content_type($controller, $c);

    my $body = $c->request->body;
    if ($body) {
      # XXX handle unsupported media/bad request
      $c->request->_set_data($component->deserialize($body));
    } else {
      $c->log->debug(
        "I would have deserialized from '$content_type', " .
        "but there was nothing in the body!"
      ) if $c->debug;
    }
  }

  $self->$next(@_);

  return 1;
};

1;
__END__

=head1 NAME

Catalyst::Action::Deserialize - Deserialize Data in a Request

=head1 SYNOPSIS

    package Foo::Controller::Bar;

    __PACKAGE__->config(
        'default'   => 'text/x-yaml',
        'stash_key' => 'rest',
        'map'       => {
            'text/x-yaml'        => 'YAML',
            'text/x-data-dumper' => [ 'Data::Serializer', 'Data::Dumper' ],
        },
    );

    sub begin :ActionClass('Deserialize') {}

=head1 DESCRIPTION

This action will deserialize HTTP POST, PUT, and OPTIONS requests.
It assumes that the body of the HTTP Request is a serialized object.
The serializer is selected by introspecting the requests content-type
header.

The specifics of deserializing each content-type is implemented as
a plugin to L<Catalyst::Action::Deserialize>.  You can see a list
of currently implemented plugins in L<Catalyst::Controller::REST>.

The results of your Deserializing will wind up in $c->req->data.
This is done through the magic of L<Catalyst::Request::REST>.

While it is common for this Action to be called globally as a
C<begin> method, there is nothing stopping you from using it on a
single routine:

   sub foo :Local :Action('Deserialize') {}

Will work just fine.

When you use this module, the request class will be changed to
L<Catalyst::Request::REST>.

=head1 SEE ALSO

You likely want to look at L<Catalyst::Controller::REST>, which implements
a sensible set of defaults for a controller doing REST.

L<Catalyst::Action::Serialize>, L<Catalyst::Action::REST>

=head1 AUTHOR

Adam Jacob <adam@stalecoffee.org>, with lots of help from mst and jrockway

Marchex, Inc. paid me while I developed this module.  (http://www.marchex.com)

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

