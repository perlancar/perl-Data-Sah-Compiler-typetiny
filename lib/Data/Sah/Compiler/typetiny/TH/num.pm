package Data::Sah::Compiler::perl::TH::num;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;
#use Log::Any '$log';

use Mo qw(build default);
use Role::Tiny::With;

extends 'Data::Sah::Compiler::perl::TH';
with 'Data::Sah::Type::num';

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;
    my $dt = $cd->{data_term};

    if ($cd->{args}{core} || $cd->{args}{no_modules}) {
        $cd->{_ccl_check_type} = "$dt =~ ".'/\A(?:[+-]?(?:0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?|((?i)\s*nan\s*)|((?i)\s*[+-]?inf(inity)?)\s*)\z/';
    } else {
        $c->add_sun_module($cd);
        $cd->{_ccl_check_type} = "$cd->{_sun_module}::isnum($dt)";
    }
}

sub superclause_comparable {
    my ($self, $which, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($which eq 'is') {
        $c->add_ccl($cd, "$dt == $ct");
    } elsif ($which eq 'in') {
        if ($dt =~ /\$_\b/) {
            $c->add_ccl($cd, "do { my \$_sahv_dt = $dt; grep { \$_ == \$_sahv_dt } \@{ $ct } }");
        } else {
            $c->add_ccl($cd, "grep { \$_ == $dt } \@{ $ct }");
        }
    }
}

sub superclause_sortable {
    my ($self, $which, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($which eq 'min') {
        $c->add_ccl($cd, "$dt >= $ct");
    } elsif ($which eq 'xmin') {
        $c->add_ccl($cd, "$dt > $ct");
    } elsif ($which eq 'max') {
        $c->add_ccl($cd, "$dt <= $ct");
    } elsif ($which eq 'xmax') {
        $c->add_ccl($cd, "$dt < $ct");
    } elsif ($which eq 'between') {
        if ($cd->{cl_is_expr}) {
            $c->add_ccl($cd, "$dt >= $ct\->[0] && $dt <= $ct\->[1]");
        } else {
            # simplify code
            $c->add_ccl($cd, "$dt >= $cv->[0] && $dt <= $cv->[1]");
        }
    } elsif ($which eq 'xbetween') {
        if ($cd->{cl_is_expr}) {
            $c->add_ccl($cd, "$dt > $ct\->[0] && $dt < $ct\->[1]");
        } else {
            # simplify code
            $c->add_ccl($cd, "$dt > $cv->[0] && $dt < $cv->[1]");
        }
    }
}

1;
# ABSTRACT: perl's type handler for type "num"

=for Pod::Coverage ^(clause_.+|superclause_.+)$
