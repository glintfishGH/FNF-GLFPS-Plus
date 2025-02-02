package glibs;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;

/**
 * The GLGU or GLintGeneralUse class is a class containing a bunch of... general use functions
 */
class GLGU {
    // static var blackBG:FlxSprite;

    static var stamp:Float;

    /**
     * Sets a stamp and begins to time.
     */
    public static function startStamp() {
        stamp = Sys.time();
    }

    /**
     * Ends the stamp and returns the amount of time a process took.
     * @param message 
     */
    public static function endStamp(message:String = "") {
        if (message != "") message = ": " + message;
        trace('Finished process$message (${Sys.time() - stamp})');
    }

    // public static function addBG(?color:FlxColor = FlxColor.BLACK, ?camera:FlxCamera, ?alpha:Float = 1):FlxSprite {
        // blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, color);
        // blackBG.alpha = alpha;
        // blackBG.cameras = [camera];
        // return blackBG;
    // }

    // public static function removeBG() {
        // return blackBG.destroy();
    // }
}