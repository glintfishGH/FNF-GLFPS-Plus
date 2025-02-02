package;

import flixel.util.FlxTimer;
import flixel.addons.text.FlxTypeText;

using StringTools;

/**
 * Slightly modified implementation of `FlxTypeText`.
 * Has the ability to pause for certain symbols using the `waitChars` map
 */
class TypeText extends FlxTypeText {
    /**
     * Which characters, when inserted into the `text` field, will get deleted and then delay 
     * text typing.
     * 
     * Key -> Symbol / Chararacter
     * 
     * Value -> Delay in seconds
     */
    public var waitChars:Map<String, Float> = new Map<String, Float>();

    override function update(elapsed:Float) {
        super.update(elapsed);

        /**
         * Go through all the keys of the `waitChars` map.
         */
        for (char in waitChars.keys()) {
            /**
             * Found the character.
             */
            if (_finalText.charAt(_length) == char) {
                /**
                 * Magic bullshit to remove said character so it doesn't display.
                 * Split the text into two while excluding the waitChar, then merge the two strings back.
                 */
                var leftStr:String = _finalText.substring(0, _length);
                var rightStr:String = _finalText.substring(_length + 1, _finalText.length);
                _finalText = leftStr + rightStr;

                paused = true;
                // Wait until the keys value time has passed to continue typing.
                FlxTimer.wait(waitChars.get(char), function () {
                    paused = false; 
                });
            }
        }
    }

    /**
     * Removes all the `waitChar` characters from the text.
     */
    public function removeWaitChars() {
        // Remove all the "wait" characters, since they usually only get removed during typing.
        // First, loop through all the characters.
        for (i in 0... _finalText.length) {
            var finalText:String = _finalText;

            // Then the waitChars map
            for (key in waitChars.keys()) {
                // character is a waitChar
                if (finalText.charAt(i) == key) {
                    var removedStr = removeCharacter(finalText, i);
                    finalText = removedStr;
                    _finalText = finalText;
                }
            }
        }
    }

    /**
     * Removes a character from `string` at `pos`.
     * @param pos The position of the character.
     * 
     * FIXME: Untested.
     */
    private function removeCharacter(string:String, pos:Int):String {
        var leftStr:String = string.substring(0, pos);
        var rightStr:String = string.substring(pos + 1, string.length);
        return leftStr + rightStr;
    }
}