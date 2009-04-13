package Catalyst::RequestRole::Deserialize;
# ABSTRACT: A helper for actions that do the Deserialize role
use Moose::Role;

has data => (
  is     => 'ro',
  writer => '_set_data',
);

1;

__END__

=head1 DESCRIPTION

This role is automatically composed into your request by
L<Catalyst::ActionRole::Deserialize>.  See there for more details.

=attr data

The deserialized data from the request body, if any.

=cut
