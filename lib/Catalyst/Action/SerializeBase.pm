package Catalyst::Action::SerializeBase;
use Moose;
use namespace::autoclean;

our $VERSION = '0.85';
$VERSION = eval $VERSION;

with qw(Catalyst::ActionRole::SerializeblePlugins);

1;

=head1 NAME

Catalyst::Action::SerializeBase - Base class for Catalyst::Action::Serialize and Catlayst::Action::Deserialize.

=head1 DEPRECATION

This Class has been Deprecated. It is no longer actually used by the
L<Catalyst::Action::Serialize> or L<Catalyst::Action::Deserialize>
Classes. The documentation below is included for historical reasons.

=head1 DESCRIPTION

This module implements the plugin loading and content-type negotiating
code for L<Catalyst::Action::Serialize> and L<Catalyst::Action::Deserialize>.

=head1 SEE ALSO

L<Catalyst::Action::Serialize>, L<Catalyst::Action::Deserialize>,
L<Catalyst::Controller::REST>,

=head1 AUTHORS

See L<Catalyst::Action::REST> for authors.

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
