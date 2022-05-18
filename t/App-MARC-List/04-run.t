use strict;
use warnings;

use App::MARC::List;
use English;
use File::Object;
use File::Spec::Functions qw(abs2rel);
use Perl6::Slurp qw(slurp);
use Test::More 'tests' => 4;
use Test::NoWarnings;
use Test::Output;

my $data_dir = File::Object->new->up->dir('data');
my $script = abs2rel(File::Object->new->file('04-run.t')->s);
# XXX Hack for missing abs2rel on Windows.
if ($OSNAME eq 'MSWin32') {
	$script =~ s/\\/\//msg;
}

# Test.
@ARGV = (
	'-h',
);
my $right_ret = <<"END";
Usage: $script [-h] [--version] marc_xml_file field subfield
	-h		Print help.
	--version	Print version.
	marc_xml_file	MARC XML file.
	field		MARC field.
	subfield	MARC subfield.
END
stderr_is(
	sub {
		App::MARC::List->new->run;
		return;
	},
	$right_ret,
	'Run help.',
);

# Test.
@ARGV = (
	$data_dir->file('ex1.xml')->s,
	'015',
	'a',
);
$right_ret = <<'END';
cnb000000096
END
stdout_is(
	sub {
		App::MARC::List->new->run;
		return;
	},
	$right_ret,
	'Run list for MARC XML file with 1 record (015a = cnb000000096).',
);

# Test.
@ARGV = (
	$data_dir->file('ex2.xml')->s,
	'015',
	'a',
);
stderr_like(
	sub {
		App::MARC::List->new->run;
		return;
	},
	qr{^Cannot process '1' record\. Error: Field 300 must have indicators \(use ' ' for empty indicators\)},
	'Run filter for MARC XML file with 1 record (with error).',
);
