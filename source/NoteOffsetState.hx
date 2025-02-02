import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

class NoteOffsetState extends FlxState {
    var note:FlxSprite;
	var noteDirs:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    var animIndex(default, set):Int;

    var offsetArr:Array<Array<Float>> = [[26, 26], [29, 29], [27, 27], [28, 28]];
    
    override function create() {
        super.create();
        note = new FlxSprite();
        note.frames = Paths.getSparrowAtlas("NOTE_assets");
        note.antialiasing = true;
        note.scale.set(0.7, 0.7);
        note.updateHitbox();
        note.scrollFactor.set();

		note.animation.addByPrefix('static', "arrow" + noteDirs[0], 12, false);
        note.animation.addByPrefix('pressed', noteDirs[0].toLowerCase() + " press", 12, false);
        note.animation.addByPrefix('confirm', noteDirs[0].toLowerCase() + " confirm", 12, false);

        // note.animation.onFinish.add(function (name:String) {
        //     if (name == "confirm") {
        //         note.animation.play('static', true);
        //         note.centerOffsets();
        //     }
        // });
        note.animation.play('static');
        note.screenCenter();
        add(note);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxG.keys.justPressed.A) animIndex--;
        if (FlxG.keys.justPressed.D) animIndex++;

        if (FlxG.keys.justPressed.SPACE) {
            note.animation.play("confirm");
        }
        if (FlxG.keys.justPressed.ENTER) {
            note.animation.play("static");
        }

        if (note.animation.curAnim.name == "confirm")
            note.offset.set(offsetArr[animIndex][0] ?? 0, offsetArr[animIndex][1] ?? 0);
        else note.offset.set(0, 0);

        var up:Bool = FlxG.keys.justPressed.UP;
        var down:Bool = FlxG.keys.justPressed.DOWN;
        var left:Bool = FlxG.keys.justPressed.LEFT;
        var right:Bool = FlxG.keys.justPressed.RIGHT;

        if (left) {
            note.offset.x += 1;
            offsetArr[animIndex][0] = note.offset.x;
        }
        if (right) {
            note.offset.x -= 1;
            offsetArr[animIndex][0] = note.offset.x;
        }
        if (up) {
            note.offset.y += 1;
            offsetArr[animIndex][1] = note.offset.y;
        }
        if (down) {
            note.offset.y -= 1;
            offsetArr[animIndex][1] = note.offset.y;
        }

        trace(note.offset);
    }

    function set_animIndex(value:Int):Int {
        value = FlxMath.wrap(value, 0, noteDirs.length - 1);
        note.animation.addByPrefix('static', "arrow" + noteDirs[value], 12, false);
        note.animation.addByPrefix('pressed', noteDirs[value].toLowerCase() + " press", 12, false);
        note.animation.addByPrefix('confirm', noteDirs[value].toLowerCase() + " confirm", 12, false);
        note.animation.play("static");
        return animIndex = value;
    }
}