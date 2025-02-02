package;

import glibs.GLSpriteTools;
import flixel.FlxSprite;

using StringTools;

/**
 * TODO: Document. Probably refactor? Fix idles.
 */
class Character extends FlxSprite
{
	//Global character properties.
	public static var LOOP_ANIM_ON_HOLD:Bool = true; 	//Determines whether hold notes will loop the sing animation. Default is true.
	public static var USE_IDLE_END:Bool = false; 		//Determines whether you will go back to the start of the idle or the end of the idle when letting go of a note. Default is true for FPS Plus, false for base game.

	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	/**
	 * Whether or not this character is allowed to dance.
	 */
	public var canDance:Bool = true;

	/**
	 * Whether or not the character danced. Only true for one frame.
	 */
	public var danced:Bool = false;

	/**
	 * Whether or not the character is currently dancing.
	 */
	public var dancing:Bool = false;

	/**
	 * The amount of time that should pass before the character plays their idle again.
	 */
	public var holdLength:Float = 2000;
	var holdTimer:Float = 0;
	public var stepsUntilRelease:Float = 4;

	public var canAutoAnim:Bool = true;
	public var danceLockout:Bool = false;
	public var animSet:String = "";

	public var deathCharacter:String = "bf";

	public var iconName:String;

	var facesLeft:Bool = false;

	var framerate:Int = 12;

	var endedSing:Bool = true;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?debugMode:Bool = false) {
		super(x, y);
		antialiasing = false;

		animOffsets = new Map<String, Array<Dynamic>>();
		
		this.debugMode = debugMode;
		this.isPlayer = isPlayer;
		curCharacter = character;

		configureCharacter();
		dance();
	}

	function configureCharacter() {
		switch (curCharacter) {
			case 'player':
				frames = Paths.getSparrowAtlas("player");
				animation.addByPrefix('idle', 'BF IDLE instance', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE instance', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE instance', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE instance', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE instance', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS instance', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS instance', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS instance', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS instance', 24, false);

				addOffset('idle');
				addOffset("singUP", -6);
				addOffset("singRIGHT");
				addOffset("singLEFT", -12);
				addOffset("singDOWN");
				addOffset("singUPmiss", -6);
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss", -12);
				addOffset("singDOWNmiss");

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'opponent':
				frames = Paths.getSparrowAtlas("opponent");
				animation.addByPrefix('idle', 	   'Idle1', 24, false);
				animation.addByPrefix('singUP',    'Pose Up1', 24, false);
				animation.addByPrefix('singLEFT',  'Pose Left1', 24, false);
				animation.addByPrefix('singRIGHT', 'Pose Right1', 24, false);
				animation.addByPrefix('singDOWN',  'Pose Down1', 24, false);

				addOffset("idle", 0, 0);
				addOffset("singDOWN", 70, -107);
				addOffset("singRIGHT", -24, -13);
				addOffset("singUP", 30, 50);
				addOffset("singLEFT", 90, -27);

				playAnim('idle');
				facesLeft = true;

			default:
				curCharacter = "bfriend";
				configureCharacter();
		}

		if (((facesLeft && !isPlayer) || (!facesLeft && isPlayer)) && !debugMode){
			flipX = true;

			var oldRight = animation.getByName("singRIGHT").frames;
			var oldRightOffset = animOffsets.get("singRIGHT");
			animation.getByName("singRIGHT").frames = animation.getByName("singLEFT").frames;
			animOffsets.set("singRIGHT", animOffsets.get("singLEFT"));
			animation.getByName('singLEFT').frames = oldRight;
			animOffsets.set("singLEFT", oldRightOffset);

			// IF THEY HAVE MISS ANIMATIONS??
			if (animation.getByName('singRIGHTmiss') != null){
				var oldMiss = animation.getByName("singRIGHTmiss").frames;
				var oldMissOffset = animOffsets.get("singRIGHTmiss");
				animation.getByName("singRIGHTmiss").frames = animation.getByName("singLEFTmiss").frames;
				animOffsets.set("singRIGHTmiss", animOffsets.get("singLEFTmiss"));
				animation.getByName('singLEFTmiss').frames = oldMiss;
				animOffsets.set("singLEFTmiss", oldMissOffset);
			}
		}

		animation.onFrameChange.add(function(name, frameNum, frameIndex) {

		});
		animation.onFinish.add(function(name) {
			if (name != "idle") {
				endedSing = true;
			}
			else {
				dancing = true;
				danced = true;
			}
		});

		glibs.GLogger.success("Configured character: " + curCharacter);
	}

	override function update(elapsed:Float){
		super.update(elapsed);
		if (debugMode) { return; }

		// Turn this into miliseconds.
		if (endedSing) holdTimer += elapsed * 1000;
		if (holdTimer >= holdLength) {
			canDance = true;
			// dance();
		}

		changeOffsets();
	}

	public function dance(?ignoreDebug:Bool = false) {
		if (canDance) {
			playAnim('idle', true);
		}
	}

	public function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		canDance = false;
		if (animName != "idle") {
			dancing = false;
			endedSing = false;
			holdTimer = 0;
		}
		animation.play(animName, force, reversed, frame);
		changeOffsets();
	}

	function changeOffsets() {
		if (animOffsets.exists(animation?.curAnim?.name)) { 
			var animOffset = animOffsets.get(animation.curAnim.name);
			var xOffsetAdjust:Float = animOffset[0];
			if(flipX == true){
				xOffsetAdjust *= -1;
				xOffsetAdjust += frameWidth;
				xOffsetAdjust -= width;
			}
			offset.set(xOffsetAdjust, animOffset[1]); 
		}
		else { offset.set(0, 0); }
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) animOffsets[name] = [x, y];

	public function switchChar(newCharacter:String) {
		curCharacter = newCharacter;
		animOffsets.clear();
		configureCharacter();
		dance();
	}
}
