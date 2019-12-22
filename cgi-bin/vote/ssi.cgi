#!/usr/bin/perl

use CGI;
require "sitevariables.pl";
require "common.pl";

$cur= CGI->new();

# global variables
$content = "";
$vote = $cur->param('vote');

$is_ssi = 'yes';
$save_width = $width+30;
$width = $ssi_width;

$content .= print_question();

printssi($content);

############# SUBROUTINES ################################

sub add_vote{
	open(DATAFILE,"<vote.dat");
	while(<DATAFILE>){
		chomp();
		($item,$no_votes) = split(/==/,$_);
		$votes{$item} = $no_votes;
	}
	close(DATAFILE);

	$votes{$vote}++; #increase the number of votes by one

	open(DATAFILE,">vote.dat");
	foreach $key (sort keys %votes){
		print DATAFILE "$key==$votes{$key}\n";
	}
	close(DATAFILE);
}

sub printssi{
	print "Content-type: text/html\n\n";
	print <<HTML;
$_[0]
HTML
}
