sub checkip {
	if($lockhours){
		my $ip = $ENV{"REMOTE_ADDR"};
		my $time = time();
		my ($logged_time,$logged_ip);
		
		if (open(LOGINFILE, "<./ip.log") ) {
			flock(LOGINFILE, 2);
			while (<LOGINFILE>) {
				chomp $_;
				($logged_time,$logged_ip) = split(/==/,$_);
				
				#last vote from that IP address
				if (($logged_ip eq $ip) && (($time-$logged_time) < ($lockhours*3600) )) {
				dienice("Someone from your IP address has already voted recently.  This is a measure to prevent folks from voting multiple times. Thank you for voting.<br><br><br>","template.html");
				}
			}
			flock(LOGINFILE, 8);
			close LOGINFILE;
		}
		open(LOGOUTFILE,">>./ip.log");
		flock(LOGOUTFILE, 2);
		print LOGOUTFILE "$time==$ip\n";
		flock(LOGOUTFILE, 8);
		close(LOGOUTFILE);
	}	
}


sub print_results{
	my $return;
	my $largest = 0;
	my ($item,$no_votes);
	my $total=0;
	my $font_question_close = "";
	my $font_answers_close = "";

	if($is_ssi){
		$font_question = $ssi_font_question;
		$font_answers = $ssi_font_answers;
	}
	if($font_question){$font_question_close ="</font>";}
	if($font_answers){$font_answers_close ="</font>";}

	if($cur->param('back')){
		$back = $cur->param('back');
		$back = "<a href=\'$back\'>back</a>";
	}
	if($close_button =~ /yes/i){
		$close = <<HTML;
<a href="javascript:window.close();">close</a>
HTML
	}

	$return = <<HTML;
<table width="$width" bgcolor="$border_color" cellpadding=0 cellspacing=1><tr><td>
<table width=100% bgcolor="$background_color" cellspacing=0 cellpadding=2>
<tr bgcolor="$border_color"><td>$font_question<b>$question</b>$font_question_close</td></tr>
<tr><td>
	<table cellpadding=10><tr><td>
HTML

	open(DATAFILE,"<vote.dat");
	while(<DATAFILE>){
		chomp();
		($item,$no_votes) = split(/==/,$_);
		$votes{$item} = $no_votes;
		if($no_votes > $largest){$largest = $no_votes;}
		$total = $total + $no_votes;
	}
	close(DATAFILE);

	$return .= "<table width=\"100%\">";
	#foreach $key (sort keys %votes){
	$font_answers_white = $font_answers;
	if($font_answers_white){
		$font_answers_white =~ s/<font (.*)>/<font $1 color=white>/;
	}else{
		$font_answers_white = "<font color=white>";
	}
	foreach $key (@answers){
		$no_votes = $votes{$key};
		
		$bar_width = int(($width/2)*$no_votes/$largest);
		if($bar_width > 20){
			$spercent = sprintf("$font_answers_white%.0f\%$font_answers_close",$no_votes/$total*100);
		}elsif($bar_width){
			$spercent = "&nbsp;";
		}
		
		if($bar_width){
			$return .= <<HTML;
		<tr><td>$font_answers$key$font_answers_close</td>
		<td>
		<table border=0 cellpadding=0 cellspacing=0>
    	<tr> 
			<td width="$bar_width" bgcolor="$border_color"><small>$spercent</small></td>
    	</tr>
		</table>
		</td>
		<td align="right">$font_answers$no_votes votes$font_answers_close</td></tr>
HTML
		}
	}

	$return .= <<HTML;
	</table>

	<p>$font_answers$total total votes$font_answers_close</p>
	$close
	</td></tr></table>
</td></tr>
</table>
</td></tr></table>
HTML

	return $return;

}


sub print_question{
	my $return;
	my $back = $ENV{'HTTP_REFERER'};
	my $font_question_close = "";
	my $font_answers_close = "";

	if($is_ssi){
		$font_question = $ssi_font_question;
		$font_answers = $ssi_font_answers;
	}
	if($font_question){$font_question_close ="</font>";}
	if($font_answers){$font_answers_close ="</font>";}

	$new_window = <<HTML;
	 OnClick="javascript:window.open('$url?view=view','Popup','width=$save_width,height=$save_width,scrollbars=1')"
HTML

	$return = <<HTML;
<form method="post" $action>
<table width="$width" bgcolor="$border_color" cellpadding=0 cellspacing=1><tr><td>
<table width=100% bgcolor="$background_color" cellspacing=0 cellpadding=2>
<tr bgcolor="$border_color"><td>$font_question<b>$question</b>$font_question_close</td></tr>
<tr><td>
HTML

	foreach (@answers){
		$on_click = <<HTML;
	 OnClick="javascript:window.open('$url?vote=$_','Popup','width=$save_width,height=$save_width,scrollbars=1')"
HTML
		$return .= "<input type=\"radio\" name=\"vote\" value=\"$_\" $on_click>$font_answers$_$font_answers_close<br>";
	}

	$return .= <<HTML;

</td></tr>
HTML

	$return .= <<HTML;
<tr><td>
<a href="#NULL" $new_window>$font_answers view w/o voting$font_answers_close</a></td></tr>
</table>
</td></tr></table>
<input type="hidden" name="back" value="$back"
HTML

	return $return;
}

sub dienice($){
	printpage("
<table width=\"$width\" bgcolor=\"$border_color\" cellpadding=0 cellspacing=1><tr><td>
<table width=100% bgcolor=\"$background_color\" cellspacing=0 cellpadding=2>	
<tr bgcolor=\"$border_color\"><td align=center><font color=white><b>OOPS</b></font></td></tr>
<tr><td>
	<font color=red><br><br>$_[0]</font>
</td></tr></table>
</td></tr></table>
","$_[1]");
	exit();
}

sub printpage($){
	my $content = $_[0];
	my $template = $_[1];
	my $page;

	if($template){
		open(TEMPLATE,"<$template")||dienice("could not find the template file template.html to use!");
		while(<TEMPLATE>){
			$page .= $_;
		}
		close(TEMPLATE);

		$page =~ s/<!-- ?CONTENT ?-->/$content<br><font color='#000000' size=-1>
Powered by <a color='#008800' href="http:\/\/www.fuzzymonkey.org\/newfuzzy\/software\/perl\/" target=\"new\">My Voting Script $version<\/a>.  Licensed under <a href=\"http:\/\/www.fsf.org\/copyleft\/gpl.html\" target=\"newwindow\">GPL<\/a>. &#169; 2000-2003 Fuzzymonkey.org.<\/font><br>/i;
	}else{
		$page = $content;
	}
	print "Content-type: text/html\n\n$page";
} 

return 1;
