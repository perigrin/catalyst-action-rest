package Catalyst::Deserializer::YAML;

use Moose;
with qw/Catalyst::Deserializer/;
use YAML::Syck;
use namespace::clean -except => 'meta';

sub deserialize {
  my ($self, $body) = @_;
  return LoadFile("$body");
}

__PACKAGE__->meta->make_immutable;
1;
