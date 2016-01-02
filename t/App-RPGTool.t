# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl App-RPGTool.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use Data::Dumper;

use Test::More tests => 6;
BEGIN { use_ok('App::RPGTool') }
use App::RPGTool;
my $RPGTool = App::RPGTool->new( use_test_database => 1 );

$RPGTool->delete_all_characters();
is( scalar $RPGTool->characters_hash(),
    0, 'Character list should be empty after delete' );

my $new_character = 'Phil';
$RPGTool->add_character($new_character);
my $is_active = $RPGTool->is_active($new_character);
is( $is_active, 1, "Check for $new_character" );

my %ch = $RPGTool->characters_hash();
is( $ch{$new_character}, 1, "Check for $new_character" );

$RPGTool->deactivate($new_character);
$is_active = $RPGTool->is_active($new_character);
is( $is_active, 0, "Check deactivate for $new_character" );

$RPGTool->delete_character($new_character);
$is_active = $RPGTool->is_active($new_character);
ok( !defined $is_active, "Check $new_character deleted" );

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

