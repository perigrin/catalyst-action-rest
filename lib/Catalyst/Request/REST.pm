package Catalyst::Request::REST;
# ABSTRACT: A REST-y subclass of Catalyst::Request (DEPRECATED)
use Moose;
extends 'Catalyst::Request';
with 'Catalyst::RequestRole::REST';

1;

__END__

=head1 DESCRIPTION

This class exists for backwards compatibility.  New code should use
L<Catalyst::RequestRole::REST> instead; see there for all methods and
attributes.

=cut
