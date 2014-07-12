package Web::Compare;
use strict;
use warnings;
use Carp qw/croak/;
use HTTP::Request;
use Furl;
use Diff::LibXDiff;

use Class::Accessor::Lite (
    ro  => [qw/ req ua diff /],
);

our $VERSION = '0.02';

sub new {
    my ($class, $left, $right, $options) = @_;

    bless {
        req => [ _init_req($left), _init_req($right) ],
        ua  => $options->{ua} || Furl->new,
        diff => $options->{diff},
    }, $class;
}

sub _init_req {
    my $u = shift;

    unless (ref $u eq 'HTTP::Request') {
        $u = HTTP::Request->new(GET => $u);
    }

    return $u;
}

sub report {
    my $self = shift;

    my @responses;
    for my $req ( @{ $self->req } ) {
        my $res = $self->ua->request($req);
        push @responses, $res->content;
    }

    my $diff;
    if ($self->diff) {
        $diff = $self->diff->(@responses);
    }
    else {
        $diff = Diff::LibXDiff->diff(@responses);
    }

    return $diff;
}

1;

__END__

=head1 NAME

Web::Compare - Compare web pages


=head1 SYNOPSIS

    use Web::Compare;
    
    my $wc = Web::Compare->new($left_url, $right_url);
    warn $wc->report;


=head1 DESCRIPTION

Web::Compare is the tool for comparing web pages.

It might be useful like below.

    use Web::Compare;
    
    my $wc = Web::Compare->new(
        'http://staging.example.com/foo/bar',
        'http://production.example.com/foo/bar',
    );
    warn $wc->report;

To compare staging web page to production web page.


=head1 METHODS

=head2 new($left_url, $right_url[, $options_ref])

constractor

C<$left_url> and C<$right_url> is the URL or these should be L<HTTP::Request> object.

C<$options_ref> follows bellow params.

=over

=item B<ua>

The user agent object what you want.

=item B<diff>

By default, C<Web::Compare> uses L<Diff::LibXDiff> for reporting diff.
If you want to use an other diff tool, you'll set C<diff> param as code ref.

    use Web::Compare;
    use String::Diff qw//;
    
    my $wc = Web::Compare->new(
        $lefturl, $righturl, {
            diff => sub {
                my ($left, $right) = @_;

                String::Diff::diff_merge($left, $right);
            },
        },
    );

=back

=head2 report

Send requests and report diff


=head1 REPOSITORY

Web::Compare is hosted on github: L<http://github.com/bayashi/Web-Compare>

Welcome your patches and issues :D


=head1 AUTHOR

Dai Okabayashi E<lt>bayashi@cpan.orgE<gt>


=head1 SEE ALSO


=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut