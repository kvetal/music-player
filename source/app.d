import playlist;
import mp3player;
import types;
import std.stdio;
import scheduler;
import std.datetime.stopwatch;
import std.conv;
import std.string;

string[string] readConfig(string fileName)
{
	string[string] cfg;
	auto cfg_file = new File(fileName,"r");
	foreach(ref line;cfg_file.byLine)
	{
		if ((strip(line).length == 0) || (strip(line)[0] == '#')) continue;
		
		auto l = line.split('=');
		cfg[to!string(l[0]).strip] = to!string(l[1]).strip;
	}
	return cfg;
}

void main()
{
	auto cfg = readConfig("config.cfg");
	MP3Player mplay = new MP3Player();
	MP3Player mplay1 = new MP3Player();
	scope(exit)
	{
		mplay.stop();
		mplay1.stop();
	}
	auto mus_pl = new PlayList();
	auto rek_pl = new PlayList();
	if (!mus_pl.loadFromPLFile(cfg["music_paylist"]))
	{
		writeln("music playlist load error.");
		return;
	}
	if (!rek_pl.loadFromPLFile(cfg["reklama_playlist"]))
	{
		writeln("reklama playlist load error.");
		return;
	}

	ulong interval = to!int(cfg["rek_interval"]);
	writeln("interval:",interval);
	mus_pl.setLoop(true);
	mus_pl.setCurrentTrackIndex = 21;
	mplay.setVolume(10);
	bool stopper = false;
	bool stopper1 = false;
	auto sw = StopWatch (AutoStart.no);
	
	while (!stopper)
	{
		if (sw.peek.total!"seconds" >= interval)
		{
			mplay.stop();
			sw.stop();
			sw.reset();
			while (!stopper1)
			{
				if (mplay1.getStatus() == Status.Stopped)
				{
					writeln(rek_pl.getTrack(rek_pl.getCurrentTrackIndex()).fullFileName);
					mplay1.openFromFile(rek_pl.getTrack(rek_pl.getCurrentTrackIndex()).fullFileName);
					mplay1.play();
					rek_pl.next();
					stopper1 = true;
				}
			}
			stopper1 = false;
		}
		if (mplay.getStatus() == Status.Stopped)
		{
			writeln(mus_pl.getTrack(mus_pl.getCurrentTrackIndex()).fullFileName);
			mplay.openFromFile(mus_pl.getTrack(mus_pl.getCurrentTrackIndex()).fullFileName);
			mplay.play();
			sw.start();
			mus_pl.next();
		}
	}
	readln();
	readln();
}
