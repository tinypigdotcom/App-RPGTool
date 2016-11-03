#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use lib 'lib';

#./blib/lib/App/RPGTool.pm
#./lib/App/RPGTool.pm

use Data::Dumper;
use DMB::Tools ':all';
use App::RPGTool;

sub function1 {
    my $RPGTool = App::RPGTool->new();
    $RPGTool->run();
    print "I am a.pl\n";
}

sub main {
    my @argv = @_;
    function1();
    return;
}

my $rc = ( main(@ARGV) || 0 );

exit $rc;

