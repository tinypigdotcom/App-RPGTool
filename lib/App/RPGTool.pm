package App::RPGTool;

use 5.022001;
use strict;
use warnings FATAL => 'all';

our $VERSION = '0.01';

use Data::Dumper;
use DMB::Tools ':all';
use Term::ReadLine;
use JSON;

my $json = JSON->new->allow_nonref->pretty;

my $database;
my $database_init = {
    'chars'         => {},
    'monster_types' => {},
    'monsters'      => {},
    'initiative'    => {},
};
my $ACTIVE=1;
my $INACTIVE=0;

my $freeze_file = "$ENV{HOME}/.rpgtool";

my %subs = (
    'a' => {
        does => 'Activate a character',
        code => \&cmd_activate,
    },
    'd' => {
        does => 'Deactivate a character',
        code => \&cmd_deactivate,
    },
    'ac' => {
        does => 'List All Characters',
        code => \&cmd_list_all_characters,
    },
    'c' => {
        does => 'List Active Characters',
        code => \&cmd_list_active_characters,
    },
    'h' => {
        does => 'Get Help',
        code => \&cmd_help,
    },
    '?' => {
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

    if ( $args{use_test_database} ) {
        $freeze_file = "$ENV{HOME}/.rpgtool.t";
    }
    my $self = {
        use_test_database => $args{use_test_database},
    };
    bless $self, $class;

    $self->pthaw();

    return $self;
}


sub cmd_list_active_characters {
    my ($self,@args) = @_;
    print "Active Characters:\n";
    for ( sort { $a cmp $b } $self->active_characters() ) {
        print "$_\n";
    }
}

sub cmd_list_all_characters {
    my ($self,@args) = @_;
    print "All Characters:\n";
    my %chars = $self->characters_hash();
    for ( sort { $a cmp $b } keys %chars ) {
        print "$_";
        if ( !$chars{$_} ) {
            print '*';
        }
        print "\n";
    }
    print "* inactive\n";
}

sub require_one_string {
    my ($self,@args) = @_;
    my $arg = shift;
    if ( $arg !~ /\S/ ) {
        print "Missing argument\n";
        return 0;
    }
    else {
        return $arg;
    }
}

sub cmd_switch {
    my ($self,$name_search,$flag) = @_;
    my @chars = $self->search_characters_by_flag($name_search,!$flag);
    my $current_state = ($flag == $ACTIVE   ? 'in' : '') . 'active';
    my $active_verb   = ($flag == $INACTIVE ? 'de' : '') . 'activate';
    if ( @chars < 1 ) {
        print "No $current_state characters found matching input ($name_search).\n";
        return;
    }
    elsif ( @chars == 1 ) {
        my $rc = $self->set_flag($chars[0],$flag);
        print "${active_verb}d $chars[0]\n";
        return;
    }
    print "$active_verb which Characters:\n";
    for ( sort { $a cmp $b } @chars ) {
        print "$_\n";
    }
}

sub cmd_activate {
    my ($self,$char) = @_;
    return $self->cmd_switch($char,$ACTIVE);
}

sub cmd_deactivate {
    my ($self,$char) = @_;
    return $self->cmd_switch($char,$INACTIVE);
}

sub cmd_help {
    my ($self,@args) = @_;
    for ( sort { $a cmp $b } keys %subs ) {
        printf "%-3s %-34s\n", $_, $subs{$_}->{does};
    }
}

sub set_flag {
    my ($self,$char,$flag) = @_;
    if ( exists $database->{chars}->{$char} ) {
        $database->{chars}->{$char} = $flag;
        $self->pfreeze();
        return 1;
    }
    else {
        return 0;
    }
}

sub activate {
    my ($self,$char) = @_;
    return $self->set_flag($char,$ACTIVE);
}

sub deactivate {
    my ($self,$char) = @_;
    return $self->set_flag($char,$INACTIVE);
}

#     1 = active
#     0 = inactive
# undef = does not exist
sub is_active {
    my ($self,$char) = @_;
    if ( exists $database->{chars}->{$char} ) {
        return $database->{chars}->{$char};
    }
    else {
        return;
    }
}

sub dump_database {
    print Dumper($database->{chars});
}

sub characters_by_flag {
    my ($self,$flag) = @_;
    return grep { $database->{chars}->{$_} == $flag } keys %{ $database->{chars} };
}

sub active_characters {
    my ($self,@args) = @_;
    return $self->characters_by_flag($ACTIVE);
}

sub inactive_characters {
    my ($self,@args) = @_;
    return $self->characters_by_flag($INACTIVE);
}

sub add_character {
    my ($self,$char) = @_;
    return if $database->{chars}->{$char};
    $database->{chars}->{$char} = 1;
    $self->pfreeze();
    return;
}

sub delete_character {
    my ($self,$char) = @_;
    return if !defined $self->is_active($char);
    delete $database->{chars}->{$char};
    $self->pfreeze();
    return;
}

sub delete_all_characters {
    my ($self,@args) = @_;
    %{ $database->{chars} } = ();
    $self->pfreeze();
    return;
}

sub characters_hash {
    my ($self,@args) = @_;
    return %{ $database->{chars} };
}

sub search_characters_by_flag {
    my ($self,$name_search,$flag) = @_;
    return grep { /^$name_search/i } $self->characters_by_flag($flag);
}

sub init_data {
    my ($self,@args) = @_;
    if ( ref $database ne 'HASH'
        || !$database->{chars} )
    {
        $database = $database_init;
        pfreeze();
    }
}

sub pfreeze {
    my ($self,@args) = @_;
    write_file( $freeze_file, $json->encode( $database ));
}

sub pthaw {
    my ($self,@args) = @_;
    if ( -f $freeze_file && !$self->{use_test_database} ) {
        my $json_input = file_contents($freeze_file);
        $database = $json->decode( $json_input );
    }
    $self->init_data();
}

sub run {
    my ($self,@args) = @_;
    my $term   = Term::ReadLine->new('RPGTool');
    my $prompt = "RPGTool> ";
    my $OUT    = $term->OUT || \*STDOUT;
    $self->pthaw();
    my $line;
    while ( defined( $_ = $term->readline($prompt) ) ) {
        chomp;
        $_ ||= 'ac';
        $line = $_;    # Make a copy so we can abuse it
        $line =~ s/(\S+)\s?//;
        my $first_word = $1 || '';
#        $subs{$first_word}->{code}->($line) if $subs{$first_word};
        if ($subs{$first_word}) {
            my $coderef = $subs{$first_word}->{code};
            $coderef->($self,$line);
        }
        $term->addhistory($_) if /\S/;
    }
    return;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

App::RPGTool - Perl extension for blah blah blah

=head1 SYNOPSIS

  use App::RPGTool;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for App::RPGTool, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

U-Wesker\dave, E<lt>dave@nonetE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by U-Wesker\dave

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.22.1 or,
at your option, any later version of Perl 5 you may have available.


=cut

