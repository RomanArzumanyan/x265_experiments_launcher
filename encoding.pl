use strict;
use X265_launcher;
use X265_msql_iface;
use X265_tbs_profiler;

sub println {
    print @_;
    print "\n";
}

#### Videos, no *.y4m extension ####
my @videos_720 = ( 
    "sintel_trailer_2k_720p24", 
    "720p5994_stockholm_ter" 
);

my @videos_1080 = (
	"pedestrian_area_1080p25", 
	"blue_sky_1080p25",
	"ducks_take_off_1080p50",  
	"park_joy_1080p50"
);

my @videos_2160 = ( 
    "ducks_take_off_2160p50", 
    "park_joy_2160p50" 
);

#### Coding parameters ####
my @qp_values = ( 22, 27, 32, 37 );
my $frame_num = 120;

#### IO parameters ####
my $raw_dir = "/home/roman/mnt_raw";
my $enc_dir = "/home/roman/Videos/x265";
my $csv_dir = "/home/roman/Documents/PhD/x265";
my $app_dir = "/home/roman/Install/x265_1.5/release_x86";

#### Interface to MySQL to store results ####
my $sql_iface = new X265_msql_iface( "localhost", "x265", "x265", "x265" );

foreach my $qp (@qp_values) {
	#### Encode 720p videos ####
	foreach my $video (@videos_720) {
		my $launcher = new X265_launcher(
			$app_dir . "/x265",
			$raw_dir . "/".$video.".y4m",
			$enc_dir . "/".$video.".x265",
			$csv_dir . "/".$video.".csv",
			1280,
			720,
			24,
			1,
			0,
			$qp,
			$frame_num
		);
		
		#Run encoder & insert record
		println $launcher->get_command();
		$launcher->encode( $app_dir . "/x265" );
		$sql_iface->insert_one_launch($launcher);
		
		#Run profiler & insert profile record
		my $profiler = new X265_tbs_profiler(
		  "/opt/AMD/CodeXL_1.6-7247/CodeXLCpuProfiler",
          "process", 
          $launcher, 
          $video,
          "/home/roman/Documents/PhD/x265/CodeXL_Profiler/".$video
		);
		
		println $profiler->get_coll_cmd();
		$profiler->collect("/opt/AMD/CodeXL_1.6-7247/CodeXLCpuProfiler");
        
        println $profiler->get_rep_cmd();
        $profiler->report( "/opt/AMD/CodeXL_1.6-7247/CodeXLCpuProfiler", "process" );
        
        $sql_iface->insert_one_profile($profiler);
	}
	
    #### Encode 1080p videos ####
    $frame_num = 60;
    foreach my $video (@videos_1080) {
        my $launcher = new X265_launcher(
            $app_dir . "/x265",
            $raw_dir . "/".$video.".y4m",
            $enc_dir . "/".$video.".x265",
            $csv_dir . "/".$video.".csv",
            1920,
            1080,
            24,
            1,
            0,
            $qp,
            $frame_num
        );
        
        #Run encoder & insert record
        println $launcher->get_command();
        $launcher->encode( $app_dir . "/x265" );
        $sql_iface->insert_one_launch($launcher);
        
        #Run profiler & insert profile record
        my $profiler = new X265_tbs_profiler(
          "/opt/AMD/CodeXL_1.6-7247/CodeXLCpuProfiler",
          "process", 
          $launcher, 
          $video,
          "/home/roman/Documents/PhD/x265/CodeXL_Profiler/".$video
        );
        
        println $profiler->get_coll_cmd();
        $profiler->collect("/opt/AMD/CodeXL_1.6-7247/CodeXLCpuProfiler");
        
        println $profiler->get_rep_cmd();
        $profiler->report( "/opt/AMD/CodeXL_1.6-7247/CodeXLCpuProfiler", "process" );
        
        $sql_iface->insert_one_profile($profiler);
    }
    
    #### Encode 2160 videos ####
    $frame_num = 15;
    foreach my $video (@videos_2160) {
        my $launcher = new X265_launcher(
            $app_dir . "/x265",
            $raw_dir . "/".$video.".y4m",
            $enc_dir . "/".$video.".x265",
            $csv_dir . "/".$video.".csv",
            3840,
            2160,
            24,
            1,
            0,
            $qp,
            $frame_num
        );
        
        #Run encoder & insert record
        println $launcher->get_command();
        $launcher->encode( $app_dir . "/x265" );
        $sql_iface->insert_one_launch($launcher);
        
        #Run profiler & insert profile record
        my $profiler = new X265_tbs_profiler(
          "/opt/AMD/CodeXL_1.6-7247/CodeXLCpuProfiler",
          "process", 
          $launcher, 
          $video,
          "/home/roman/Documents/PhD/x265/CodeXL_Profiler/".$video
        );
        
        println $profiler->get_coll_cmd();
        $profiler->collect("/opt/AMD/CodeXL_1.6-7247/CodeXLCpuProfiler");
        
        println $profiler->get_rep_cmd();
        $profiler->report( "/opt/AMD/CodeXL_1.6-7247/CodeXLCpuProfiler", "process" );
        
        $sql_iface->insert_one_profile($profiler);
    }	
}