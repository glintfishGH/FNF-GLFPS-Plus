import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

/**
 * A note object that contains the note, sustain and tail in one object.
 * TODO: Update to support recycling. Bring over changes from Glimpse    -glintfish
 */
@:publicFields
class Note extends FlxTypedSpriteGroup<FlxSprite> {
    var note:FlxSprite;
    var sustain:FlxSprite;
    var tail:FlxSprite;

    var time:Float;
    var direction:Int;
    var sustainLength(default, set):Float = 0;
    var isSustain:Bool;

    var scrollSpeed:Float;

    var canBeHit:Bool = false;

    /**
     * Is currently being hit.
     * Mainly used for sustains.
     */
    var isHit:Bool = false;

    /**
     * Gets fired only once.
     */
    var wasHit:Bool = false;

    /**
     * If the note is currently being held.
     * Used for sustains.
     */
    var isHeld:Bool = false;
    var wasReleased:Bool = false;

    var downscroll:Bool = false;

    var colors:Array<String> = ["purple", "blue", "green", "red"];

    public function new(time:Float, direction:Int, sustainLength:Float = 0, ?scrollSpeed:Float = 1) {
        super();
        this.time = time;
        this.direction = direction;
        @:bypassAccessor this.sustainLength = sustainLength;
        this.scrollSpeed = scrollSpeed;
        isSustain = sustainLength != 0;

        note = new FlxSprite();
        note.frames = Paths.getSparrowAtlas("NOTE_assets");
        note.animation.addByPrefix("note", colors[direction % 4] + "0");
        note.animation.play("note");
        note.scale.set(1, 1);
        note.updateHitbox();
        add(note);

        if (isSustain) {
            sustain = new FixedClipSprite();
            sustain.frames = note.frames;
            tail = new FixedClipSprite();
            tail.frames = note.frames;

            // Idk they feel a LITTLE too thin
            sustain.scale.set(1.15, 1);

            sustain.updateHitbox();
            tail.updateHitbox();

            sustain.animation.addByPrefix("sustain", "" + colors[direction % 4] + " hold piece");
            sustain.animation.play("sustain");
            tail.animation.addByPrefix("tail", "" + colors[direction % 4] + " hold end");
            tail.animation.play("tail");

            sustain.setGraphicSize(sustain.width / 4, sustainLength * 0.45 * scrollSpeed - tail.height);
            sustain.updateHitbox();

            sustain.x = note.frameWidth / 2 - sustain.width / 2;
            sustain.y = note.height / 2;
            insert(0, sustain);
            // add(sustain);
    
            tail.setGraphicSize(sustain.width, tail.frameHeight);
            tail.updateHitbox();
            tail.x = sustain.x;
            tail.y = sustain.y + sustain.height - 2;
            add(tail);
        }

        for (member in this.members) 
            member.antialiasing = true;
    }

    // TODO: Update this since it doesn't work properly??
    @:noCompletion function set_sustainLength(value:Float):Float {
        sustain.height = value * 0.45 * scrollSpeed;
        sustain.updateHitbox();
        tail.y = sustain.y + sustain.height - 1; // Realistically i shouldnt have to offset the sprites y but it also causes some bullshit to happen
        return sustainLength = value;
    }
}

/**
 * Used for the sustain and tail.
 * Overrides clipRect to not round down the values.
 */
class FixedClipSprite extends FlxSprite {
    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
    }

    override function set_clipRect(rect:FlxRect):FlxRect {
		if (rect != null) clipRect = rect;
		else clipRect = null;

		if (frames != null) frame = frames.frames[animation.frameIndex];

		return rect;
    }
}