package meta.state.menus;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;
import meta.data.ScriptHandler;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;

using StringTools;

/*
	Typedef for Menu Preferences
	carries information for items
	menu background images and other minor customization stuffs
 */
typedef MainMenuDef =
{
	var staticBack:String;
	var flashingBack:String;
	var staticBackColor:Array<Int>;
	var flashingBackColor:Array<Int>;
	var options:Array<String>;
}

/*
	currently, the Main Menu is completely handled by a script located on the assets/scripts/menus folder
	you can get as expressive as you can with that, create your own custom menu
 */
class MainMenuState extends MusicBeatState
{
	var parsedJson:MainMenuDef;
	var mainScript:ScriptHandler;

	override function create()
	{
		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		#if DISCORD_RPC
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		// uh
		persistentUpdate = persistentDraw = true;

		try // set up the menu preferences json if it exists;
		{
			parsedJson = haxe.Json.parse(Paths.getTextFile('scripts/menus/MainMenu.json'));
		}
		catch (e) // ...or just use a hardcoded fallback one;
		{
			parsedJson = haxe.Json.parse('{
				"staticBack": "menuBG",
				"flashingBack": "menuDesat",
				"staticBackColor": null,
				"flashingBackColor": [253, 113, 155],
				"options": ["story mode", "freeplay", "options"]
			}');
		}

		// set up the main menu script itself
		mainScript = new ScriptHandler(Paths.module('MainMenu', 'scripts/menus'));
		mainScript.call('create', []);

		mainScript.set('parsedJson', parsedJson);

		mainScript.set('add', add);
		mainScript.set('remove', remove);
		mainScript.set('this', this);
		mainScript.set('controls', controls);

		super.create();

		mainScript.call('postCreate', []);
	}

	override function update(elapsed:Float)
	{
		mainScript.call('update', [elapsed]);
		super.update(elapsed);
		mainScript.call('postUpdate', [elapsed]);

		mainScript.set('elapsed', elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		mainScript.call('beatHit', [curBeat]);
		mainScript.set('curBeat', curBeat);
	}

	override function stepHit()
	{
		super.stepHit();

		mainScript.call('stepHit', [curStep]);
		mainScript.set('curStep', curStep);
	}

	override public function destroy()
	{
		mainScript.call('destroy', []);
		super.destroy();
	}

	override public function onFocus()
	{
		mainScript.call('onFocus', []);
		super.onFocus();
	}

	override public function onFocusLost()
	{
		mainScript.call('onFocusLost', []);
		super.onFocusLost();
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxText))
			cast(Object, FlxText).antialiasing = false;
		return super.add(Object);
	}
}
