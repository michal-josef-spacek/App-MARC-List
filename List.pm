package App::MARC::List;

use strict;
use warnings;

use Class::Utils qw(set_params);
use English;
use Error::Pure qw(err);
use Getopt::Std;
use List::MoreUtils qw(uniq);
use MARC::File::XML (BinaryEncoding => 'utf8', RecordFormat => 'MARC21');
use Unicode::UTF8 qw(decode_utf8 encode_utf8);

our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Process parameters.
	set_params($self, @params);

	# Object.
	return $self;
}

# Run.
sub run {
	my $self = shift;

	# Process arguments.
	$self->{'_opts'} = {
		'h' => 0,
	};
	if (! getopts('h', $self->{'_opts'}) || @ARGV < 1
		|| $self->{'_opts'}->{'h'}) {

		print STDERR "Usage: $0 [-h] [--version] marc_xml_file field subfield\n";
		print STDERR "\t-h\t\tPrint help.\n";
		print STDERR "\t--version\tPrint version.\n";
		print STDERR "\tmarc_xml_file\tMARC XML file.\n";
		print STDERR "\tfield\t\tMARC field.\n";
		print STDERR "\tsubfield\tMARC subfield.\n";
		return 1;
	}
	$self->{'_marc_xml_file'} = shift @ARGV;
	$self->{'_marc_field'} = shift @ARGV;
	$self->{'_marc_subfield'} = shift @ARGV;

	if (! defined $self->{'_marc_field'}
		|| ! defined $self->{'_marc_subfield'}) {

		err "Field and subfield is required.";
	}

	my $marc_file = MARC::File::XML->in($self->{'_marc_xml_file'});
	my $ret_hr = {};
	my $num = 1;
	my $previous_record;
	while (1) {
		my $record = eval {
			$marc_file->next;
		};
		if ($EVAL_ERROR) {
			print STDERR "Cannot process '$num' record. ".
				"Previous record is ".$previous_record->title."\n";
			print STDERR "Error: $EVAL_ERROR\n";
			next;
		}
		if (! defined $record) {
			last;
		}
		$previous_record = $record;
		# TODO Multiple values
		my $field = $record->field($self->{'_marc_field'});
		if (defined $field) {
			# TODO Multiple values
			my $subfield_value = $field->subfield($self->{'_marc_subfield'});
			if (defined $subfield_value && ! exists $ret_hr->{$subfield_value}) {
				$ret_hr->{$subfield_value} = $subfield_value;
			}
		}
		$num++;
	}

	# Print out.
	print join "\n", map { encode_utf8($_) } uniq sort keys %{$ret_hr};
	print "\n";
	
	return 0;
}

1;


__END__

=pod

=encoding utf8

=head1 NAME

App::MARC::XML2JSON - Base class for cpan-get script.

=head1 SYNOPSIS

 use App::MARC::XML2JSON;

 my $app = App::MARC::XML2JSON->new;
 my $exit_code = $app->run;

=head1 METHODS

=head2 C<new>

 my $app = App::MARC::XML2JSON->new;

Constructor.

Returns instance of object.

=head2 C<run>

 my $exit_code = $app->run;

Run.

Returns 1 for error, 0 for success.

=head1 ERRORS

 new():
         From Class::Utils::set_params():
                 Unknown parameter '%s'.

 run():
         TODO

=head1 EXAMPLE

 use strict;
 use warnings;

 use App::MARC::XML2JSON;

 # Arguments.
 @ARGV = (
         'App::Pod::Example',
 );

 # Run.
 exit App::MARC::XML2JSON->new->run;

 # Output like:
 # Package on 'http://cpan.metacpan.org/authors/id/S/SK/SKIM/App-Pod-Example-0.19.tar.gz' was downloaded.

=head1 DEPENDENCIES

L<Class::Utils>,
L<Error::Pure>,
L<Getopt::Std>,
L<IO::Barf>,
L<LWP::UserAgent>
L<Menlo::Index::MetaCPAN>
L<URI::cpan>.

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/App-MARC-XML2JSON>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2022 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.01

=cut
