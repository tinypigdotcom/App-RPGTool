#!/usr/bin/perl

use strict;
use warnings;

package App::SimpleShell;

use Term::ReadLine;

my $history_file = "$ENV{HOME}/.simpleshell";

my %subs = (
    'h' => {
        does => 'Get Help',
        code => \&cmd_help,
    },
    'q' => {
        does => 'Quit',
        code => sub { exit },
    },
);

sub new {
    my ( $class, %args ) = @_;
    my $self = { };
    bless $self, $class;
    return $self;
}

sub cmd_help {
    my ($self,@args) = @_;
    for ( sort { $a cmp $b } keys %subs ) {
        printf "%-3s %-34s\n", $_, $subs{$_}->{does};
    }
}

sub add_history {
    my ($self,$line) = @_;
    $self->{term}->addhistory($line);
}

sub run {
    my ($self,@args) = @_;
    my $term = $self->{term} = Term::ReadLine->new('SimpleShell');
    $term->MinLine(undef); # disable autohistory
    my $prompt = "SimpleShell> ";
    my $line;
    while ( defined( $_ = $term->readline($prompt) ) ) {
        chomp;
        $_ ||= 'default_command';
        $line = $_;    # Make a copy so we can abuse it
        $line =~ s/(\S+)\s?//;
        my $first_word = $1 || '';
        if ($subs{$first_word}) {
            my $coderef = $subs{$first_word}->{code};
            $coderef->($self,$line);
        }
        $self->add_history($_) if /\S/;
    }
    return;
}

package main;

sub main {
    my @argv = @_;
    my $SimpleShell = App::SimpleShell->new();
    $SimpleShell->run();
    return;
}

my $rc = ( main(@ARGV) || 0 );

exit $rc;

