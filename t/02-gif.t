use strict;
use warnings;

use Test::More;
use Test::Exception;

use Image::Empty;

my $gif;

lives_ok { $gif = Image::Empty->gif } "instantiated gif ok";

ok( $gif->type eq 'image/gif', "type" );

ok( $gif->length == 43, "length" );

ok( $gif->disposition eq 'inline', "disposition" );

ok( $gif->filename eq 'empty.gif', "filename" );



done_testing();
