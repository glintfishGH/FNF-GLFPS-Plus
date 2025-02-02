import Song.SongData;

/**
 * TODO: Finish...
 */
class ChartEditor extends MusicBeatState {
    public var songData:SongData;
    var curSong:String;
    public function new(song:String) {
        super();
        curSong = song;
    }

    override function create() {
        super.create();
    }
}