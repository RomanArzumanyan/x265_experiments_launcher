#This package add information about X265 encoder launches and profiles to
#MySQL table
package X265_reporter;
{
	use strict;
	use warnings;
	use DBI;
	use DBD::mysql;
	use X265_msql_iface;

	sub new {
		my $class = shift;

		my $self = { sql_iface => shift };

		bless $self, $class;
		return $self;
	}

	sub get_top_functions {
		my $self      = shift;
		my $num_func  = shift;
		my $date_from = shift;
		my $date_till = shift;

		#get distinct profile dates in given range
		my $query =
		    "select distinct start_time from x265.profile "
		  . "where start_time > \'"
		  . $date_from
		  . "\' and start_time < \'"
		  . $date_till . "\'"
		  . " order by start_time desc;";

		my $statement = $self->{sql_iface}->{conn}->prepare($query);
		unless ( $statement->execute() ) {
			die $statement->errstr;
		}

		my ( @row, @rows );
		while ( @row = $statement->fetchrow_array() ) {
			push( @rows, join( ", ", @row ) );
		}

		#get top profile functions for each profile
		foreach my $start_time (@rows) {
			#Get profile command name
			$query =
			    "select distinct name from x265.profile "
			  . "where start_time = \'"
			  . $start_time . "\';";
			
			$statement = $self->{sql_iface}->{conn}->prepare($query);
			unless ( $statement->execute() ) {
				die $statement->errstr;
			}
			
			@row = $statement->fetchrow_array();
			print "----" . $start_time . ", " . join( ", ", @row ) . "----\n";

            #Get profile results
			$query =
			    "select function, timer from x265.profile "
			  . "where start_time = \'"
			  . $start_time . "\' "
			  . "order by start_time, timer desc limit "
			  . $num_func . ";";

			$statement = $self->{sql_iface}->{conn}->prepare($query);
			unless ( $statement->execute() ) {
				die $statement->errstr;
			}

			while ( @row = $statement->fetchrow_array() ) {
				print "\t", join( ", ", @row ), "\n";
			}

			print "\n\n";
		}
	}
}

1;
