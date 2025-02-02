package;

import openfl.display3D.textures.Texture;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.FlxG;
import openfl.display3D.Context3DTextureFormat;

using StringTools;

/**
 * Creates textures that exist only in VRAM and not standard RAM.
 * 
 * Originally written by Smokey, additional developement by Rozebud.
 * TODO: Document the rest.
 */
class GPUBitmap {
	static var trackedTextures:Array<TexAsset> = new Array<TexAsset>();

	/**
	 * Creates BitmapData for a sprite and deletes the reference stored in RAM leaving only the texture in VRAM.
	 * @param path The file path.
	 * @param texFormat The texture format.
	 * @param optimizeForRender Generates mipmaps.
	 * @param _cachekey Key for the Texture Buffer cache.
	 * @return BitmapData
	 */
	public static function create(path:String, texFormat:Context3DTextureFormat = BGRA, optimizeForRender:Bool = false, ?_cachekey:String):BitmapData {
		_cachekey ??= path;

		for (tex in trackedTextures) {
			if (tex.cacheKey == _cachekey) {
				return BitmapData.fromTexture(tex.texture);
			}
		}

		var bmp = Assets.getBitmapData(path, false);
		var _texture = FlxG.stage.context3D.createTexture(bmp.width, bmp.height, texFormat, optimizeForRender);
		_texture.uploadFromBitmapData(bmp);
		bmp.dispose();
		bmp.disposeImage();
		var trackedTex = new TexAsset(_texture, _cachekey);
		trackedTextures.push(trackedTex);
		return BitmapData.fromTexture(_texture);
	}

	public static function disposeAllTextures():Void {
		var counter:Int = 0;
		for (texture in trackedTextures) {
			texture.texture.dispose();
			trackedTextures.remove(texture);
			counter++;
		}
	}

	public static function disposeTexturesByKey(key:String) {
		var counter:Int = 0;
		for (i in 0...trackedTextures.length) {
			if (trackedTextures[i].cacheKey.contains(key)) {
				trackedTextures[i].texture.dispose();
				trackedTextures.remove(trackedTextures[i]);
				counter++;
			}
		}
	}

	public static function disposeAll() {
		for (i in 0...trackedTextures.length) {
			trackedTextures[i].texture.dispose();
		}

		trackedTextures = new Array<TexAsset>();
	}
}

class TexAsset {
	public var texture:Texture;
	public var cacheKey:String;

	public function new(texture:Texture, cacheKey:String) {
		this.texture = texture;
		this.cacheKey = cacheKey;
	}
}
