package glibs;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;

/**
 * Contains utils for moving objects, getting positions, scales, etc.
 * This exists purely because I got tired of copy pasting the same functions over and over again.
 * Its kind of ass but it gets the job done.
 */
class GLDebugTools {
    /**
     * Move an FlxObject by a `moveAmount`
     * 
     * @param object The object you want to move
     * @param moveAmount The amount of pixels the object will move. Holding SHIFT will make the object move 10x further
     */
    public static function moveItem(object:FlxObject, moveAmount:Float = 1) {
        if (FlxG.keys.justPressed.LEFT){
            object.x -= (FlxG.keys.pressed.SHIFT) ? moveAmount * 10 : moveAmount;
            trace('x: ${object.x} | y: ${object.y}');
        }
        if (FlxG.keys.justPressed.DOWN){
            object.y += (FlxG.keys.pressed.SHIFT) ? moveAmount * 10 : moveAmount;
            trace('x: ${object.x} | y: ${object.y}');
        }
        if (FlxG.keys.justPressed.UP){
            object.y -= (FlxG.keys.pressed.SHIFT) ? moveAmount * 10 : moveAmount;
            trace('x: ${object.x} | y: ${object.y}');
        }
        if (FlxG.keys.justPressed.RIGHT){
            object.x += (FlxG.keys.pressed.SHIFT) ? moveAmount * 10 : moveAmount;
            trace('x: ${object.x} | y: ${object.y}');
        }
    }

    /**
     * Rotates an `FlxObject` by pressing Q and E.
     * @param object The object you want to rotate.
     * @param rotationAmount The amount the object will rotate.
     */
    public static function rotateItem(object:FlxObject, rotationAmount:Int = 2) {
        if (FlxG.keys.justPressed.Q) {
            object.angle -= rotationAmount;
            trace('angle: ${object.angle}');
        }
        if (FlxG.keys.justPressed.E) {
            object.angle += rotationAmount;
            trace('angle: ${object.angle}');
        }
    }

    /**
     * Scales an `FlxObject` by pressing Q and E.
     * @param object The object to scale.
     * @param scaleAmount The amount to scale by.
     * @param updateHitbox Whether or not to update the `object`s hitbox when scaling.
     */
    public static function scaleItem(object:FlxSprite, scaleAmount:Float = 0.1, ?updateHitbox:Bool = true) {
        if (FlxG.keys.justPressed.Q) {
            object.scale.x -= scaleAmount;
            object.scale.y -= scaleAmount;
            trace('scale: ${object.scale.x}'); // Works because you're adjusting both the x and y scale, so you can use either of them
        }
        if (FlxG.keys.justPressed.E) {
            object.scale.x += scaleAmount;
            object.scale.y += scaleAmount;
            trace('scale: ${object.scale.x}');
        }

        if(updateHitbox)
            object.updateHitbox();
    }
}