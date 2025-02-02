package;

import lime.app.Future;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import config.KeyBinds;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

using StringTools;
class InitState extends MusicBeatState {
	var graphicsToCache:Array<String> = [];
	var songs:Array<String> = FileSystem.readDirectory("assets/songs/");

	override function create() {
		FlxG.mouse.visible = false;
		FlxG.sound.muteKeys = [FlxKey.ZERO];

		FlxG.save.bind('data');
		KeyBinds.keyCheck();
		PlayerSettings.init();
		PlayerSettings.player1.controls.loadKeyBinds();

		UIStateExt.defaultTransIn = null;
		UIStateExt.defaultTransOut = null;
		useDefaultTransIn = false;
		customTransIn = null;

        for (song in songs) {
            convertChart(song);
        }

		super.create();
		FlxG.switchState(new SwagMenu());
	}

    function fixChart(song:String) {
        var path:String = 'assets/songs/$song/';
        var chart:Dynamic = Json.parse(File.getContent(path + 'chart.json'));

        var newNotes:Array<{t:Float, d:Int, l:Float}> = [];
        for (i in 0...chart.notes.length) {
            var noteObj = chart.notes[i];
            newNotes.push({t: noteObj.time, d: noteObj.direction, l: noteObj.length});
        }

        chart = Json.stringify({
            format: "GLFormat",
            player1: chart.player1,
            player2: chart.player2,
            song: chart.song,
            bpm: chart.bpm,
            bpmChanges: chart.bpmChanges,
            speed: chart.speed,
            events: chart.events,
            notes: newNotes,
            focuses: chart.focuses
        });
        trace(chart);
        File.saveContent(path + "chart.json", chart);
    }

    /**
     * Converts the chart from FPS Plus / Psych format into GLFormat.
     * @param song_chart 
     */
    function convertChart(song_chart:String) {
        var path:String = 'assets/songs/$song_chart/';
        var chart:Dynamic = Json.parse(File.getContent(path + 'chart.json'));

        if (chart.format != null) return;

        /**
         * Declare the new chart.
         */
        var newChart:Dynamic = {};

        /**
         * Array of the newly formatted notes.
         */
        var newNotes:Array<{t:Float, d:Int, l:Float}> = [];

        /**
         * Array of must hit sections. All this does is decide where the camera is.
         * Called focuses in the chart.
         */
        var mustHits:Array<{time:Float, focusBF:Bool}> = [];

        /**
         * Array of all the bpm changes in the chart.
         */
        var bpmChanges:Array<{time:Float, newBPM:Float}> = [];

        var oldChartBPM:Float = chart.song.bpm;

        /**
         * How many steps a section has.
         */
        var sectionLength:Int = 16;

        /**
         * Time at which each section starts. Set on each itteration of the for loop below
         */
        var sectionStartTime:Float = 0;

        // Parsing the entire section, not the notes inside it.
        for (i in 0...chart.song.notes.length) {
            /**
             * Section currently being parsed.
             */
            var curSection:Dynamic = chart.song.notes[i];

            var nextSection:Dynamic = chart.song.notes[i + 1];
            var mustHit:Bool = curSection.mustHitSection;

            // Have to get the time of the mustHit, do a bunch of math.
			sectionStartTime += ((60 / oldChartBPM) * 1000 / 4) * sectionLength;

            if (i == 0) {
                mustHits.push({focusBF: mustHit, time: 0});
            }
            if (nextSection != null) {
                if (nextSection.mustHitSection != curSection.mustHitSection) {
                    mustHits.push({focusBF: mustHit, time: sectionStartTime});
                }
            }
            // The section contains a bpm change.
            if (curSection.changeBPM) {
                bpmChanges.push({
                    time: ((60 / oldChartBPM) * 1000) * 4 * i, newBPM: curSection.bpm
                });
            }
            // Time to parse the notes.
            for (j in 0...curSection.sectionNotes.length) {
                var sectionNotes = curSection.sectionNotes[j];

                var noteTime:Float = sectionNotes[0];
                var noteDirection:Int = cast sectionNotes[1]; // no trust me this IS an Int
                var noteLength:Float = sectionNotes[2];
                
                /**
                 * Removing mustHitSection from note parsing
                 * If the section is NOT a musthit, 0123 are the opponent, 4567 are the player.
                 */
                var notMustHitArray:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7];
                var mustHitArray:Array<Int> = [4, 5, 6, 7, 0, 1, 2, 3];
                if (!mustHit) {
                    newNotes.push({t: noteTime, d: notMustHitArray[noteDirection], l: noteLength});
                }
                else 
                    newNotes.push({t: noteTime, d: mustHitArray[noteDirection], l: noteLength});
            }
        }

        var bpmChangeMap = [];

        // Goes through all the bpm changes
		for (i in 0...bpmChanges.length)
		{
            // The JSON object containing the bpm changes.
            var changeObject:Dynamic = bpmChanges[i];
            var changeStep:Int = Math.floor(newChart.bpm / Conductor.stepLength);

			var changeEvent:Conductor.BPMChangeEvent = {
                songTime: changeObject.time,
                bpm: changeObject.newBPM,
                stepTime: changeStep
            }
			bpmChangeMap.push(changeEvent);
		}

        newChart = Json.stringify({
            format: "GLFormat",
            player1: chart.song.player1,
            player2: chart.song.player2,
            song: chart.song.song,
            bpm: chart.song.bpm,
            bpmChanges: bpmChanges,
            speed: chart.song.speed,
            events: chart.song.events,
            notes: newNotes,
            focuses: mustHits
        });

        File.saveContent(path + "chart-conv.json", newChart);
    }
}