package Catalyst::ActionRole::SerializeBase;

use MooseX::Role::Parameterized;
use Catalyst::RequestRole::REST;
use namespace::clean -except => 'meta';

parameter namespace_suffix => (
  isa      => 'Str',
  required => 1,
);

role {
  my $p = shift;
  my $ns = $p->namespace_suffix;
  method namespace_suffix => sub { $ns };
};

sub config_for_controller {
  my ($self, $controller, $c) = @_;

  if (exists $controller->{serialize}) {
    my $controller_class = blessed $controller;
    $c->log->warning(
      "Using deprecated 'serialize' configuration for $controller_class!"
    );
    $c->log->warning(
      "Please see `perldoc Catalyst::Action::REST`."
    );
    my $config = $controller->{serialize};
    # if they're using the deprecated config, they may be expecting a
    # default mapping too.  (from C::C::REST)
    $config->{map} ||= $controller->{map};
    return $config;
  }

  return $controller;
}

sub resolve_content_type {
  my ($self, $controller, $c) = @_;
  
  Catalyst::RequestRole::REST->meta->apply($c->request);

  my $config = $self->config_for_controller($controller, $c);
  my $map = $config->{map};
  my @accepted;
  my $ct_stash_key = $config->{content_type_stash_key};
  if ($ct_stash_key and my $stashed = $c->stash->{$ct_stash_key}) {
    $stashed = [ $stashed ] unless ref $stashed;
    push @accepted, @$stashed;
  }
  push @accepted, @{ $c->request->accepted_content_types };
  push @accepted, $config->{default} if $config->{default};

  my @mapped = grep { $map->{$_} } @accepted;

  die "can't decide on a content-type: no match between map and accept"
    unless @mapped;

  for my $ct (@mapped) {
    my $val = $map->{$ct};
    $val = [ $val ] unless ref $val;
    my ($name, $arg) = @$val;
    my $ns = $self->namespace_suffix;
    # this doesn't actually work. whoops
    my $component = $c->component("Component::$ns\::$name")
      || $c->component("Catalyst::Component::$ns\::$name");
    return ($ct, $component, $arg) if $component;
  }

  # fiddle with response headers?
  die "can't decide on a content-type: no components found for @mapped";
}

1;
