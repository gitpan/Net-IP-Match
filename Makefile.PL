use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'Net::IP::Match',
    'VERSION_FROM'	=> 'Match.pm',
    'PREREQ_PM'		=> {
	Filter::Simple => 0.77,
    	Test::More     => 0.42,
    },
    dist                => {
        # don't ask about existing .tar.gz files
        COMPRESS => 'gzip --force --best'
    },
);
