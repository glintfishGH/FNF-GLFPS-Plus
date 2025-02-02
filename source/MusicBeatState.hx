package;

import cpp.vm.Gc;
import flixel.FlxG;
import Conductor.BPMChangeEvent;

class MusicBeatState extends UIStateExt
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var totalBeats:Int = 0;
	private var totalSteps:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	override function create() {
		super.create();
		FlxG.bitmap.clearUnused();
		FlxG.bitmapLog.viewCache();
	}

	override function update(elapsed:Float) {
		everyStep();
		updateCurStep();
		updateBeat();

		super.update(elapsed);
	}

	private function updateBeat():Void {
		curBeat = Math.round(curStep / 4);
	}

	/**
	 * CHECKS EVERY FRAME
	 */
	private function everyStep():Void {
		if (Conductor.songPosition > lastStep + Conductor.stepLength - Conductor.safeZoneOffset 
		 || Conductor.songPosition < lastStep + Conductor.safeZoneOffset) {
			if (Conductor.songPosition > lastStep + Conductor.stepLength) {
				stepHit();
			}
		}
	}

	private function updateCurStep():Void {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime) {
				lastChange = Conductor.bpmChangeMap[i];
			}
		}
		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepLength);
	}

	public function stepHit():Void {
		totalSteps += 1;
		lastStep += Conductor.stepLength;

		// If the song is at least 3 steps behind
		if (Conductor.songPosition > lastStep + (Conductor.stepLength * 3)) {
			lastStep = Conductor.songPosition;
			totalSteps = Math.ceil(lastStep / Conductor.stepLength);
		}

		if (totalSteps % 4 == 0)
			beatHit();
	}

	public function beatHit():Void {
		lastBeat += Conductor.beatLength;
		totalBeats += 1;
	}
}
