package Catalyst::Component::Deserializer::YAML;

use Moose;
extends 'Catalyst::Component';
with 'Catalyst::ComponentRole::Deserializer';
use YAML::Syck;
use namespace::clean -except => 'meta';

sub deserialize {
  my ($self, $body) = @_;
  return LoadFile("$body");
}

__PACKAGE__->meta->make_immutable;
1;
