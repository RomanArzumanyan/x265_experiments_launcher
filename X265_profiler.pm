#Performance profiler
package X265_profiler;
{
	use strict;
	use warnings;
	use File::Copy;
	use X265_launcher;

	sub new {
		my $class = shift;

		my $self = {
			app            => shift,   #Profiler application
			report_option  => shift,   #Options to profile reporter
			launcher       => shift,   #Reference to X265_launcher
			coll_out_fname => shift,   #Base name for files with profile results
			rep_out_dir    => shift,   #Where report files will be stored
			app_cmd        => "",      #Application launch string
			rep_inp_fname  => "",      #Report input filename
		};

		#Add directory name to filename
		$self->{coll_out_fname} =
		  $self->{rep_out_dir} . '/' . $self->{coll_out_fname};

		#Report input file supposed to be same to collect output.
		#Suitable file is one with .caperf extension
		$self->{rep_inp_fname} = $self->{coll_out_fname} . '.caperf';

		bless $self, $class;
		return $self;
	}

	sub get_app {
		my $self = shift;
		return $self->{app};
	}

	sub set_app {
		my $self = shift;
		$self->{app} = shift;
	}

	sub get_report_option {
		my $self = shift;
		return $self->{report_option};
	}

	sub set_report_option {
		my $self = shift;
		$self->{report_option} = shift;
	}

	sub get_rep_cmd {
		my $self = shift;
		return
		    $self->get_app()
		  . ' report -i '
		  . $self->get_rep_inp_fname() . ' -o '
		  . $self->get_rep_out_dir() . ' -R '
		  . $self->get_report_option();
	}

	sub report {
		my $self       = shift;
		my $report_opt = $self->get_report_option();

		if    ( $report_opt eq "overview" )  { }
		elsif ( $report_opt eq "process" )   { }
		elsif ( $report_opt eq "module" )    { }
		elsif ( $report_opt eq "callgraph" ) { }
		elsif ( $report_opt eq "all" )       { }
		else {
			die "Unsupported regime: $report_opt";
		}

		unless ( -e $self->get_rep_inp_fname() ) {
			croak( "File " . $self->get_rep_inp_fname() . " doens't exist." );
			return 1;
		}

		if ( -z $self->get_rep_inp_fname() ) {
			croak( "File " . $self->get_rep_inp_fname() . " is empty." );
			return 1;
		}

		if ( system $self->get_rep_cmd() ) {
			die $?;
		}

		#Profiler will put results in subfolder, we need to extract it
		#Cut out file extension
		my $tmp_dir = substr( $self->get_rep_inp_fname(), 0, -7 );

		#Copy files in parent folder one by one & remove after copy
		my $dst_dir = $tmp_dir . '/..';
		opendir( my $dir, $tmp_dir ) || die "can't opendir $tmp_dir: $!";
		my @files = readdir($dir);
		foreach my $t (@files) {
			if ( -f "$tmp_dir/$t" ) {

				#Check with -f only for files (no directories)
				#Only .csv file is needed
				if ( $t =~ /\.csv$/i ) {
					copy "$tmp_dir/$t", "$dst_dir/$t";
				}
				unlink "$tmp_dir/$t";
			}
		}

		#remove folder, which must be empty
		rmdir $tmp_dir;
	}

	sub get_launcher {
		my $self = shift;
		return $self->{launcher};
	}

	sub set_launcher {
		my $self = shift;
		$self->{launcher} = shift;
	}

	sub get_rep_out_dir {
		my $self = shift;
		return $self->{rep_out_dir};
	}

	sub set_rep_out_dir {
		my $self = shift;
		$self->{rep_out_dir} = shift;
	}

	sub get_rep_inp_fname {
		my $self = shift;
		return $self->{rep_inp_fname};
	}

	sub set_rep_inp_fname {
		my $self = shift;
		$self->{rep_inp_fname} = shift;
	}

	sub get_coll_out_fname {
		my $self = shift;
		return $self->{coll_out_fname};
	}

	sub set_coll_out_fname {
		my $self = shift;
		$self->{coll_out_fname} = shift;
	}

	sub get_result_filename {
		my $self = shift;
		return $self->get_coll_out_fname() . '.csv';
	}
}

1;
