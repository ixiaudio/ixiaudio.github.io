#########################################################################
# My Voting Script
#
# http://www.fuzzymonkey.org
# license: GPL
$version = '2.1';
#########################################################################

$question = 'Is the ixi puffin a nice software animal?';
@answers = ('Yes','No', 'Maybe');

# prevent someone from the same IP address from voting more than once
# set this to 0 to disable IP address checking
$lockhours = 0;

# look and feel
$border_color = "#1b18b2";
$background_color = "#efeffc";
$width = '500';
$font_question = "<font color=white>"; #closed automatically if present
$font_answers = ""; #closed automatically if present

# options for use in ssi mode
$url = 'http://www.ixi-software.net/cgi-bin/vote/index.cgi';
$ssi_width = '250';
$close_button = "no";
$ssi_font_question = "<font color=white size=-1>"; #closed automatically if present
$ssi_font_answers = "<font size=-1>"; #closed automatically if present

return 1;
