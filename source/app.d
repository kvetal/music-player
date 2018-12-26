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
	mplay.openFromFile("test.mp3");
	mplay.play();
	readln();
	mplay1.openFromFile("test.mp3");
	mplay1.play();
	readln();
}
