package;

import flixel.system.FlxAssets;
import flixel.sound.FlxSound;
import glibs.GLogger;
import openfl.media.Sound;
#if sys
import sys.FileSystem;
#end

import flixel.graphics.frames.FlxAtlasFrames;

/**
 * TODO: Document.
 */
class Paths
{
    static final audioExtension:String = "ogg";

    inline static public function file(key:String, location:String, extension:String):String{
        var data:String = 'assets/$location/$key.$extension';
        return data;
    }

    inline static public function image(key:String, forceLoadFromDisk:Bool = false):Dynamic{
        var data:String = file(key, "images", "png");

        if(ImageCache.exists(data) && !forceLoadFromDisk) return ImageCache.get(data);
        return data;
    }

    static inline function loadStreamed(folder:String, key:String):Sound {
        return Sound.fromAudioBuffer(lime.media.AudioBuffer.fromVorbisFile(lime.media.vorbis.VorbisFile.fromFile(
            'assets/$folder/$key.ogg'
        )));
    }

    public static inline function loadStreamedAudio(audioName:String):Sound {
        return loadStreamed("audio", audioName);
    }

    public static inline function overworld(key:String):String {
        return 'assets/overworld/$key';
    }

    inline static public function xml(key:String, ?location:String = "images"){
        return file(key, location, "xml");
    }

    inline static public function text(key:String, ?location:String = "data"){
        return file(key, location, "txt");
    }

    inline static public function json(key:String, ?location:String = "data"){
        return file(key, location, "json");
    }

    inline static public function sound(key:String){
        return file("snd_" + key, "audio", audioExtension);
    }

    inline static public function music(key:String){
        return file("mus_" + key, "audio", audioExtension);
    }

    inline static public function voices(key:String):FlxSound {
        var sound:FlxSound = new FlxSound().loadEmbedded(openfl.media.Sound.fromFile('assets/songs/$key/voices.ogg'));
        return sound;
    }

    inline static public function inst(key:String):FlxSound {
        var sound:FlxSound = new FlxSound().loadEmbedded(openfl.media.Sound.fromFile('assets/songs/$key/inst.ogg'));
        return sound;
    }

    inline static public function getSparrowAtlas(key:String){
        return FlxAtlasFrames.fromSparrow(image(key), xml(key));
    }

    inline static public function getPackerAtlas(key:String){
        return FlxAtlasFrames.fromSpriteSheetPacker(image(key), text(key, "images"));
    }

    inline static public function video(key:String){
        return file(key, "videos", "mp4");
    }
    
    inline static public function font(key:String, ?extension:String = "ttf"){
        return file(key, "fonts", extension);
    }
}