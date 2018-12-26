module types;

///
struct PlayListItem {
	/** Полное имя файла включая путь*/
	string fullFileName;
	/** Имя самого фала и расширение*/
	string shortFileName;
	/** Длительность в секундах*/
	long duration = -1;
	/** Инфо*/
	string info;
	}

enum string bom = [0xef,0xbb,0xbf];

alias soundStatus = int;
enum {
    Stopped,
    Paused,
    Playing
}

///Интерейс плейлиста
interface IPlaylist {
	/** Загрузить плейлист из файла m3u8*/
	bool loadFromPLFile(string fileName);
	/** Сохранить плейлист в файл m3u8*/
	bool saveToPLFile(string fileName);
	/** Добавить аудио файл в плейлист*/
	void addTrackFromFile(string fileName);
	/** Добавить трек в конец плейлиста*/
	void addTrack(PlayListItem info);
	/** Удалить файл из плейлиста*/
	bool removeTrack(size_t index);
	/** Получить номер текущего трека*/
	size_t getCurrentTrackIndex();
	/** Установить текущий трек*/
	void setCurrentTrackIndex(size_t index);
	/** Получить трек по нидексу*/
	PlayListItem getTrack(size_t index);
	/** Изменить инфо о треке*/
	void setTrackInfo(size_t index, PlayListItem info);
	/** Получить текущий трек*/
	PlayListItem getCurrentTrack();
	/** переключить текущий трек на следующий и получить его данные, если выключен loop флаг,
	После последнего треке возвращает null*/
	PlayListItem next();
	/** переключить текущий трек на предыдущий и получить его данные,  если выключен loop флаг,
	После первого трека возвращает null*/
	PlayListItem prev();
	/** установить флаг циклического перебора треков*/
	void setLoop(bool flag);
	/** получить флаг циклического перебора треков*/
	bool getLoop();
	/** Размер плейлиста*/
	@property size_t length();
	/** Получить копию плейлиста в виде массива структур типа PlayListItem*/
	PlayListItem[] getArray();
	/** Передать в класс массив записаей типа PlayListItem.
	Будет передана ссылка, изменения исходнго массива будут влиять на плейлист, 
	если это не нужно передавайте PlayListItem[].idup.*/
	void setArray(PlayListItem[] playlist);
}

interface IPlayer {
	bool openFromFile(string fileName);
	void play();
	void pause();
	void setVolume(float);
	float getVolume();
	void setPlayingOffset(long offset);
	long getPlayingOffset();
	soundStatus getStatus();
}

enum SEEK_SET = 0;/* set file offset to offset */
enum SEEK_CUR = 1;/* set file offset to current plus offset */
enum SEEK_END = 2;/* set file offset to EOF plus offset */


enum Status
{
	Stopped = 0, 
	Paused = 1,
	Playing = 2
};
   
struct playMessage{}
struct stopMessage{}
struct pauseMessage{}
struct seekMessage
{
	long sec;
	this(long sec)
	{
		this.sec = sec;
	}
}

struct askOffsetMessage
{
}

struct volumeMessage
{
	float volume;
	this(float volume)
	{
		this.volume = volume;
	}
}

struct statusMessage
{
	Status status;
	this(Status status)
	{
		this.status = status;
	}
}


