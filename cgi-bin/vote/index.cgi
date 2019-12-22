#!/usr/bin/perl

use CGI;
require "sitevariables.pl";
require "common.pl";

$cur= CGI->new();

# global variables
$content = "";
$save_width = $width+30;
$vote = $cur->param('vote');
$view = $cur->param('view');

if($vote){

	checkip();

	$found =0;
	foreach (@answers){
		if($_ eq $vote){$found=1;}
	}
	unless($found){ # it matches one of the things we can vote for
		dienice("You tried to vote for something that is not allowed.<br>
		<br>
		If you feel you have gotten this in error, please contact the webmaster.","template.html");
	}
	add_vote($vote);
	$content .= print_results();
}elsif($view){
	$content .= print_results();
}else{
	$content .= print_question();
}



printpage($content,"template.html");

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

