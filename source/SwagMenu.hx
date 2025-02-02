import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import sys.FileSystem;

class SwagMenu extends MusicBeatState {
    var songs:Array<String> = [];
    var textGrp:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

    var errorLog:FlxText;

    var selectedSong(default, set):Int;
    override function create() {
        super.create();
        FlxG.camera.bgColor = 0x63595959;
        Conductor.bpm = 160;
        FlxG.sound.playMusic(Paths.loadStreamedAudio("mainMenu"));

        errorLog = new FlxText(600, 20, 500, "", 16);
        errorLog.color = 0xFFFF0000;
        trace(FileSystem.readDirectory("assets/songs"));
        for (song in FileSystem.readDirectory("assets/songs")) {
            trace(song);
            if (FileSystem.readDirectory("assets/songs/" + song).contains("inst.ogg") && FileSystem.readDirectory("assets/songs/" + song).contains("voices.ogg") && FileSystem.readDirectory("assets/songs/" + song).contains("chart.json"))  
            {
                var json:Dynamic = Song.parseJSON(song);
                if (json.format == "GLFormat") {
                    songs.push(song);
                }
                else errorLog.text += "Impropter chart format for song: " + song + ".";
            }
            else errorLog.text += "A file is missing for song: " + song + ". Please check capitalization and or naming.";
        }

        for (i => song in songs) {
            var text:FlxText = new FlxText(0, 50 + 35 * i, 300, song, 20);
            text.alignment = CENTER;
            text.screenCenter(X);
            text.ID = i;
            textGrp.add(text);
        }
        add(textGrp);
        add(errorLog);

        selectedSong = 0;

        var text:FlxText = new FlxText(0, 0, 0, "To add a new song, check out the SONGTUT.txt file.", 16);
        text.screenCenter(X);
        text.y = FlxG.height - text.height - 8;
        add(text);
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.DOWN) selectedSong++;
        if (FlxG.keys.justPressed.UP) selectedSong--;
        if (FlxG.keys.justPressed.ENTER) {
            FlxG.sound.music.stop();
            FlxG.switchState(new PlayState(songs[selectedSong]));
        }
        super.update(elapsed);
    }

    function set_selectedSong(value:Int):Int {
        value = FlxMath.wrap(value, 0, textGrp.members.length - 1);
        for (i=> member in textGrp.members) {
            if (member.ID == value) textGrp.members[i].color = 0xFFFF00;
            else textGrp.members[i].color = 0xFFFFFFFF;
        }
        return selectedSong = value;
    }
}