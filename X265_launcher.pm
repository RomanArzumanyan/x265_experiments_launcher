#H265 encoder launcher
package X265_launcher;
{
	use strict;
	use warnings;

	sub new {
		my $class = shift;

		my $self = {
			enc   => shift,    #Encoder app
			ifile => shift,    #Input file
			ofile => shift,    #Output file
			csv   => shift,    #CSV file with encoding report
			res_x => shift,    #Width
			res_y => shift,    #Height
			fps   => shift,    #FPS
			psnr  => shift,    #PSNR control
			aq    => shift,    #Adaptive quantization control
			qp    => shift,    #QP patameter
			frm   => shift,    #Frames to be encoded
		};

		bless $self, $class;
		return $self;
	}

	sub get_encoder {
		my $self = shift;
		return $self->{enc};
	}

	sub set_encoder {
		my $self = shift;
		$self->{enc} = shift;
	}

	sub get_ifile {
		my $self = shift;
		return $self->{ifile};
	}

	sub set_ifile {
		my $self = shift;
		$self->{ifile} = shift;
	}

	sub get_ofile {
		my $self = shift;
		return $self->{ofile};
	}

	sub set_ofile {
		my $self = shift;
		$self->{ofile} = shift;
	}

	sub get_fps {
		my $self = shift;
		return $self->{fps};
	}

	sub set_fps {
		my $self = shift;
		$self->{fps} = shift;
	}

	sub get_res_x {
		my $self = shift;
		return $self->{res_x};
	}

	sub set_res_x {
		my $self = shift;
		$self->{res_x} = shift;
	}

	sub get_res_y {
		my $self = shift;
		return $self->{res_y};
	}

	sub set_res_y {
		my $self = shift;
		$self->{res_y} = shift;
	}

	sub get_csv {
		my $self = shift;
		return $self->{csv};
	}

	sub set_csv {
		my $self = shift;
		$self->{csv} = shift;
	}

	sub get_psnr {
		my $self = shift;
		return $self->{psnr};
	}

	sub set_psnr {
		my $self = shift;
		$self->{psnr} = shift;
	}

	sub get_aq {
		my $self = shift;
		return $self->{aq};
	}

	sub set_aq {
		my $self = shift;
		$self->{aq} = shift;
	}

	sub get_qp {
		my $self = shift;
		return $self->{qp};
	}

	sub set_qp {
		my $self = shift;
		$self->{qp} = shift;
	}

	sub get_frm {
		my $self = shift;
		return $self->{frm};
	}

	sub set_frm {
		my $self = shift;
		$self->{frm} = shift;
	}

	sub get_param_string {
		my $self  = shift;
		my $param = shift;
		if ( $param eq "ifile" ) {
			return $self->get_ifile();
		}
		elsif ( $param eq "ofile" ) {
			return "--output " . $self->get_ofile();
		}
		elsif ( $param eq "res" ) {
			return
			    "--input-res "
			  . $self->get_res_x() . "x"
			  . $self->get_res_y();
		}
		elsif ( $param eq "fps" ) {
			return "--fps " . $self->get_fps();
		}
		elsif ( $param eq "csv" ) {
			return "--csv " . $self->get_csv();
		}
		elsif ( $param eq "psnr" ) {
			if ( $self->get_psnr() == 1 ) {
				return "--psnr";
			}
			else {
				return "--no-psnr";
			}
		}
		elsif ( $param eq "aq" ) {
			return "--aq-mode " . $self->get_aq();
		}
		elsif ( $param eq "qp" ) {
			return "-q " . $self->get_qp();
		}
		elsif ( $param eq "frm" ) {
			return "-f " . $self->get_frm();
		}
		else {
			return undef;
		}
	}

	sub get_command {
		my $self = shift;

		my $command =
		    $self->get_encoder() . ' '
		  . $self->get_param_string("ifile") . ' '
		  . $self->get_param_string("ofile") . ' '
		  . $self->get_param_string("res") . ' '
		  . $self->get_param_string("fps") . ' '
		  . $self->get_param_string("csv") . ' '
		  . $self->get_param_string("psnr") . ' '
		  . $self->get_param_string("aq") . ' '
		  . $self->get_param_string("qp") . ' '
		  . $self->get_param_string("frm");

		return $command;
	}

	sub encode {
		my $self = shift;
		if ( system $self->get_command() ) {
			die $?;
		}
	}
	
	sub get_result_filename{
		my $self = shift;
		return $self->get_csv();
	}
}

1;
