package Catalyst::TraitFor::Request::REST;

use Moose::Role; # stict/warnings included

sub _insert_self_into {
    my ($class, $app_class) = @_;
    $app_class->request(Catalyst::TraitFor::Request::REST)->meta->apply_role($app_class->request);
}

sub accepted_content_types {
    my $self = shift;

    return $self->{content_types} if $self->{content_types};

    my %types;

    # First, we use the content type in the HTTP Request.  It wins all.
    $types{ $self->content_type } = 3
        if $self->content_type;

    if ($self->method eq "GET" && $self->param('content-type')) {
        $types{ $self->param('content-type') } = 2;
    }

    # Third, we parse the Accept header, and see if the client
    # takes a format we understand.
    #
    # This is taken from chansen's Apache2::UploadProgress.
    if ( $self->header('Accept') ) {
        $self->accept_only(1) unless keys %types;

        my $accept_header = $self->header('Accept');
        my $counter       = 0;

        foreach my $pair ( split_header_words($accept_header) ) {
            my ( $type, $qvalue ) = @{$pair}[ 0, 3 ];
            next if $types{$type};

            unless ( defined $qvalue ) {
                $qvalue = 1 - ( ++$counter / 1000 );
            }

            $types{$type} = sprintf( '%.3f', $qvalue );
        }
    }

    return $self->{content_types} =
        [ sort { $types{$b} <=> $types{$a} } keys %types ];
}

sub preferred_content_type { $_[0]->accepted_content_types->[0] }

sub accepts {
    my $self = shift;
    my $type = shift;

    return grep { $_ eq $type } @{ $self->accepted_content_types };
}

1;
