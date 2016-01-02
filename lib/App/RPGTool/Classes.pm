package App::RPGTool::Classes;

use 5.022001;
use strict;
use warnings;

our $VERSION = '0.01';

package App::RPGTool::Character;
use Moose;

has 'active_flag' => ( isa => 'Bool', is => 'rw', required => 1, default => 1 );
has 'player' => ( isa => 'Str', is => 'rw', required => 1 );

package App::RPGTool::Monster;
use Moose;

has 'z' => ( isa => 'Int', is => 'rw', required => 1 );

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

