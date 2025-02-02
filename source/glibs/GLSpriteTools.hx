package glibs;

import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.BytesInput;
import haxe.zip.Reader;
import haxe.io.Bytes;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using StringTools;

/**
 * TODO: Maybe just remove this, I literally never use this.
 */
class GLSpriteTools {
    /**
     * Calls both the setPosition and scale.set functions in one. Angle is also adjustable here.
     * Just used as a way to save lines.
     * @param object Object you want to target
     * @param x x position
     * @param y y position
     * @param scale the scale of the object.
     * @param angle the angle of the object.
     */
    public static function setFields(object:FlxSprite, ?x:Float, ?y:Float, ?scale:Float, ?angle:Float) {
        object.setPosition(x, y);
        object.scale.set(scale, scale);
        object.angle = angle;
    }

    /**
     * Generates a generic, 50x50 white sprite. 
     * @param x The sprites x position
     * @param y The sprites y position
     * @param width The sprites width
     * @param height The sprites height
     * @param color The sprites color. White by default
     * @return FlxSprite
     */
    public static function createGenericSprite(x:Int = 0, y:Int = 0, width:Int = 50, height:Int = 50, ?color:FlxColor = FlxColor.WHITE):FlxSprite {
        return new FlxSprite(x, y).makeGraphic(width, height, color);
    }

    public static function spriteFromZip(path:String):FlxSprite {
        // Get the actual ZIP file
		var zipInput:Bytes = sys.io.File.getBytes("assets/" + path + ".zip");

		// Contains the files inside the ZIP file
		var zipEntries:List<haxe.zip.Entry> = Reader.readZip(new BytesInput(zipInput));

		// Can't really think of a clean way of doing this without defining these here.
		var zipXml:String = "";
		var zipBmd:openfl.display.BitmapData = null;
		
		for (entry in zipEntries) {
			// Load the PNG file
			if (entry.fileName.endsWith(".png")) {
				zipBmd = openfl.display.BitmapData.fromBytes(Reader.unzip(entry));
			}
			// XML
			else {
				zipXml = Reader.unzip(entry).toString();
			}
			// Assumes only 2 files are in the zip, the PNG and XML.
		}

		// Finally set everything to the new character.
		var zipChar:FlxSprite = new FlxSprite();
		zipChar.frames = FlxAtlasFrames.fromSparrow(zipBmd, zipXml);
		return zipChar;
    }

    public static function multiAtlas(sprites:Array<String>):FlxAtlasFrames {
        var parent:FlxAtlasFrames = Paths.getSparrowAtlas(sprites[0]);
        for (i in 1...sprites.length) {
            var child:FlxAtlasFrames = Paths.getSparrowAtlas(sprites[i]);
            parent.addAtlas(child);
        }
        return parent;
    }
}