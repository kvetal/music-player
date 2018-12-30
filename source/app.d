import playlist;
import mp3player;
import types;
import std.stdio;
import scheduler;

void main()
{
	MP3Player mplay = new MP3Player();
	MP3Player mplay1 = new MP3Player();
	scope(exit)
	{
		mplay.stop();
		mplay1.stop();
	}
	auto am_pl = new PlayList();
	auto pa_pl = new PlayList();
	am_pl.loadFromPLFile("Amaranthe.m3u8");
	pa_pl.loadFromPLFile("pantera.m3u8");

	bool stopper = false;
while (!stopper)
	{
		if (mplay1.getStatus() == Stopped)
		{
				writeln(am_pl.getTrack(am_pl.getCurrentTrackIndex()).fullFileName);
				mplay1.openFromFile(am_pl.getTrack(am_pl.getCurrentTrackIndex()).fullFileName);
				mplay1.play();
				am_pl.next();
		}
	}
	readln();
}
