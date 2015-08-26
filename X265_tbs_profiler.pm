#Time-Based-Samples profiler, derived from  X265_profiler
package X265_tbs_profiler;
{
	use strict;
	use warnings;
	use base ("X265_profiler");

	sub new {
		my $class = shift;
		my $self  = $class->SUPER::new(@_);
		$self->{mode} = "-m tbp";
		return $self;
	}

	sub get_mode {
		my $self = shift;
		return $self->{mode};
	}

	sub set_mode {
		my $self = shift;
		$self->{mode} = shift;
	}

	sub get_coll_cmd {
		my $self = shift;
		return
		    $self->get_app()
		  . ' collect '
		  . $self->get_mode() . ' -o '
		  . $self->get_coll_out_fname() . ' -G '
		  . $self->{launcher}->get_command();
	}

	sub collect {
		my $self = shift;

		#Check if output directory exists, mkdir otherwise
		if ( -e $self->get_rep_out_dir() ) {
			if ( -f $self->get_rep_out_dir() ) {
				croak("$self->get_coll_out_fname() is a file, not directory.");
				return 1;
			}
		}
		else {
			mkdir $self->get_rep_out_dir() || die $!;
		}

		if ( system $self->get_coll_cmd() ) {
			die $?;
		}
	}
}

1;
