package;

import flixel.tweens.FlxTween;
import haxe.ds.StringMap;
import flixel.FlxSprite;

class RatingObject extends FlxSprite {
    public static var judgements:StringMap<Int> = [
        "sick" => 150,
        "good" => 225, 
        "bad" =>  275,
        "shit" => 350
    ];

    private var ratings:Array<String> = ["sick", "good", "bad", "shit"];

    public var judgement(default, set):String;
    public function new(x:Float = 0, y:Float = 0, judgement:String) {
        super(x, y);

        frames = Paths.getSparrowAtlas("ratings");
        for (i in 0...ratings.length) {
            animation.addByPrefix(ratings[i], ratings[i] + "0", 24, false);
        }

        this.judgement = judgement;
    }

    function set_judgement(value:String):String {
        this.animation.play(value);
        FlxTween.tween(this, {alpha: 0}, 0.3, {onComplete: function(tween) {
            this.destroy();
        }});
        return judgement = value;
    }
}