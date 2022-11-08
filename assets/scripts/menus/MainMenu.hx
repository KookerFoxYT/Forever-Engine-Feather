// import basic flixel bullshit
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxTextBorderStyle;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
// import states and stuff
import states.TitleState;
import states.menus.StoryMenuState;
import states.menus.FreeplayState;
import states.menus.MainMenuState;
import states.menus.OptionsMenuState;

////////////////////////////////////////////
// main objects
var bg:FlxSprite;
var magenta:FlxSprite;
var camFollow:FlxObject;
var menuItems:Dynamic; // damn
// other
var curSelected:Float = 0;
var lastCurSelected:Int = 0;
var imageDirectory:String = 'base';

function postCreate()
{
	// create background
	generateBackground();

	// add the camera
	camFollow = new FlxObject(0, 0, 1, 1);
	add(camFollow);

	menuItems = ForeverTools.createTypedGroup(menuItems);
	add(menuItems);

	// loop through the menu options
	for (i in 0...parsedJson.options.length)
	{
		var menuItem:FlxSprite = new FlxSprite(0, 70 + (i * 160));
		menuItem.frames = Paths.getSparrowAtlas('menus/base/menuItems/' + parsedJson.options[i]);

		// add the animations in a cool way (real
		menuItem.animation.addByPrefix('idle', parsedJson.options[i] + " basic", 24);
		menuItem.animation.addByPrefix('selected', parsedJson.options[i] + " white", 24);
		menuItem.animation.play('idle');

		// set the id
		menuItem.ID = i;

		// placements
		menuItem.screenCenter(ForeverTools.getPoint('x'));
		// if the id is divisible by 2
		if (menuItem.ID % 2 == 0)
			menuItem.x += 1000;
		else
			menuItem.x -= 1000;

		// actually add the item
		menuItems.add(menuItem);
		menuItem.scrollFactor.set();
		menuItem.antialiasing = true;
		menuItem.updateHitbox();
	}

	// set the camera to actually follow the camera object that was created before
	var camLerp:Float = Main.framerateAdjust(0.10);
	FlxG.camera.follow(camFollow, null, camLerp);

	updateSelection();

	var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0,
		"Forever Engine Legacy v" + Main.gameVersion + " [Feather Build v" + Main.featherVersion + "]", 12);
	versionShit.scrollFactor.set();
	versionShit.setFormat(Paths.font("vcr.ttf"), 16, 0xFFFFFFFF, ForeverTools.setTextAlign('left'), FlxTextBorderStyle.OUTLINE, 0xFF000000);
	add(versionShit);

	//
}

var selectedSomethin:Bool = false;
var counterControl:Float = 0;

function update(elapsed:Float)
{
	var up = controls.UI_UP;
	var down = controls.UI_DOWN;
	var up_p = controls.UI_UP_P;
	var down_p = controls.UI_DOWN_P;
	var controlArray:Array<Bool> = [up, down, up_p, down_p];

	if ((controlArray.contains(true)) && (!selectedSomethin))
	{
		for (i in 0...controlArray.length)
		{
			// here we check which keys are pressed
			if (controlArray[i] == true)
			{
				// if single press
				if (i > 1)
				{
					// up == 2 - down == 3
					if (i == 2)
						curSelected--;
					else if (i == 3)
						curSelected++;

					if (curSelected < 0)
						curSelected = parsedJson.options.length - 1;
					else if (curSelected >= parsedJson.options.length)
						curSelected = 0;

					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
			//
		}
	}
	else
	{
		// reset variables
		counterControl = 0;
	}

	if ((controls.BACK) && (!selectedSomethin))
	{
		//
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		Main.switchState(this, new TitleState());
	}

	if ((controls.ACCEPT) && (!selectedSomethin))
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		var flashValue:Float = 0.1;
		if (Init.trueSettings.get('Disable Flashing Lights'))
			flashValue = 0.2;
		else
			FlxFlicker.flicker(magenta, 0.8, 0.1, false);

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
			{
				FlxTween.tween(spr, {alpha: 0, x: FlxG.width * 2}, 0.4, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});
			}
			else
			{
				FlxFlicker.flicker(spr, 1, flashValue, false, false, function(flick:FlxFlicker)
				{
					var daChoice:String = parsedJson.options[Math.floor(curSelected)];

					switch (daChoice)
					{
						case 'story mode':
							Main.switchState(this, new StoryMenuState());
						case 'freeplay':
							Main.switchState(this, new FreeplayState());
						case 'options':
							Main.switchState(this, new OptionsMenuState());
					}
				});
			}
		});
	}

	if (Math.floor(curSelected) != lastCurSelected)
		updateSelection();
}

function postUpdate(elapsed:Float)
{
	menuItems.forEach(function(menuItem:FlxSprite)
	{
		menuItem.screenCenter(ForeverTools.getPoint('x'));
	});
}

function generateBackground()
{
	bg = new FlxSprite(-85);
	bg.loadGraphic(Paths.image('menus/' + imageDirectory + '/' + parsedJson.staticBack));
	bg.scrollFactor.set(0, 0.12);
	bg.setGraphicSize(Std.int(bg.width * 1.1));
	bg.updateHitbox();
	bg.screenCenter();
	bg.antialiasing = true;
	add(bg);

	var staticColor:Array<Int> = parsedJson.staticBackColor;
	if (parsedJson.staticBackColor != null)
		bg.color = ForeverTools.fromRGB(staticColor[0], staticColor[1], staticColor[2]);

	magenta = new FlxSprite(-85);
	magenta.loadGraphic(Paths.image('menus/' + imageDirectory + '/' + parsedJson.flashingBack));
	magenta.scrollFactor.set(0, 0.12);
	magenta.setGraphicSize(Std.int(magenta.width * 1.1));
	magenta.updateHitbox();
	magenta.screenCenter();
	magenta.visible = false;
	magenta.antialiasing = true;
	add(magenta);

	var flashColor:Array<Int> = parsedJson.flashingBackColor;
	if (parsedJson.flashingBackColor != null)
		magenta.color = ForeverTools.fromRGB(flashColor[0], flashColor[1], flashColor[2]);
}

function updateSelection()
{
	// reset all selections
	menuItems.forEach(function(spr:FlxSprite)
	{
		spr.animation.play('idle');
		spr.updateHitbox();
	});

	// set the sprites and all of the current selection
	camFollow.setPosition(menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().x,
		menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().y);

	if (menuItems.members[Math.floor(curSelected)].animation.curAnim.name == 'idle')
		menuItems.members[Math.floor(curSelected)].animation.play('selected');

	menuItems.members[Math.floor(curSelected)].updateHitbox();

	lastCurSelected = Math.floor(curSelected);
}