use strict;
use warnings;
use X265_msql_iface;
use X265_reporter;

sub println {
	print @_;
	print "\n";
}

my $sql_iface = new X265_msql_iface( "localhost", "x265", "x265", "x265" );
my $reporter = new X265_reporter($sql_iface);

$reporter->get_top_functions(
	10,
	"2015-04-22 00:00:00",
	"2015-04-23 23:59:59"
);
