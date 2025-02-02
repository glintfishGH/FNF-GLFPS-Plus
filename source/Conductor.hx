package;

typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

/**
 * TODO: Document and make an instance.
 * Static conductors suck.
 */
class Conductor {
	public static var bpm(default, set):Float = 100;

	/**
	 * The amount of time a single beat lasts.
	 * Measured in miliseconds.
	 */
	public static var beatLength:Float = (60 / bpm) * 1000;

	/**
	 * The amount of time a single step lasts.
	 * Measured in miliseconds.
	 */
	public static var stepLength:Float = beatLength / 4;

	/**
	 * The amount of time a single measure lasts.
	 * Measured in miliseconds.
	 */
	public static var measureLength:Float = beatLength * 4;

	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var goodZone:Float = 0.40;
	public static var badZone:Float = 0.60;
	public static var shitZone:Float = 0.80;

	public static var safeFrames:Float = 8;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	static function set_bpm(value:Float):Float {
		beatLength = (60 / value) * 1000;
		stepLength = beatLength / 4;

		return bpm = value;
	}
}