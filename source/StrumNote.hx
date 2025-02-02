import flixel.FlxSprite;

class StrumNote extends FlxSprite {
	/**
	 * Directions for the notes. Used mainly for loading animations.
	 */
	var noteDirs:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

    private var framerate:Int = 24;

    public var direction:Int = 0;

    /**
     * Loads a new StrumNote
     * @param x X position of this StrumNote.
     * @param y Y position of this StrumNote.
     * @param direction The direction of this note. Sets `this.direction` and is used to load animations.
     */
    public function new(x:Int, y:Int, direction:Int) {
        super(x, y);
        this.direction = direction;
        frames = Paths.getSparrowAtlas("NOTE_assets");
        antialiasing = true;

        // If you're using custom note skins, this is the part you want to change

        // static -> When the arrow is idling / isn't being pressed.
        animation.addByPrefix('static', "arrow" + noteDirs[direction], framerate, false);

        // pressed -> When there isn't a note for the strum to hit / you miss a note.
        animation.addByPrefix('pressed', noteDirs[direction].toLowerCase() + " press", framerate, false);

        // confirm -> When you hit a note.
        animation.addByPrefix('confirm', noteDirs[direction].toLowerCase() + " confirm", framerate, false);

        animation.onFinish.add(function (name:String) {
            if (name != "static") {
                playAnim('static', true);
            }
        });
    }

    public function playAnim(name:String, force:Bool = true) {
        animation.play(name, force);
        centerOffsets();
        centerOrigin();
    }
}