#This package add information about X265 encoder launches and profiles to
#MySQL table
package X265_msql_iface;
{
	use strict;
	use warnings;
	use DBI;
	use DBD::mysql;
	use Text::CSV_XS;
	use X265_launcher;
	use POSIX qw(strftime);
	use DateTime::Format::Strptime qw( );

	sub new {
		my $class = shift;

		my $self = {
			host     => shift,
			db       => shift,
			user     => shift,
			password => shift,
			conn     => undef,
		};

		my $conn_info = "dbi:mysql:" . $self->{db} . ";" . $self->{host};
		$self->{conn} =
		  DBI->connect( $conn_info, $self->{user}, $self->{password} );
		bless $self, $class;
		return $self;
	}

	sub insert_one_launch {
		my $self     = shift;
		my $launcher = shift;
		my $line;
		my @fields;

		#Take last line from the file
		open( my $handle, '<', $launcher->get_result_filename() ) or die $!;
		while ( $line = <$handle> ) {
			chomp($line);
			@fields = split( /,/, $line );
		}

		#Remove leading & trailing whitespaces, converting empty fields to zeros
		foreach my $field (@fields) {
			$field =~ s/^\s+|\s+$//g;
			if ( $field eq "-" ) {
				$field = 0.0;
			}
		}

		#Parse datetime & change it to POSIX format.
		my $parser = DateTime::Format::Strptime->new(
			pattern  => '%a %b %e %T %Y',
			on_error => 'croak',
		);

		my $datetime = $parser->parse_datetime( $fields[1] );
		$fields[1] = $datetime->strftime("%F %T");

		#Insert it into the table
		my $query =
		    "insert into launch("
		  . " command, datetime, elapsed_time, fps, bitrate, y_psnr, u_psnr,"
		  . " v_psnr, global_psnr, ssim, ssim_db, i_count, i_ave_qp, i_kbps,"
		  . " i_psnr_y, i_psnr_u, i_psnr_v, i_ssim_db, p_count, p_ave_qp, p_kbps,"
		  . " p_psnr_y, p_psnr_u, p_psnr_v, p_ssim_db, b_count, b_ave_qp, b_kbps,"
		  . " b_psnr_y, b_psnr_u, b_psnr_v, b_ssim_db, version)"
		  . " values ("
		  . " \'$fields[0]\',  \'$fields[1]\',  \'$fields[2]\',  \'$fields[3]\',"
		  . " \'$fields[4]\',  \'$fields[5]\',  \'$fields[6]\',  \'$fields[7]\',"
		  . " \'$fields[8]\',  \'$fields[9]\',  \'$fields[10]\', \'$fields[11]\',"
		  . " \'$fields[12]\', \'$fields[13]\', \'$fields[14]\', \'$fields[15]\',"
		  . " \'$fields[16]\', \'$fields[17]\', \'$fields[18]\', \'$fields[19]\',"
		  . " \'$fields[20]\', \'$fields[21]\', \'$fields[22]\', \'$fields[23]\',"
		  . " \'$fields[24]\', \'$fields[25]\', \'$fields[26]\', \'$fields[27]\',"
		  . " \'$fields[28]\', \'$fields[29]\', \'$fields[30]\', \'$fields[31]\',"
		  . " \'$fields[32]\')";

		my $statement = $self->{conn}->prepare($query);
		unless ( $statement->execute() ) {
			die $statement->errstr;
		}
	}

	sub insert_one_profile {
		my $self     = shift;
		my $profiler = shift;
		my @temp;
		my $line;
		my $start_time;
		my $end_time;

		#Datetime parser
		my $parser = DateTime::Format::Strptime->new(
			pattern  => '%b-%d-%Y_%H-%M-%S',
			on_error => 'croak',
		);

		open( my $handle, '<', $profiler->get_result_filename() ) or die $!;
		while ( $line = <$handle> ) {
			chomp($line);
			@temp = split( /,/, $line );

			foreach my $field (@temp) {
				$field =~ s/^\s+|\s+$//g;
			}

			#Extract start & end time
			if ( $temp[0] eq "Profile Start Time:" ) {
				my $datetime = $parser->parse_datetime( $temp[1] );
				$start_time = $datetime->strftime("%F %T");
			}
			if ( $temp[0] eq "Profile End Time:" ) {
				my $datetime = $parser->parse_datetime( $temp[1] );
				$end_time = $datetime->strftime("%F %T");
			}

			#We need to extract function chart. Lines above arn't interesting.
			if (    ( $temp[0] eq "FUNCTION" )
				and ( $temp[1] eq "Timer" )
				and ( $temp[2] eq "MODULE" ) )
			{
				last;
			}
		}

		my $name = $profiler->get_launcher()->get_command();

		#Now go the fileds that we need
		while ( $line = <$handle> ) {
			chomp($line);
			@temp = split( /,/, $line );

			#Last element of array is module name, we don't need it
			pop @temp;

			#Then function counter
			my $time = pop @temp;
			$time =~ s/^\s+|\s+$//g;

			#Last elements made function name (consist commas), restore them
			for my $i ( 0 .. $#temp - 1 ) {
				$temp[$i] = $temp[$i] . ",";
			}

			my $function = join( '', @temp[ 0 .. $#temp ] );
			$function =~ s/^\s+|\s+$//g;

            my $launcher = $profiler->get_launcher();
			my $query =
			    "insert into profile("
			  . "name, start_time, end_time, function, timer, res_y, qp) values("
			  . "\'$name\', \'$start_time\', \'$end_time\', \'$function\', \'$time\'"
			  . ", \'".$launcher->get_res_y()."\', \'".$launcher->get_qp()."\')";
			my $statement = $self->{conn}->prepare($query);
			unless ( $statement->execute() ) {
				die $statement->errstr;
			}
		}
	}

	sub DESTROY {
		my $self = shift;
		$self->{conn}->disconnect();
	}
}

1;
