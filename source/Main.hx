package;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite {
	public static var fpsDisplay:FPS;

	/**
	 * Current FlxGame instance.
	 * You likely won't need to use this, but it's here just in case.
	 */
	public static var game:FlxGame;

	/**
	 * Current Main instance.
	 */
	public static var ME:Main;

	public function new() {
		super();
		ME = this;

		game = new FlxGame(0, 0, InitState, 144, 144, true);
		addChild(game);

		FlxG.autoPause = false;
		FlxSprite.defaultAntialiasing = false;
		FlxObject.defaultPixelPerfectPosition = true;
		FlxG.stage.quality = LOW;
		FlxG.fixedTimestep = false;

		fpsDisplay = new FPS(10, 3, 0xFFFFFF);
		fpsDisplay.visible = true;
		addChild(fpsDisplay);
	}
}
