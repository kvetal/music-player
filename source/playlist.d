module playlist;

import std.stdio;
import std.file;

///
struct PlayListItem {
	/** Полное имя файла включая путь*/
	string fullFileName;
	/** Имя самого фала и расширение*/
	string shortFileName;
	/** Длительность в секундах*/
	long duration = -1;
	/** Исполнитель*/
	string artist;
	/** Название композиции*/
	string trackName;
	}

///Интерейс плейлиста
interface IPlaylist {
	/** Загрузить плейлист из файла m3u8*/
	bool loadFromPLFile(string fileName);
	/** Сохранить плейлист в файл m3u8*/
	bool saveToPLFile(string fileName);
	/** Добавить аудио файл в плейлист*/
	void addTrackFromFile(string fileName);
	/** Добавить трек*/
	void addTrack(PlayListItem info);
	/** Удалить файл из плейлиста*/
	bool removeTrack(int index);
	/** Получить номер текущего трека*/
	int getCurrentTrackIndex();
	/** Установить текущий трек*/
	void setCurrentTrackIndex(int index);
	/** Получить трек по нидексу*/
	PlayListItem getTrack(int index);
	/** Изменить инфо о треке*/
	void setTrackInfo(int index, PlayListItem info);
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
	@property int length();
	/** Получить копию плейлиста в виде массива структур типа PlayListItem*/
	PlayListItem[] getArray();
	/** Передать в класс массив записаей типа PlayListItem.
	Будет передана ссылка, изменения исходнго массива будут влиять на плейлист, 
	если это не нужно передавайте PlayListItem[].idup.*/
	void setArray(PlayListItem[] playlist);
}

class playlist : IPlaylist{
	/** Загрузить плейлист из файла m3u8*/
	bool loadFromPLFile(string fileName){
		return false;
		}
	/** Сохранить плейлист в файл m3u8*/
	bool saveToPLFile(string fileName){
		return false;
	}
	/** Добавить аудио файл в плейлист*/
	void addTrackFromFile(string fileName){
		
	}
	/** Добавить трек*/
	void addTrack(PlayListItem info){
	
	}
	/** Удалить файл из плейлиста*/
	bool removeTrack(int index){
		return false;
	}
	/** Получить номер текущего трека*/
	int getCurrentTrackIndex(){
		return -1;
	}
	/** Установить текущий трек*/
	void setCurrentTrackIndex(int index){
		
	}
	/** Получить трек по нидексу*/
	PlayListItem getTrack(int index){
		PlayListItem value;
		return value;
	}
	/** Изменить инфо о треке*/
	void setTrackInfo(int index, PlayListItem info){
		
	}
	/** Получить текущий трек*/
	PlayListItem getCurrentTrack(){
		PlayListItem value;
		return value;
	}
	/** переключить текущий трек на следующий и получить его данные, если выключен loop флаг,
	После последнего треке возвращает null*/
	PlayListItem next(){
		PlayListItem value;
		return value;
	}
	/** переключить текущий трек на предыдущий и получить его данные,  если выключен loop флаг,
	После первого трека возвращает null*/
	PlayListItem prev(){
		if ((_index == 0) & _loop)
			_index = _playlist.length - 1;
		else
			_index--;
		return _playlist[_index];
	}
	/** установить флаг циклического перебора треков*/
	void setLoop(bool flag){
		_loop = flag;
	}
	/** получить флаг циклического перебора треков*/
	bool getLoop(){
		return _loop;
	}
	/** Размер плейлиста*/
	@property int length(){
		return _playlist.length;
	}
	/** Получить копию плейлиста в виде массива структур типа PlayListItem*/
	PlayListItem[] getArray(){
		return _playlist;
	}
	/** Передать в класс массив записаей типа PlayListItem.
	Будет передана ссылка, изменения исходнго массива будут влиять на плейлист, 
	если это не нужно передавайте PlayListItem[].idup.*/
	void setArray(PlayListItem[] playlist){
		_playlist = playlist;
	}
	protected:
		PlayListItem[] _playlist;
		bool _loop;
		int _index;
}
