package base.input;

import flixel.FlxG;
import openfl.events.KeyboardEvent;
import lime.app.Event;
import openfl.ui.Keyboard;

enum KeyState
{
	PRESSED;
	RELEASED;
}

typedef KeyCall = (Int, KeyState) -> Void; // ID in Array, State;
typedef BindCall = (String, Int, KeyState) -> Void; // Name, ID in Array, State;
// for convenience;
typedef Key = Null<Int>;

class Controls
{
	//
	public static var keyPressed:Event<KeyCall> = new Event<KeyCall>();
	public static var keyReleased:Event<KeyCall> = new Event<KeyCall>();

	public static var onKeyPressed:Event<BindCall> = new Event<BindCall>();
	public static var onKeyReleased:Event<BindCall> = new Event<BindCall>();

	private static var actions:Map<String, Array<Key>> = [
		// NOTE KEYS
		"left" => [Keyboard.LEFT],
		"down" => [Keyboard.DOWN],
		"up" => [Keyboard.UP],
		"right" => [Keyboard.RIGHT],
		// UI KEYS
		"ui_left" => [Keyboard.LEFT],
		"ui_down" => [Keyboard.DOWN],
		"ui_up" => [Keyboard.UP],
		"ui_right" => [Keyboard.RIGHT],
		"accept" => [Keyboard.ENTER],
		"pause" => [Keyboard.ENTER, Keyboard.P],
		"back" => [Keyboard.ESCAPE, Keyboard.BACKSPACE],
		// MISC GAME KEYS
		"reset" => [Keyboard.R, Keyboard.END],
		"autoplay" => [Keyboard.NUMBER_6],
		"skipDiag" => [Keyboard.SHIFT, Keyboard.END],
		"debug" => [Keyboard.NUMBER_7, Keyboard.NUMBER_8],
	];

	public static var keysHeld:Array<Key> = [];

	public static function init()
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
	}

	public static function destroy()
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
	}

	public static function onKeyPress(event:KeyboardEvent)
	{
		//
		if (FlxG.keys.enabled)
		{
			var keyCode:Int = event.keyCode;
			if (!keysHeld.contains(keyCode))
			{
				keysHeld.push(keyCode);
				keyPressed.dispatch(keyCode, PRESSED);

				for (key in getKeyFromEvent(keyCode))
					onKeyPressed.dispatch(key, keyCode, PRESSED);
			}
		}
	}

	public static function onKeyRelease(event:KeyboardEvent)
	{
		//
		if (FlxG.keys.enabled)
		{
			var keyCode:Int = event.keyCode;
			if (keysHeld.contains(keyCode))
			{
				keysHeld.remove(keyCode);
				keyReleased.dispatch(keyCode, RELEASED);

				for (key in getKeyFromEvent(keyCode))
					onKeyReleased.dispatch(key, keyCode, RELEASED);
			}
		}
	}

	private static function getKeyFromEvent(key:Key):Array<String>
	{
		//
		if (key == null)
			return [];

		var gottenKeys:Array<String> = [];
		for (action => keys in actions)
		{
			if (keys.contains(key))
				gottenKeys.push(action);
		}

		return gottenKeys;
	}

	public static function getKeyState(key:Key):KeyState
	{
		//
		return keysHeld.contains(key) ? PRESSED : RELEASED;
	}

	public static function getKeyString(action:String)
	{
		//
		if (actions.exists(action))
			return action;
		return '';
	}

	public static function getPressEvent(action:String, type:String = 'justPressed'):Bool
	{
		// stores the last registered key event;
		var lastEvent:String = 'justReleased';

		// check event keys
		if (actions.exists(action))
		{
			var keys:Array<Key> = actions.get(action);

			lastEvent = type;

			// checks if the event is the one specified on the type parameter for the action we want;
			if (Reflect.field(FlxG.keys, 'any' + type.charAt(0).toUpperCase() + type.substr(1))(keys))
				return true;
		}

		return false;
	}

	public static function setKeys(action:String, keys:Array<Key>)
	{
		//
		actions.set(action, keys);
	}

	public static function setKey(action:String, id:Int, key:Key)
	{
		//
		if (actions.exists(action))
			actions.get(action)[id] = key;
	}
}