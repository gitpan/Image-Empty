package Image::Empty;

use 5.006;
use strict;
use warnings;

=head1 NAME

Image::Empty - Hassle-free empty/transparent 1x1 pixel images for tracking URLs.

=head1 VERSION

Version 0.12

=cut

our $VERSION = '0.12';

$VERSION = eval $VERSION;

=head1 SYNOPSIS

Create 1x1 pixel empty/transparent GIFs to use in tracking URLs without the hassle of actually creating and/or loading image data.

 use Image::Empty;
 
 my $cgi = CGI->new;
 
 my $gif = Image::Empty->gif;
 
 print $cgi->header( -type => $gif->type, -Content_length => $gif->length );
 
 print $gif->content;

Or a bit shorter...

 my $gif = Image::Empty->gif;
 
 print $gif->render( CGI->new );

Or, if you do not want the dependency on the C<CGI> module...

 my $gif = Image::Empty->gif;
 
 print $gif->render;
 
Or, if you are working with Plack...

 my $gif = Image::Empty->gif;
 
 return $gif->render( Plack::Response->new );

=cut

=head1 METHODS

=head2 Class Methods

=head3 new

Returns an instance representing an image.

 my $empty = Image::Empty->new;

=cut

sub new
{
	my ( $class, %args ) = @_;
	
	my $self = { type        => $args{ type },
	             length      => $args{ length },
	             disposition => $args{ disposition },
	             filename    => $args{ filename },
	             content     => $args{ content },
	           };
	
	bless( $self, $class );
	
	return $self;
}

=head3 gif

Returns an instance representing an empty GIF for use in an HTTP response.

 my $gif = Image::Empty->gif;

=cut

sub gif
{
	my ( $class, %args ) = @_;

	return $class->new( type        => 'image/gif',
	                    length      => 43,
	                    disposition => 'inline',
	                    filename    => 'empty.gif',
	                    content     => sprintf( "GIF89a\1\0\1\0%c\0\0%c%c%c\0\0\0%s,\0\0\0\0\1\0\1\0\0%c%c%c\1\0;", 144, 0, 0, 0, pack("U8", 33, 249, 4, 5, 16, 0, 0, 0), 2, 2, 4 ),
	                  );
}

=head2 Instance Methods

=head3 render

The C<render> method can be used as a shortcut to set the HTTP headers and body when responding with the empty GIF.

A string is returned.

Under a CGI environment this would generally be printed direct to C<STDOUT> (ie, the browser).

Chaining the methods together can make the usage very compact.

 use Image::Empty;
 
 print Image::Empty->gif->render;

Remember that the C<render> method sets the HTTP headers for you, so you do not need to worry about this yourself.

=head4 CGI

If you already have an instance of the C<CGI> object in your code, you can pass this instance to the render method, to have it use the C<CGI-\>header> method.

As above, a string is returned.

 print Image::Empty->gif->render( CGI->new );

It is the same as doing...

 my $cgi = CGI->new;
 
 my $gif = Image::Empty->gif;
 
 print $cgi->header( -type                => $gif->type,
                     -Content_length      => $gif->length,
                     -Content_disposition => $gif->disposition . '; filename="' . $gif->filename . '"',
                   );
 
 print $gif->content;

=head4 Plack

If you are working with Plack, we support that too.

The C<render> method in this scenario returns the C<finalized> L<Plack::Response> object, as a quick one-liner...

 my $app = sub {

         return Image::Empty->gif->render( Plack::Response->new );
 }

It is the same as doing...

 my $app = sub {
 
         my $gif = Image::Empty->gif;
 
         my $response = Plack::Response->new;
 
         $response->status(200);
 
         $response->content_type( $gif->type );
         $response->content_length( $gif->length );
 
         $response->header( 'Content-disposition' => $gif->disposition . '; filename="' . $gif->filename . '"' );
 
         $response->body( $gif->content ); 
 
         return $response->finalize;
 }

=cut

sub render
{
	my ( $self, $handler ) = @_;
	
	if ( ref $handler eq 'CGI' )
	{
		return $handler->header( -type => $self->type, -Content_length => $self->length, -Content_disposition => $self->disposition . '; filename="' . $self->filename . '"' )
		     . $self->content;
	}

	if ( ref $handler eq 'Plack::Response' )
	{
		$handler->status(200);
	
		$handler->content_type(   $self->type   );
		$handler->content_length( $self->length );
	
		$handler->header( 'Content-disposition' => $self->disposition . '; filename="' . $self->filename . '"' );

		$handler->body( $self->content );
		
		return $handler->finalize;
	}
	
	return 'Content-Type: ' . $self->type . "\n" .
	       'Content-Length: ' . $self->length . "\n" .
	       'Content-disposition: ' . $self->disposition . '; filename="' . $self->filename . '"' .
	       "\n\n" .
	       $self->content;
}

=head2 Attributes

=head3 type

 $gif->type;

Returns the mime/type of the image for use in HTTP headers.

=cut

sub type
{
	my ( $self, $arg ) = @_;
	$self->{ type } = $arg if defined $arg;
	return $self->{ type };
}

=head3 length

 $gif->length;

Returns the content length for use in HTTP headers.

=cut

sub length
{
	my ( $self, $arg ) = @_;
	$self->{ length } = $arg if defined $arg;
	return $self->{ length };
}

=head3 disposition

 $gif->disposition;

Returns the content disposition for use in HTTP headers.

=cut

sub disposition
{
	my ( $self, $arg ) = @_;
	$self->{ disposition } = $arg if defined $arg;
	return $self->{ disposition };
}

=head3 filename

 $gif->filename;

Returns the content filename for use in HTTP headers.

=cut

sub filename
{
	my ( $self, $arg ) = @_;
	$self->{ filename } = $arg if defined $arg;
	return $self->{ filename };
}

=head3 content

 $gif->content;

Returns the image data to send in the HTTP response body.

=cut

sub content
{
	my ( $self, $arg ) = @_;
	$self->{ content } = $arg if defined $arg;
	return $self->{ content };
}

=head1 TODO

mod_perl support

PNG support

Catalyst support


=head1 AUTHOR

Rob Brown, C<< <rob at intelcompute.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-image-empty at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Image-Empty>.  I will be notified, and then you will
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Image::Empty


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Image-Empty>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Image-Empty>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Image-Empty>

=item * Search CPAN

L<http://search.cpan.org/dist/Image-Empty/>

=back


=head1 ACKNOWLEDGEMENTS

I can not actually remember where the original line came from to produce the gif content.

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Rob Brown.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;
