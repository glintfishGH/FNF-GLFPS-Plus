import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * TODO: Document.
 * Also change probably?
 */
class Rating extends FlxSprite {
    public var rating(default, set):String;
    var originalY:Float;
    public function new(x:Float, y:Float) {
        super(x, y);
        originalY = y;
        alpha = 0;

        frames = Paths.getSparrowAtlas("ratings");
        animation.addByPrefix("sick", "sick");
        animation.addByPrefix("good", "good");
        animation.addByPrefix("bad",  "bad");
        animation.addByPrefix("shit", "shit");
    }

    function set_rating(value:String):String {
        alpha = 1;

        FlxTween.cancelTweensOf(this);
        animation.play(value, true);
        this.y = originalY - 10;
        FlxTween.tween(this, {y: originalY, alpha: 0}, 0.7, {ease: FlxEase.quartOut});

        return rating = value;
    }
}