package Catalyst::ActionRole::SerializeBase;

use MooseX::Role::Parameterized;
use Catalyst::RequestRole::REST;
use Catalyst::ControllerRole::SerializeBase;
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

has serializer_plugins => (
  is        => 'ro',
  isa       => 'HashRef',
  lazy      => 1,
  default   => sub { {} },
);

sub resolve_content_type {
  my ($self, $controller, $c) = @_;
  
  Catalyst::RequestRole::REST->meta->apply($c->request);
  Catalyst::ControllerRole::SerializeBase->meta->apply($controller);

  my @mapped = $controller->possible_content_type_maps($c);

  $self->throw_unsupported_media_type unless @mapped;

  my $c_meta = Moose::Meta::Class->initialize(blessed $c);
  my %class_to_ct;
  my %class_to_arg;

  my $ns = $self->namespace_suffix;
  my @classes_to_try = map {
    my $name = $_->{name};
    my @classes = map { "$_\::$ns\::$name" }
      $c_meta->name, $c_meta->linearized_isa;
    @class_to_ct{@classes} = ($_->{content_type}) x @classes;
    @class_to_arg{@classes} = ($_->{arg}) x @classes;
    @classes;
  } @mapped;

  my $plugin_class = eval {
    Class::MOP::load_first_existing_class(@classes_to_try);
  };

  unless ($plugin_class) {
    $self->throw_unsupported_media_type($mapped[0]);
  }

  my $plugin = $self->serializer_plugins->{$plugin_class} ||=
    $plugin_class->new(
    );

  my $found_ct = $class_to_ct{$plugin_class};

  # fiddle with response headers?

  return (
    $class_to_ct{$plugin_class},
    $plugin,
    $class_to_arg{$plugin_class},
  );
}

sub _throw {
  my ($self, $code) = @_;
  die bless $code => 'Catalyst::Action::Serialize::Exception';
}

sub throw_unsupported_media_type {
  my ($self, $content_type) = @_;
  $self->_throw(sub {
    my ($c) = @_;
    $c->response->content_type('text/plain');
    $c->response->status(415);
    $c->response->body(
      (defined $content_type and length $content_type) 
      ? "Content-Type $content_type is not supported.\r\n"
      : "Cannot find a Content-Type supported by your client.\r\n"
    );
  });
}

sub throw_serialize_bad_request {
  my ($self, $content_type, $error) = @_;
  $self->_throw(sub {
    my ($c) = @_;
    $c->response->content_type('text/plain');
    $c->response->status(400);
    $c->response->body(
      "Content-Type $content_type had a problem with your request.\r\n" .
      "***ERROR***\r\n$error"
    );
  });
}

1;
