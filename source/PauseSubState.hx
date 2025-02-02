package;

import flixel.tweens.FlxTween;
import config.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import PlayState;

class PauseSubState extends MusicBeatSubstate
{
	public function new() {
		super();
		openfl.Lib.current.stage.frameRate = 144;

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		FlxG.bitmapLog.viewCache();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		PlayState.instance.persistentUpdate = false;

		if (controls.BACK) {
			unpause(); 
		}
	}

	function unpause(){
		FlxTween.globalManager.active = true;
		if(Config.noFpsCap)
			openfl.Lib.current.stage.frameRate = 999;
		close();
	}
}
