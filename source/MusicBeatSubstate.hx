package;

import flixel.FlxSubState;
import backend.Controls;

class MusicBeatSubstate extends FlxSubState
{
	public function new() {
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var totalBeats:Int = 0;
	private var totalSteps:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		super.create();
	}

	override function update(elapsed:Float) {
		everyStep();

		updateCurStep();
		curBeat = Math.round(curStep / 4);

		super.update(elapsed);
	}

	/**
	 * CHECKS EVERY FRAME
	 */
	private function everyStep():Void {
		if (Conductor.songPosition > lastStep + Conductor.stepLength - Conductor.safeZoneOffset
			|| Conductor.songPosition < lastStep + Conductor.safeZoneOffset)
		{
			if (Conductor.songPosition > lastStep + Conductor.stepLength) {
				stepHit();
			}
		}
	}

	private function updateCurStep():Void {
		curStep = Math.floor(Conductor.songPosition / Conductor.stepLength);
	}

	public function stepHit():Void {
		totalSteps += 1;
		lastStep += Conductor.stepLength;

		if (totalSteps % 4 == 0)
			beatHit();
	}

	public function beatHit():Void {
		lastBeat += Conductor.beatLength;
		totalBeats += 1;
	}
}
