package;

import flixel.graphics.frames.FlxFrame;
import StringBuf;
import flixel.util.FlxColor;
import Song.SongData;
import config.*;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import glibs.GLGU;

using StringTools;
using StringBuf;
#if sys
import sys.FileSystem;
#end

typedef RestartSongInfo = {
	?bfriendPos:Array<Float>,
	?bfriendSprite:String,

	?gfriendPos:Array<Float>,
	?gfriendSprite:String,

	?opponentPos:Array<Float>,
	?opponentSprite:String,

	?camPos:Array<Float>,
	?camZoom:Float,

	?background:FlxSprite
}

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;

	public static var curStage:String = '';
	public static var SONG:SongData;
	public static var EVENTS:Dynamic;
	public static var loadEvents:Bool = true;

	private var canHit:Bool = false;
	private var noMissCount:Int = 0;

	private var camFocus:String = "";
	private var camTween:FlxTween;
	private var camZoomTween:FlxTween;
	private var uiZoomTween:FlxTween;
	private var camFollow:FlxObject;

	private var sectionHasOppNotes:Bool = false;
	private var sectionHasBFNotes:Bool = false;
	private var sectionHaveNotes:Array<Array<Bool>> = [];

	private var vocals:FlxSound;

	private var dad:Character;
	private var boyfriend:Character;
	private var girlfriend:Character;
	var gfCanDance:Bool = false;

	//Wacky input stuff=========================

	/**
     * Used for recycling.
     * When a note is pressed / deleted, it's added here.
     * The properties of that note get reset when it spawns again and it's removed from this group.
     */
	var graveyard:FlxTypedGroup<Note> = new FlxTypedGroup<Note>();

    /**
     * An array of bools that checks for control just presses.
     */
    var controlJusts:Array<Bool> = [];

	/**
     * An array of bools that checks for control presses / holds.
     */
    var controlPresses:Array<Bool> = [];

    /**
     * A 4-member array that contains a Note object for each lane.
     */
    var noteTargets:Array<Note> = [];

	//End of wacky input stuff===================

	private var autoplay:Bool = false;

	private var invuln:Bool = false;
	private var invulnCount:Int = 0;

	private var notes:FlxTypedGroup<Note>;
	private var maxNotes:Int = 30;
	private var unspawnNotes:Array<Note> = [];
	private var opponentNotes:Array<Note> = [];
	private var focuses:Array<{focusBF:Bool, time:Float}> = [];

	private var curSection:Int = 0;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<StrumNote>;
	private var opponentStrums:FlxTypedGroup<StrumNote>;

	public var curSong:String = "";

	private var health:Float;

	private var misses:Int = 0;
	private var combo:Int = 0;
	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var camOverlay:FlxCamera;

	private var eventList:Array<Array<Dynamic>> = [];

	var songScore:Int = 0;
	var scoreTxt:FlxText;

	var defaultCamZoom:Float = 1;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 1;

	var inCutscene:Bool = false;

	var dadBeats:Array<Int> = [0, 2];
	var bfBeats:Array<Int> = [0, 2];

	public static var sectionStart:Bool =  false;
	public static var sectionStartPoint:Int =  0;
	public static var sectionStartTime:Float =  0;

	var disableCamera:Bool;

	var alts:Bool;

	var eventMap:Map<Int, Void->Void> = new Map<Int, Void->Void>();

	var singDirections:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

	var restartSongInfo:RestartSongInfo = {};
	var bg:FlxSprite;

	var black:FlxSprite;

	var rating:Rating;

	/**
	 * @param song The song to play. Can be without or with-the-dashes.
	 */
	public function new(?song:String) {
		super();
		song = song.replace(" ", "-").toLowerCase();
		curSong = song;
	}

	override public function create() {
		instance = this;
		FlxG.mouse.visible = false;
		PlayerSettings.gameControls();
		disableCamera = false;

		SONG = Song.parseJSON(curSong);
		var music:FlxSound = Paths.inst(curSong);
		FlxG.sound.music = music;

		vocals = new FlxSound();

		if (FileSystem.exists('assets/songs/$curSong/voices.ogg'))
			vocals = Paths.voices(curSong);

		FlxG.sound.list.add(vocals);

		if (Config.noFpsCap)
			openfl.Lib.current.stage.frameRate = 999;
		else
			openfl.Lib.current.stage.frameRate = 144;

		camTween = FlxTween.tween(this, {}, 0);
		camZoomTween = FlxTween.tween(this, {}, 0);
		uiZoomTween = FlxTween.tween(this, {}, 0);

		canHit = !(Config.ghostTapType > 0);
		noMissCount = 0;
		invulnCount = 0;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;
		camHUD.zoom = 0.7;
		camHUD.scroll.x -= camHUD.viewMarginLeft;
		camHUD.scroll.y -= camHUD.viewMarginTop;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camOverlay);
		FlxG.cameras.add(camHUD);
		FlxG.camera.pixelPerfectRender = true;

		FlxCamera.defaultCameras = [camGame];

		dad = new Character(0, 100, "opponent");
		add(dad);

		boyfriend = new Character(1000, 410, "player");
		add(boyfriend);

		dad.holdLength = Conductor.stepLength * 3;
		boyfriend.holdLength = Conductor.stepLength * 3;

		// persistentUpdate = true;
		persistentDraw = true;
		playerStrums = new FlxTypedGroup<StrumNote>();
		opponentStrums = new FlxTypedGroup<StrumNote>();
		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		strumLineNotes.camera = camHUD;
		generateSong();

		rating = new Rating(boyfriend.x - 200, boyfriend.y + 150);
		rating.scale.set(0.5, 0.5);
		rating.updateHitbox();
		add(rating);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow, 2);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		startingSong = true;
		beatHit();
		Conductor.songPosition -= 1000;

		FlxG.bitmap.clearUnused();
		FlxG.bitmapLog.viewCache();
		super.create();
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong():Void {
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;

		if (!paused) {
			// FlxG.sound.playMusic(@:privateAccess Paths.loadStreamed("songs", '$curSong/inst'), 1, false);
			FlxG.sound.music.play();
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		if(sectionStart){
			FlxG.sound.music.time = sectionStartTime;
			Conductor.songPosition = sectionStartTime;
			vocals.time = sectionStartTime;
		}
	}

	private function generateSong():Void {
		GLGU.startStamp();
		Conductor.bpm = SONG.bpm;

		generateStaticArrows();

		notes = new FlxTypedGroup<Note>();
		notes.camera = camHUD;
		add(notes);

		generateChart();

		generatedMusic = true;
		GLGU.endStamp("Song loading");
	}

	function generateChart() {
		var chartNotes:Array<{l:Float, d:Int, t:Float}> = SONG.notes;
		var _focuses:Array<{focusBF:Bool, time:Float}> = SONG.focuses;

		for (chartNote in chartNotes) {
			var note:Note = new Note(chartNote.t, chartNote.d, (chartNote.l <= Conductor.stepLength) ? 0 : chartNote.l, SONG.speed * 1.5);
			unspawnNotes.push(note);
		}
		unspawnNotes.sort((note1, note2) -> FlxSort.byValues(FlxSort.ASCENDING, note1.time, note2.time));

		for (focus in _focuses) {
			focuses.push(focus);
		}
	}

	private function generateStaticArrows():Void {
		for (i in 0...4) {
			var babyArrow:StrumNote = new StrumNote(0, 50, i);
			babyArrow.x += 250 * camHUD.zoom * i;
			babyArrow.x += 125;
			babyArrow.ID = i;

			opponentStrums.add(babyArrow);

			babyArrow.animation.play('static');
			strumLineNotes.add(babyArrow);
		}

		for (i in 0...4) {
			var babyArrow:StrumNote = new StrumNote(0, 50, i);
			babyArrow.x += 250 * camHUD.zoom * i;
            babyArrow.x += 400 + FlxG.width / 2;
			babyArrow.ID = i;

			playerStrums.add(babyArrow);

			babyArrow.animation.play('static');
			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			FlxG?.sound?.music?.pause();
			vocals?.pause();

			// if (startTimer != null && !startTimer.finished)
			// 	startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState() {
		PlayerSettings.gameControls();

		if (paused) {
			FlxG?.sound?.music?.play();
			vocals?.play();
			if (!startingSong) {}
				// resyncVocals();

		// 	if (startTimer != null && !startTimer.finished)
		// 		startTimer.active = true;
		// 	paused = false;
		}

		// setBoyfriendInvuln(1/60);

		super.closeSubState();
	}

	function resyncVocals():Void {
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	override public function update(elapsed:Float) {
		updateInputs();
		updateNotes();
		addNotes();

		super.update(elapsed);

		if (controls.PAUSE && startedCountdown && canPause) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			PlayerSettings.menuControls();

			openSubState(new PauseSubState());
		}

		if (FlxG.keys.justPressed.EIGHT) {

			PlayerSettings.menuControls();
			sectionStart = false;

			if(FlxG.keys.pressed.SHIFT) {
				switchState(new AnimationDebug(boyfriend.curCharacter));
			}
			if (FlxG.keys.pressed.CONTROL) {
				switchState(new AnimationDebug(dad.curCharacter));
			}
		}

		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else {
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition) {
					songTime += Conductor.songPosition / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (focuses[0] != null) {
			var focus = focuses[0];
			if (Conductor.songPosition >= focus.time) {
				if (!focus.focusBF) camFocusBF();
				else camFocusOpponent();
				focuses.remove(focus);
			}
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = true;
	var canPause:Bool = true;

	/**
	 * Updates controlJusts and controlPresses.
	 */
	function updateInputs() {
		// Apparently resizing to 0 helps with array allocation?
		controlJusts.resize(0);
        controlPresses.resize(0);
        controlJusts = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
        controlPresses = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
	}

	/**
	 * Updates noteTargets and each note in the notes array.
	 */
	function updateNotes() {
        noteTargets = [for (i in 0...4) notes.getFirst(function (note:Note) return note.direction % 4 == i && note.direction > 3)];

        for (note in noteTargets) {
            if (note != null) {
                if (note.canBeHit) {
                    if (controlJusts[note.direction % 4]) {
                        note.isHit = true;
                        note.wasHit = true;
                    }

                    if (note.isSustain) {
                        if (controlPresses[note.direction % 4]) note.isHeld = true;
                    }
    
                    if (note.isHeld && note.isHit && !controlPresses[note.direction % 4]) {
                        note.wasReleased = true;
                    }
                }
                else {
                    if (controlJusts[note.direction % 4]) {
                        playerStrums.members[note.direction % 4].playAnim("pressed");
                    }
                }
            }
        }

        notes.forEach(function(note:Note) {
            
            note.y = (strumLineNotes.members[0].y - (Conductor.songPosition - note.time) * (0.45 * FlxMath.roundDecimal(note.scrollSpeed, 1)));
            note.x = strumLineNotes.members[note.direction].x;

            note.canBeHit = (Conductor.songPosition >= note.time - Conductor.stepLength * 4 && // BELOW THE STRUMS
							 Conductor.songPosition <= note.time + Conductor.stepLength && // ABOVE THE STRUMS
                             noteTargets.contains(note));

            if (note.direction > 3) {
                if (Conductor.songPosition > note.time + Conductor.stepLength && !note.isHit) {
                    removeNote(note);
                }
            }
            updateOpponentNotes(note, Conductor.songPosition);

            playerInputs(note, Conductor.songPosition);
        });
    }

	function addNotes() {
		if (unspawnNotes[0] != null) {
			var note:Note = unspawnNotes[0];
			if (note.time - Conductor.songPosition < 3000 && notes.length - 1 <= maxNotes * 2) {
				note.x = -note.width * 2; // They spawn on the top left for a single frame so we just move em out the way :]
				note.camera = camHUD;
				notes.add(note);
				unspawnNotes.splice(unspawnNotes.indexOf(note), 1);
			}
		}
    }

	function noteMiss(direction:Int) {
		var strum:StrumNote = playerStrums.members[direction % 4];
		strum.playAnim("pressed", true);
		boyfriend.playAnim(singDirections[direction % 4] + "miss", true);
	}

    function noteHit(note:Note, strum:StrumNote) {
        var targetCharacter:Character = (note.direction > 3) ? boyfriend : dad;
        targetCharacter.playAnim(singDirections[note.direction % 4], true);
        strum.playAnim("confirm");
        removeNote(note);
    }

	function sustainHit(note:Note, strum:StrumNote) {
		var targetCharacter:Character = (note.direction > 3) ? boyfriend : dad;
        targetCharacter.playAnim(singDirections[note.direction % 4], true);
        strum.playAnim("confirm");
        setUpNoteRect(note, strum);
    }

	function setUpNoteRect(note:Note, strum:StrumNote) {
        note.note.visible = false;
        var sustain:FlxSprite = note.sustain;
        var tail:FlxSprite = note.tail;
        var strumCenter:Float = strum.y + strum.height / 2;

        var susDist:Float = Math.abs(sustain.y - strumCenter);
        var tailDist:Float = Math.abs(tail.y - strumCenter);

        var susRect:FlxRect = new FlxRect(0, sustain.y, sustain.frameWidth, sustain.frameHeight);
        if (sustain != null && sustain.scale != null) {
            susRect.y = susDist / note.sustain.scale.y;
            note.sustain.clipRect = susRect;

            if (susRect.y >= sustain.height / sustain.scale.y) {
                var tailRect:FlxRect = new FlxRect(0, tail.y, susRect.width, tail.height);
                
                tailRect.y = tailDist / tail.scale.y;
                note.tail.clipRect = tailRect;
            }
        }
    }

	function checkNoteRating(note:Note):String {
		var noteTimeDiff:Float = Math.abs(Conductor.songPosition - note.time);
		var rating:String = "sick";

		if (noteTimeDiff > Conductor.safeZoneOffset * Conductor.shitZone)
			rating = 'shit';
		else if (noteTimeDiff > Conductor.safeZoneOffset * Conductor.badZone)
			rating = 'bad';
		else if (noteTimeDiff > Conductor.safeZoneOffset * Conductor.goodZone)
			rating = 'good';
		return rating;
	}
	
	function updateOpponentNotes(note:Note, time:Float) {
        var strum:StrumNote = opponentStrums.members[note.direction % 4];
        if (time >= note.time) {
            if (note.direction <= 3) {
                if (!note.isSustain) {
                    noteHit(note, strum);
                    return;
                }
                // The rest of this handles sustains.
                sustainHit(note, strum);
                if (Conductor.songPosition >= note.time + note.sustainLength) {
                    removeNote(note);
                }
            }
        }
    }

	function playerInputs(note:Note, time:Float) {
        var strum:StrumNote = playerStrums.members[note.direction % 4];
        if (note.isHit) note.canBeHit = true;

        /**
         * Alright lets break this down.
         */
        if (note.canBeHit) {
            /**
             * The note has been hit, time to see if its a sustain or not.
             */
            if (note.isHit) {
                // We set this since the code for removing notes triggers otherwise.
                note.canBeHit = true;

                if (note.wasHit) {
                    getRating(note);
                }

                // Note isn't a sustain, hit it.
                if (!note.isSustain) noteHit(note, strum);
                else {
                    // This "event" is only fired once and is only used here so we can align
                    // the sustain to the strumline and adjust its length.
                    if (note.wasHit) {
                        snapToStrum(note);
                    }

                    // During holding, was this note let go?
                    if (note.wasReleased) {
                        // It WAS let go, but when?
                        // bullshit magic to make release timing a little lenient, so you dont have to wait until the absolute
                        // end of the sustain to let it go.
                        if (Conductor.songPosition - note.time - note.sustainLength < Conductor.stepLength * note.scrollSpeed) {
                            removeNote(note);
                        }

                        // This gets run when the note was released early.
                        // TODO: Implement.
                        else {

                        }
                        // noteMiss(note.direction);
                    }
                    // Note is still being held, trigger the sustain hit.
                    if (note.isHeld) {
                        if (Conductor.songPosition >= note.time + note.sustainLength) removeNote(note);
                        sustainHit(note, strum);
                    }
                    // honestly i dont know what this does???
                    // FIXME: Figure out what this does.
                    else {
                        removeNote(note);
                    }
                    note.wasHit = false;
                }
            }
        }
    }

	function getRating(note:Note) {
        // How far away the note was hit from the strum in miliseconds.
        var timeDiff:Int = Std.int(Math.abs(Conductor.songPosition - note.time));

        // The judgement that the rating object will how.
        // bad by default. 
        var trueJudgement:String = "bad";

        // Used when going through the judgement map.
        // Keep at some high value.
        var minTime:Int = 1000;
        
        for (judgement in RatingObject.judgements.keys()) {
            var judgementTime = RatingObject.judgements.get(judgement);

            // Is the time at which the note was hit less than the judgement time.
            if (timeDiff <= judgementTime) {
                if (judgementTime <= minTime) {
                    minTime = judgementTime;

                    trueJudgement = judgement;    
                }
            }
        }

        var ratingObject:RatingObject = new RatingObject(300, 200, trueJudgement);
        ratingObject.judgement = trueJudgement;
        ratingObject.scale.set(0.7, 0.7);
        ratingObject.acceleration.y = 1000;

        ratingObject.velocity.y -= 100 * FlxG.random.float(0.8, 1.2);
        ratingObject.velocity.x = 20 * FlxG.random.float(0.8, 1.2);
        if (FlxG.random.bool() == true) ratingObject.velocity.x *= -1;

        ratingObject.camera = camHUD;
        add(ratingObject);
    }

	function removeNote(note:Note) {
		if (notes.members[notes.members.indexOf(note)] != null) {
			notes.members[notes.members.indexOf(note)].destroy();
			notes.remove(notes.members[notes.members.indexOf(note)], true);
		}
	}

	/**
	 * Snaps the sustain bit of the note to the strum and increases its length.
	 * Used for when the note isnt hit at the right time
	 */
	function snapToStrum(note:Note) {
        var prevNoteY:Float = note.y;
        note.time = Conductor.songPosition;
		note.y = (strumLineNotes.members[0].y - (Conductor.songPosition - note.time) * (0.45 * note.scrollSpeed));

		var dist = prevNoteY - note.y;

        note.sustain.setGraphicSize(note.sustain.width, note.sustain.height + dist);
        note.sustain.updateHitbox();
        note.sustain.y = note.note.y + note.note.height / 2;
		note.sustainLength += dist;
	}

	public function endSong():Void {
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		PlayerSettings.menuControls();
		sectionStart = false;
		FlxG.switchState(new SwagMenu());
	}

	var endingSong:Bool = false;

	function setBoyfriendInvuln(time:Float = 5 / 60) {
		invuln = true;
		FlxTimer.wait(time, ()->{ invuln = false; });
	}

	function setCanMiss(time:Float = 10 / 60) {
		canHit = true;
		FlxTimer.wait(time, ()->{ canHit = false; });
	}

	override function stepHit() {
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition)) > 20
			|| (Math.abs(vocals.time - (Conductor.songPosition)) > 20)) {
				resyncVocals();
				trace("resyncing");
			}

		super.stepHit();
	}

	override function beatHit() {
		super.beatHit();
		if (curBeat % 2 == 0) {
			if (boyfriend.canDance) {
				boyfriend.dance();
			}
			if (dad.canDance)
				dad.dance();
		}
	}

	/**
	 * Focuses the camera on the opponent.
	 * If `tween` is null, `FlxEase.quartOut` is used
	 */
	function camFocusOpponent(?time:Float = 1.9, ?tween:EaseFunction) {
		tween ??= FlxEase.quartOut;
		var followX = dad.getGraphicBounds().x + dad.getGraphicBounds().width / 2 + 150;
		var followY = dad.getGraphicBounds().y + dad.getGraphicBounds().height / 2 - 50;
		camMove(followX, followY, 1.3, FlxEase.quintOut, "dad");
		camChangeZoom(defaultCamZoom, 1, FlxEase.quartOut);
	}

	/**
	 * Focuses the camera on Boyfriend.
	 * @param camMoveTime The amount of time it'll take the camera to move to Boyfriend.
	 * @param camZoomTime The amount of time it'll take the camera to zoom in on Boyfriend.
	 * @param camMoveTween Which tween to use for the camera movement.
	 * @param camZoomTween Which tween to use for the camera zoom.
	 */
	function camFocusBF(?camMoveTime:Float = 1.9, ?camZoomTime:Float = 1.3, ?camMoveTween:EaseFunction, ?camZoomTween:EaseFunction) {
		camMoveTween ??= FlxEase.quartOut;
		camZoomTween ??= FlxEase.quintOut;

		var followX = boyfriend.getGraphicBounds().x + boyfriend.getGraphicBounds().width / 2 - 150;
		var followY = boyfriend.getGraphicBounds().y + boyfriend.getGraphicBounds().height / 2 - 100;

		camMove(followX, followY, 	  1.3, camMoveTween, "bf");
		camChangeZoom(defaultCamZoom, camZoomTime, camZoomTween);
	}

	/**
	 * Moves the `camFollow` object. If no time is given, the tween happens instantly.
	 * @param x The x position the camera should focus on.
	 * @param y The y position the camera should focus on.
	 * @param time The amount of time the tween will take.
	 * @param ease Which ease to use. FlxEase.ease.
	 * @param focus Which character the camera is focusing on. can be bf, dad, or gf.
	 * @param onComplete Which function to run when the tween is finished. Isn't run if the time is 0.
	 */
	function camMove(x:Float, y:Float, time:Float = 0, ease:EaseFunction, ?focus:String = "", ?onComplete:TweenCallback):Void {
		onComplete ??= function(tween:FlxTween) {};

		camTween.cancel();
		if (time > 0)
			camTween = FlxTween.tween(camFollow, {x: x, y: y}, time, {ease: ease, onComplete: onComplete});
		else
			camFollow.setPosition(x, y);

		camFocus = focus;
	}

	/**
	 * Changes the zoom of `camGame`. If no time is given, the tween happens instantly.
	 * @param zoom The new zoom of the camera.
	 * @param time The amount of time it'll take to tween.
	 * @param ease Which ease to use. FlxEase.ease.
	 * @param onComplete Which function to run when the tween is finished. Isn't run if the time is 0.
	 */
	function camChangeZoom(zoom:Float, time:Float = 0, ?ease:EaseFunction, ?onComplete:TweenCallback):Void {
		onComplete ??= function(tween:FlxTween) {};

		camZoomTween.cancel();
		if (time > 0) {
			camZoomTween = FlxTween.tween(camGame, {zoom: zoom}, time, {ease: ease, onComplete: onComplete});
			camZoomTween.start();
		}
		else camGame.zoom = zoom;
	}

	/**
	 * Changes the zoom of `camHUD`. If no time is given, the tween happens instantly.
	 * @param zoom The new zoom of the camera.
	 * @param time The amount of time it'll take to tween.
	 * @param ease Which ease to use. FlxEase.ease.
	 * @param onComplete Which function to run when the tween is finished. Isn't run if the time is 0.
	 */
	function uiChangeZoom(zoom:Float, time:Float = 0, ?ease:EaseFunction, ?onComplete:TweenCallback):Void {
		onComplete ??= function(tween:FlxTween) {};

		uiZoomTween.cancel();
		if (time > 0) {
			uiZoomTween = FlxTween.tween(camHUD, {zoom: zoom}, time, {ease: ease, onComplete: onComplete});
			uiZoomTween.start();
		}
		else camHUD.zoom = zoom;
	}

	override public function onFocus(){
		super.onFocus();
		if(Config.noFpsCap && !paused) {
			openfl.Lib.current.stage.frameRate = 999;
		}
		else {
			openfl.Lib.current.stage.frameRate = 144;
		}
	}
}