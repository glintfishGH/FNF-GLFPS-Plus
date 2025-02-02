package glibs;

/**
 * Logger class for pretty logging.
 * TODO: Add posInfos and rest functions.
 */
class GLogger {
    private static function ansi(color:AnsiColor):Dynamic {
        return '\033[38;5;${color}m';
    }

    private static function escape():String {
        return "\u001b[0m";
    }

    private static function print(message:Dynamic, color:AnsiColor, printLine = true) {
        Sys.println(ansi(color) + message + escape());
    }

    /**
     * WARNING: Only one paramater can be traced.
     */
    public static function general(message:Dynamic) {
        print(message, PINK);
    }

    public static function info(message:Dynamic) {
        print("[ INFO ] " + message, BLUE);
    }

    public static function error(message:Dynamic) {
        print("[ ERROR ] " + message, RED);
    }

    public static function warning(message:Dynamic) {
        print("[ WARNING ] " + message, YELLOW);
    }

    public static function success(message:Dynamic) {
        print("[ SUCCESS ] " + message, GREEN);
    }

    /**
     * Custom logger message
     * @param message Message to log
     * @param type [ `type` ] `message`.
     * @param color 
     */
    public static function custom(message:Dynamic, type:String, color:AnsiColor) {
        print('[ $type ] $message', color);
    }
}

enum abstract AnsiColor(Int) from Int to Int {
    var BLACK = 0;
    var RED = 1;
    var GREEN = 2;
    var YELLOW = 3;
    var BLUE = 4;
    var PINK = 5;
    var TURQUOISE = 6;

    var GRAY = 16;
}