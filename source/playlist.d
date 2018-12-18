module playlist;

import std.stdio;
import std.file;
import std.algorithm;
import std.regex;
import std.utf;
import std.encoding;
import std.conv;
import std.string;
import std.exception;

bool fDebug = false;

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

class PlayList : IPlaylist{
	this(){
		_playlist = [];
	}
	/** Загрузить плейлист из файла m3u8*/
	bool loadFromPLFile(string fileName){
		/* Открываем файл */
		File file;
		try{
			file = File(fileName,"r");
		} catch (Exception e){
			if (fDebug) writeln(e.msg);
			return false;
		}
		scope(exit) file.close;
		/* чистим плейлист */
		_playlist = [];
		/* Читаем первую строку, для того, что бы определить модификацию формата 
			m3u  - просто список имен файлов в кодировке latin - 1
			m3u8 - файл в формате utf-8, c доп информацией о треках*/
		auto firstString = file.readln();
		/*Проверяем первую строку на предмет наличия корректного Byte Order Mark и заголовка EXTM3U*/
		if ((firstString[0..3] == bom) && (firstString[3..10] == "#EXTM3U")){
			/* Если проверка удачна, срезаем BOM, устанавливаем флаг расширеккого формата*/
			firstString = firstString[3..$];
			_extM3U = true;
			/* Задаем флаг заполнения информации о треке*/
			bool f = false;
			/* Создаем временную переменную для хранения инфо о треке */
			PlayListItem track;
			/* читаем файл построчно */
			foreach (line;file.byLine){
				/* Если если строка начинается с тега #EXTINF, разбиваем ее на составные части, 
					заполняем информацию о треке, и устанавливаем флаг заполнения, следующей строкой будет путь и имя файла*/
				if (line[0..7] == "#EXTINF"){
					auto splittedINFO = line.split(regex(`[,:]`));
					if (splittedINFO[1].isNumeric)
						track.duration = to!int(splittedINFO[1]);
					track.info = to!string(splittedINFO[2]);
					f = true;
				} else {
					/* Заполняем Путь и имя файла, добавляем структуру в плейлист и сбрасываем флаг заполнения*/
					if (f){
						auto splittedFileName = line.split(regex(`[\\/]`));
						track.fullFileName = to!string(line);
						track.shortFileName = to!string(splittedFileName[splittedFileName.length - 1]);
						_playlist ~=track;
						f = false;
					}
				}
			}
		} else { /* Если формат не расширеный добавляем первую строку в плейлист*/
			addTrackFromFile(firstString);
		}
		/* Если формат не расширеный, читаем строки из файла и просто добавляем в путь и имя файла в плейлист*/
		if (!_extM3U){
			foreach (line;file.byLine){
				addTrackFromFile(cast(string)line);
			}
		}
		return true;
}
	/** Сохранить плейлист в файл m3u8*/
	bool saveToPLFile(string fileName){
		return false;
	}
	/** Добавить аудио файл в конец плейлиста*/
	void addTrackFromFile(string fileName){
		auto splittedFileName = fileName.split(regex(`[\\/]`));
		PlayListItem track;
		track.fullFileName = fileName;
		track.shortFileName = splittedFileName[splittedFileName.length - 1];
		track.info = split(track.shortFileName,regex(`[.]`))[0];
		_playlist ~= track;
	}
	/** Добавить трек в конец плейлиста*/
	void addTrack(PlayListItem info){
		_playlist ~=info;
	}
	/** Удалить трек из плейлиста*/
	bool removeTrack(size_t index){
		if (_playlist !is null){
			_playlist = _playlist.remove(index);
			return true;
		}
		return false;
	}
	/** Получить номер текущего трека*/
	size_t getCurrentTrackIndex(){
		return _index;
	}
	/** Установить текущий трек*/
	void setCurrentTrackIndex(size_t index){
		_index = index;
	}
	/** Получить трек по нидексу*/
	PlayListItem getTrack(size_t index){
		return _playlist[index];
	}
	/** Изменить инфо о треке*/
	void setTrackInfo(size_t index, PlayListItem info){
		_playlist[index] = info;
	}

	/** Получить текущий трек*/
	PlayListItem getCurrentTrack(){
		return _playlist[_index];
	}

	/** переключить текущий трек на следующий и получить его данные, если выключен loop флаг
	после последнего трека будет ошибка index out of range
	Вообще переключение треков не задача плейлиста, но пока будет так*/
	PlayListItem next(){
		if ((_index == _playlist.length-1) & _loop)
			_index = 0;
		else 
			_index++;
		return _playlist[_index];
	}

	/** переключить текущий трек на предыдущий и получить его данные,  если выключен loop флаг,
	После первого трека будет ошибка index out of range.
	Вообще переключение треков не задача плейлиста, но пока будет так*/
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
	@property size_t length(){
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
		bool _extM3U = false;
		size_t _index;
		
}

unittest{
	PlayList pl = new PlayList();
	assert(pl.length == 0);
	pl.addTrackFromFile("/home/user/music/Хлам/какая то попсятина.ogg");
	assert(pl.getTrack(0).info == "какая то попсятина");
	if (pl.loadFromPLFile("playlist.m3u8"))
		assert(pl.length > 0);
}
