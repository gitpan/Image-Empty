use strict;
use warnings;

use Test::More;
use Test::Exception;
use MIME::Base64;

use Image::Empty;

my $png;

lives_ok { $png = Image::Empty->png } "instantiated png ok";

ok( $png->type eq 'image/png', "type" );

ok( $png->length == 67, "length" );

ok( $png->disposition eq 'inline', "disposition" );

ok( $png->filename eq 'empty.png', "filename" );

my $output = $png->render;

my $static = 'Content-Type: ' . 'image/png' . "\r\n" .
	       'Content-Length: ' . 67 . "\r\n" .
	       'Content-Disposition: ' . 'inline' . '; filename="' . 'empty.png' . '"' .
	       "\r\n\r\n" . decode_base64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==');
    
ok( $output eq $static, "rendered output looks good" );

done_testing();
