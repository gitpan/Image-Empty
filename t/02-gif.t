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


my $output = $gif->render;

my $static = 'Content-Type: ' . 'image/gif' . "\n" .
	       'Content-Length: ' . 43 . "\n" .
	       'Content-Disposition: ' . 'inline' . '; filename="' . 'empty.gif' . '"' .
	       "\n\n" . sprintf( "GIF89a\1\0\1\0%c\0\0%c%c%c\0\0\0%s,\0\0\0\0\1\0\1\0\0%c%c%c\1\0;", 144, 0, 0, 0, pack("U8", 33, 249, 4, 5, 16, 0, 0, 0), 2, 2, 4 );
	       
ok( $output eq $static, "rendered output looks good" );



done_testing();
