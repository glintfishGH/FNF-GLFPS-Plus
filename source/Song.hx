package;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;

using StringTools;

typedef SongData = {
	var song:String;
	var speed:Float;
	var player1:String;
	var player2:String;
	var notes:Array<{t:Float, d:Int, l:Float}>;
	var bpm:Float;
	var events:Array<Dynamic>;
	var focuses:Array<{time:Float, focusBF:Bool}>;
}

class Song {
	/**
	 * Parses a JSON from the songs folder.
	 * @param song The name of the song.
	 * @return SongData
	 */
	public static function parseJSON(song:String):SongData {
		var songToGet:String = 'assets/songs/$song/chart';
		var jsonContents:String;
		
		if (FileSystem.exists(songToGet + "-conv.json"))
			jsonContents = File.getContent(songToGet + "-conv.json");
		else jsonContents = File.getContent(songToGet + ".json");
		return Json.parse(jsonContents);
	}
}
