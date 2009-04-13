package Catalyst::Serializer::YAML;

use Moose;
with qw/Catalyst::Serializer/;
use YAML::Syck;
use namespace::clean -except => 'meta';

sub serialize {
  my ($self, $data) = @_;
  return Dump($data);
}

__PACKAGE__->meta->make_immutable;
1;

