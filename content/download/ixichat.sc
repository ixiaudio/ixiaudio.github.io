// bucherhausen, innsbruck. April 7, 2004.
// ixi software chat client made in supercollider 3
// mail or phone your friend and get his/her IP addresse
// both of you have to have SC 3 running with this patch.

(
var w, text, textwin, sendbutt, remoteIP, iPbutt, remoteText, otherIP, otherNetAddr;
// send synth def to server
SynthDef(\tpulse, { arg out=0,freq=700,sawFreq=440.0; 
	Out.ar(out, SyncSaw.ar(freq,  sawFreq,0.1) * EnvGen.kr(Env.perc,1.0,doneAction: 2)) 
}).send(s);

w = SCWindow("ixi sc chat", Rect(38, 364, 340, 300)).front;
remoteIP = SCTextField(w, Rect(20, 40, 120, 20) );
iPbutt = SCButton(w, Rect(180, 40, 60, 20));
iPbutt.states = [["set IP",Color.black,Color.clear]];
iPbutt.action_({
	remoteIP.defaultKeyDownAction(3.asAscii);
	otherIP = remoteIP.value;
	otherNetAddr = NetAddr(otherIP, 57120);
	//[\otherIP, otherIP].postln;
	//[\otherNetAddr, otherNetAddr].postln;
	});
	
text = SCTextField(w, Rect(20, 80, 220, 20) );
textwin = SCTextField(w, Rect(20, 120, 220, 20) );
SCStaticText(w, Rect(250, 120, 40, 20)).string_("you");

sendbutt = SCButton(w, Rect(250, 80, 60, 20));
sendbutt.states = [["send",Color.black,Color.clear]];
sendbutt.action_({
	text.defaultKeyDownAction(3.asAscii);
	textwin.value = text.value;
	Synth(\tpulse, [\freq, 222+(333.rand)]);
	otherNetAddr.sendMsg(\snd, 444+(555.rand)); 
	otherNetAddr.sendMsg(\txt, text.value); 
	text.value = "";
	});
	
remoteText = SCTextField(w, Rect(20, 180, 220, 20) );
SCStaticText(w, Rect(250, 180, 40, 20)).string_("other");

f = {arg time, responder, message;
	//[time, responder, message].postln;
	y = Synth(\tpulse, [\freq, message.at(1).asInteger]);	};
g = {arg time, responder, message;
	//[time, responder, message].postln;
	{remoteText.value = message.at(1).asString}.defer;
	};
OSCresponder(nil, \snd, f).add;
OSCresponder(nil, \txt, g).add;

)



