package Image::Empty;

use 5.006;
use strict;
use warnings;

=head1 NAME

Image::Empty - Empty/transparent 1x1 pixel images for use in tracking URLs.

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.05';

$VERSION = eval $VERSION;

=head1 SYNOPSIS

Create 1x1 pixel empty/transparent GIFs to use in tracking URLs.

 my $empty_gif = Image::Empty->gif;
 
 print CGI->new->header( -type => $empty_gif->type, -Content_length => $empty_gif->length );
 
 print $empty_gif->content;

Or

 my $gif = Image::Empty->gif;
 
 $gif->render( CGI->new );

Or, if running under Plack

 my $gif = Image::Empty->gif;
 
 return $gif->render( Plack::Response->new );

=cut

use Moose;

has type        => ( is => 'rw', isa => 'Str' );
has length      => ( is => 'rw', isa => 'Int' );
has disposition => ( is => 'rw', isa => 'Str' );
has filename    => ( is => 'rw', isa => 'Str' );
has content     => ( is => 'rw',              );

=head1 METHODS

=head2 Attributes

=head3 type

 $empty_image->type;

Returns the mime/type of the image for use in HTTP headers.

=cut

=head3 length

 $empty_image->length;

Returns the content length for use in HTTP headers.

=cut

=head3 disposition

 $empty_image->disposition;

Returns the content disposition for use in HTTP headers.

=cut

=head3 filename

 $empty_image->filename;

Returns the content filename for use in HTTP headers.

=cut

=head3 content

 $empty_image->content;

Returns the image data to send in the HTTP response body.

=cut

=head2 Class Methods

=head3 gif

 my $gif = Image::Empty->gif;

Returns an instance representing an empty GIF for use in responding to HTTP requests.

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

=head4 CGI

You can supply a C<CGI> object to the C<render> method to have the HTTP header and content set for you.

A string is returned for you to print, you can condense this down to a single line by chaining methods.

 print Image::Empty->gif->render( CGI->new );

It is the same as doing:

 my $gif = Image::Empty->gif;
 
 print CGI->new->header( -type                => $gif->type,
                         -Content_length      => $gif->length,
                         -Content_disposition => $gif->disposition . '; filename="' . $gif->filename . '"',
                       );
 
 print $gif->content;

=head4 Plack::Response

If you are working under Plack, this module supports that too.

This scenario returns the C<finalized> L<Plack::Response> object, as a quick one-liner...

 my $app = sub {

         return Image::Empty->gif->render( Plack::Response->new );
 }

It is the same as doing:

 my $app = sub {
 
         my $gif = Image::Empty->gif;
 
         my $response = Plack::Response->new;
         
         return $gif->render( $response );
 }

=cut

sub render
{
	my ( $self, $handler ) = @_;

	return '' unless $handler;
	
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
	
	return '';
}

=head1 TODO

* PNG support
* Catalyst support


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
