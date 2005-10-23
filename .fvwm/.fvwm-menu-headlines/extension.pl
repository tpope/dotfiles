$siteInfo->{"sexygeek"} = {
	'name' => "SexyGeek",
	'host' => "www.sexygeek.org",
	'path' => "/?q=node/feed",
	'func' => \&processSexyGeek,
	'flds' => 'title, link, description, category, pubDate',
};

sub processSexyGeek () {
    return processXml('item',
	{ 'h' => 'title', 'u' => 'link', 'd' => 'pubDate' },
	sub ($) {
	    $_[0] =~ /(\d+) (\w+) (\d+) (\d+):(\d+):(\d+)/;
	    ($3, $smonthHash{$2}, $1, $4, $5, $6);}
	,-5,
    );
};

sub processBBC () {
	readAllLines() =~ /STORY 1\nHEADLINE Last update at (\d+:\d+)\n\nURL \n(.*)$/s;
	my ($time, $contents) = ($1, $2);
	dieNet("Parse error. Did BBC site change format?", "") unless defined $time;
	my @entries = ();

	$contents =~ s{STORY (\d+)\nHEADLINE (.*?)\nURL (.*?)\n}{
		my $entry = {};
		my $date = undef;
		$entry->{'story'} = $1;
		my $headline = $2;
		my $url = $3;
		if ($headline =~ /^(.+?)  (\d+ \w+ \d+)$/) {
			$headline = $1;
			$date = $2 . " $time";
		}
		$entry->{'headline'} = $headline;
		$url =~ s|^(http://.*?/).*/-/(.*)$|$1$2|;
		$url = "http://www.bbc.co.uk/" if $url eq "";
		$entry->{'url'} = $url;
		$entry->{'date'} = $date;
		setEntryAliasesAndTime(
			$entry,
			{ 'h' => 'headline', 'u' => 'url', 'd' => 'date' },
			sub ($) {
				return () unless defined $_[0] &&
	         $_[0] =~ /^(\d+) (\w+) (\d+) (\d+):(\d+)/;
	         ($3, $lmonthHash{$2}, $1, $4, $5);
			}, +0,
		);
		push @entries, $entry;
		""
	}sige;

	return \@entries;
}

1;
