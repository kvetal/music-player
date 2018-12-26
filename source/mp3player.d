module mp3player;

//import std.stdio;
import derelict.portaudio;
import std.conv;
import derelict.mpg123;
import std.exception;
import std.string;
import std.concurrency;
import core.time;
import types;
import core.thread;
import std.algorithm;
import std.range;

bool fDebug = false;

class MP3Player : IPlayer
{	
	private
	{
		string _filename;
		int _mpg_error;
		mpg123_handle* _mh;
		int _mpg123_status;
		PaError _pa_err;
		int _rate, _channels, _encoding;
		Tid _thread;
		int _length;
		bool _file_loaded = false;
		float _volume = 100;
	}
		shared long offset;
	this()
	{
		DerelictMPG123.load();
		DerelictPORTAUDIO.load();
		_pa_err = Pa_Initialize();
		if (_pa_err != 0) throw new Error("PortAudio initialization failed:"~to!string(Pa_GetErrorText(_pa_err)));
		_mpg123_status = mpg123_init();
		if (_mpg123_status != MPG123_OK) throw new Error("MPG123 init failed:"~to!string(_mpg123_status));
	}
	~this()
	{
		this.stop();
		_pa_err = Pa_Terminate();
		//if (fDebug) writeln("Pa_Terminate in ~this() result:",_pa_err);
		mpg123_exit();
	}
	bool openFromFile(string fileName)
	{
		_filename = fileName;
		_mh  = mpg123_new(null, &_mpg_error);
		if (_mpg_error != MPG123_OK) return false;
		_mpg_error = mpg123_open(_mh, toStringz(_filename));
		if (_mpg_error != MPG123_OK) return false;
		_mpg_error = mpg123_getformat(_mh, &_rate, &_channels, &_encoding);
		//if (fDebug) writeln("mpg123_getformat result:",_mpg_error,"\nrate:",_rate,"\nchannels:",_channels,"\nencoding:",_encoding);
		if (_mpg_error != MPG123_OK) return false;
		_length = cast(int) (mpg123_framelength(_mh) * mpg123_tpf(_mh));
		_file_loaded = true;
		return true;
	}
	void play()
	{
		//if (fDebug) writeln(Tid.init);
		if (_thread == Tid.init)
			_thread = spawn(&_play,thisTid, _filename, _length);
		else
			if (this.getStatus == Status.Paused)
				send(_thread,playMessage());
	}
	
	void stop()
	{
		send(_thread,stopMessage());
	}
	
	void pause()
	{
		send(_thread,pauseMessage());
	}
	
	void setVolume(float volume)
	{
		send(_thread,volumeMessage(volume));
		_volume = volume;
		
	}
	
	float getVolume()
	{
		return _volume;
	}

	/** Смещение от начала в микросекундах*/
	void setPlayingOffset(long offset)
	{
		send(_thread,seekMessage(offset/1000000));
	}
	
	long getPlayingOffset()
	{
		long offs;
		send(_thread,askOffsetMessage());
			receive(
				(seekMessage m)
					{
						offs = m.sec;
					}
			);
		return offs;
	}
	
	soundStatus getStatus()
	{
		Status status;
		send(_thread,statusMessage(Status.Stopped));
		receiveTimeout(100.msecs,
				(statusMessage m)
					{
						status = m.status;
					}
		);
		return status;
	}
}

void _play(Tid parentId,string filename,int length)
	{
		int mpg_error;
		PaError pa_err;
		int rate, channels, encoding;
		PaStreamParameters outputParameters;
		mpg123_handle* mh  = mpg123_new(null, &mpg_error);
		mpg_error = mpg123_open(mh, toStringz(filename));
		mpg_error = mpg123_getformat(mh, &rate, &channels, &encoding);
		auto outDev = Pa_GetDefaultOutputDevice();

		outputParameters.device = outDev;
		outputParameters.channelCount = channels;
		outputParameters.sampleFormat =paInt16;
		outputParameters.suggestedLatency = Pa_GetDeviceInfo(outputParameters.device).defaultHighInputLatency;
		outputParameters.hostApiSpecificStreamInfo = null;

		PaStream* stream;
		pa_err = Pa_OpenStream(&stream, null, &outputParameters, rate, 64, 0,null,null);
		if (pa_err < 0) return;
		pa_err = Pa_StartStream(stream);
		if (pa_err < 0) return;

		enum size_t bufSize = 4096;
		//writeln(mpg123_spf(mh));
		ubyte[bufSize] outBuf;
		int numSampleBlock;
		size_t done;
		bool pause = false;
		do
		{
			receiveTimeout(10.msecs,
				(pauseMessage m)
					{
						pause = true;
					},
				(playMessage m)
					{
						pause = false;
					},
				(seekMessage m)
					{
						mpg123_seek_frame(mh,cast (int)(m.sec * mpg123_tpf(mh)),SEEK_SET);
					},
				(stopMessage m)
					{
						pause = true;
						mpg_error = -1;
					},
				(volumeMessage m)
					{
						mpg123_volume(mh,m.volume/100f);
					},
				(askOffsetMessage m)
					{
						send(parentId,seekMessage(cast(long)((mpg123_tellframe(mh) * mpg123_tpf(mh))*1000000)));
					},
				(statusMessage m)
					{
						if (pause) 
							send(parentId,statusMessage(Status.Paused));
						else if (mpg_error != MPG123_OK)
							send(parentId,statusMessage(Status.Stopped));
						else send(parentId,statusMessage(Status.Playing));

					}
		);
		double base,really, rva_db;
		if (!pause)
			{
			mpg_error = mpg123_read(mh, outBuf.ptr, bufSize, &done);
			//if (fDebug) if (mpg_error != MPG123_OK) writeln("mpg123_read error:",mpg_error);
			Pa_WriteStream(cast(PaStream*)stream, outBuf.ptr, done/4 );
			//if (fDebug) writeln("Block:",numSampleBlock," bytes:", done);
			numSampleBlock++;
			}
	}
	while (mpg_error == MPG123_OK);
	
	pa_err = Pa_StopStream(stream);
//	if (fDebug) writeln("Pa_StopStream:",to!string(Pa_GetErrorText(pa_err)));

	pa_err = Pa_CloseStream(stream);
//	if (fDebug) writeln("Pa_CloseStream:",to!string(Pa_GetErrorText(pa_err)));
//	if (fDebug) writeln("this tid",thisTid);
}


