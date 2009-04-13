package Catalyst::ControllerRole::SerializeBase;

use Moose::Role;

has serialize_config => (
  is         => 'ro',
  isa        => 'HashRef',
  lazy_build => 1,
);

sub _build_serialize_config {
  my $self = shift;

  my $c = $self->_application;

  if (exists $self->{serialize}) {
    my $self_class = blessed $self;
    $c->log->warning(
      "Using deprecated 'serialize' configuration for $self_class!"
    );
    $c->log->warning(
      "Please see `perldoc Catalyst::Action::REST`."
    );
    my $config = $self->{serialize};
    # if they're using the deprecated config, they may be expecting a
    # default mapping too.  (from C::C::REST)
    $config->{map} ||= $self->{map};
    return { %$config };
  }

  # XXX treating the object as a hash
  return { %$self };
}

has default_content_type => (
  is         => 'ro',
  isa        => 'Maybe[Str]',
  lazy_build => 1,
);

sub _build_default_content_type {
  my $self = shift;
  return $self->serialize_config->{default};
}

has content_type_map => (
  is         => 'ro',
  isa        => 'HashRef[ArrayRef]',
  lazy_build => 1,
);

sub _build_content_type_map {
  my $self = shift;
  my $map = $self->serialize_config->{map};
  for (keys %$map) {
    $map->{$_} = [ $map->{$_} ] unless ref $map->{$_};
  }
  return $map;
}

sub accepted_content_types {
  my ($self, $c) = @_;
  my $config = $self->serialize_config;
  my @accepted;

  my $ct_stash_key = $config->{content_type_stash_key};
  if ($ct_stash_key and my $stashed = $c->stash->{$ct_stash_key}) {
    $stashed = [ $stashed ] unless ref $stashed;
    push @accepted, @$stashed;
  }
  push @accepted, @{ $c->request->accepted_content_types };
  push @accepted, $self->default_content_type
    if $self->default_content_type;
  return @accepted;
}

sub possible_content_type_maps {
  my ($self, $c) = @_;

  my @accepted = $self->accepted_content_types($c);
  my $map = $self->content_type_map;
  return map {
    {
      content_type => $_,
      name         => $map->{$_}->[0],
      arg          => $map->{$_}->[1],
    }
  } grep { $map->{$_} } @accepted;
}

1;
