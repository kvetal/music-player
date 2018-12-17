module audioplayer;
import std.string;
import std.stdio;
import std.conv;
import derelict.util.loader;
import derelict.util.system;
import derelict.util.exception;
import derelict.sfml2;



interface Player {
	bool openFromFile(string fileName);
	void play();
	void pause();
	void setVolume(float);
	float getVolume();
	void setPlayingOffset(long offset);
	long getPlayingOffset();
	soundStatus getStatus();
	}

alias soundStatus = int;
enum {
    Stopped,
    Paused,
    Playing
}


class APlayer : Player{
	this(){
		DerelictSFML2Audio.load();
	}
	
	bool openFromFile(string fileName){
		_music = sfMusic_createFromFile(fileName.toStringz());
		if (_music) return true;
		return false;
		}

	void play(){
		sfMusic_play(_music);
	}

	void stop(){
		sfMusic_stop(_music);
		}

	void pause(){
		sfMusic_pause(_music);
		}

	void setVolume(float volume){
		sfMusic_setVolume(_music,volume);
	}

	float getVolume(){
		return sfMusic_getVolume(_music);
	}

	void setPlayingOffset(long offset){
		sfTime timeOffset;
		timeOffset.microseconds = offset;
		sfMusic_setPlayingOffset(_music,timeOffset);
	}

	long getPlayingOffset(){
		return sfMusic_getPlayingOffset(_music).microseconds;
	}

	soundStatus getStatus(){
		return sfMusic_getStatus(_music);
	}
	protected{
		sfMusic* _music;
		float _volume;
		}
}