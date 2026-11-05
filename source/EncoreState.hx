package;

import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import sys.FileSystem;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.effects.FlxSkewedSprite;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

// Menu in stile Freeplay, ma con una sola voce: too-slow-encore
class EncoreState extends MusicBeatState
{
	// Nome dell'immagine in assets/images/fpstuff/ e nome della canzone
	static inline var ENCORE_ID:String = 'too-slow-encore';

	var whiteshit:FlxSprite;

	var curSongSelected:Int = 0;

	var textgrp:FlxTypedGroup<FlxText>;

	var songArray:Array<String> = [ENCORE_ID];

	var boxgrp:SkewSpriteGroup;

	var bg:FlxSprite;

	var scrollingBg:FlxBackdrop;

	var cdman:Bool = true;

	var selecting:Bool = false;

	var charText:FlxText;

	var scoreText:FlxText;

	override function create()
	{
		whiteshit = new FlxSprite().makeGraphic(1280, 720, FlxColor.WHITE);
		whiteshit.alpha = 0;

		bg = new FlxSprite().loadGraphic(Paths.image('backgroundlool'));
		bg.screenCenter();
		bg.setGraphicSize(1280, 720);
		add(bg);

		scrollingBg = new FlxBackdrop(Paths.image('sidebar'), 0, 1, false, true);
		add(scrollingBg);

		textgrp = new FlxTypedGroup<FlxText>();

		boxgrp = new SkewSpriteGroup();

		var box:FlxSkewedSprite = new FlxSkewedSprite(0, 0);
		box.loadGraphic(Paths.image('FreeBox'));
		boxgrp.add(box);
		box.ID = 0;
		box.setGraphicSize(Std.int(box.width / 1.7));

		FlxG.log.add('searching for ' + 'assets/images/fpstuff/' + ENCORE_ID + '.png');

		var char:FlxSkewedSprite = new FlxSkewedSprite(0, 0);
		if (FileSystem.exists('assets/images/fpstuff/' + ENCORE_ID + '.png'))
		{
			FlxG.log.add(ENCORE_ID + ' found');
			char.loadGraphic(Paths.image('fpstuff/' + ENCORE_ID));
		}
		else
		{
			char.loadGraphic(Paths.image('fpstuff/placeholder'));
		}
		boxgrp.add(char);
		char.ID = 0;
		char.setGraphicSize(Std.int(box.width / 1.7));

		boxgrp.x = -335;

		var uhhdumbassline:FlxSprite = new FlxSprite(300).makeGraphic(10, 720, FlxColor.BLACK);
		add(uhhdumbassline);

		add(boxgrp);

		add(textgrp);

		scoreText = new FlxText(30, 105, FlxG.width, "");
		scoreText.setFormat("Sonic CD Menu Font Regular", 18, FlxColor.WHITE, CENTER);
		scoreText.y -= 36;
		scoreText.x -= 20;
		add(scoreText);

		charText = new FlxText(30, 10, FlxG.width, "Encore");
		charText.setFormat("Sonic CD Menu Font Regular", 36, FlxColor.WHITE, CENTER);
		charText.y -= 10;
		charText.x -= 23;
		add(charText);

		////// LOADING SHIT FOR THE BEGINNING ////////
		boxgrp.forEach(function(sprite:FlxSkewedSprite)
		{
			FlxTween.tween(sprite, {alpha: 1}, 0.2);
			FlxTween.tween(sprite.scale, {x: 0.58, y: 0.58}, 0.2, {ease: FlxEase.expoOut});
			FlxTween.tween(sprite.skew, {x: 0, y: 0}, 0.2, {ease: FlxEase.expoOut});
		});

		for (i in 0...songArray.length)
		{
			var text:FlxText = new FlxText(350, FlxG.height / 2 - 30 * songArray.length + i * 30 * songArray.length, FlxG.width,
				StringTools.replace(songArray[i], "-", " "));
			text.setFormat("Sonic CD Menu Font Regular", 36, 0xFFFFFFFF, CENTER);
			text.ID = i;
			textgrp.add(text);
		}

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Encore Menu", null);
		#end

		add(whiteshit);

		super.create();
	}

	override function update(elapsed:Float)
	{
		scrollingBg.y += 1;

		super.update(elapsed);

		var upP = FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W;
		var downP = FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S;
		var accepted = controls.ACCEPT;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
				changeSelection(-1);
			if (gamepad.justPressed.DPAD_DOWN)
				changeSelection(1);
		}

		if (cdman)
		{
			if (upP)
				changeSelection(-1);
			if (downP)
				changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (!selecting)
				FlxG.switchState(new MainMenuState());
			else
			{
				scoreText.text = "";
				curSongSelected = 0;
				selecting = false;
				textgrp.forEach(function(text:FlxText)
				{
					FlxTween.cancelTweensOf(text);
					text.alpha = 1;
				});
			}
		}

		if (accepted && cdman && selecting)
		{
			cdman = false;

			PlayState.SONG = Song.loadFromJson(songArray[curSongSelected].toLowerCase() + '-hard', songArray[curSongSelected].toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 2;
			PlayState.storyWeek = 1;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			PlayStateChangeables.nocheese = false;

			FlxTween.tween(whiteshit, {alpha: 1}, 0.4);
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			new FlxTimer().start(0.8, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}

		if (accepted && cdman && !selecting)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			selecting = true;
			if (textgrp.members != null)
			{
				textgrp.forEach(function(text:FlxText)
				{
					FlxTween.cancelTweensOf(text);
					text.alpha = 1;
					if (text.ID == curSongSelected)
					{
						scoreText.text = "Score: " + Highscore.getScore(songArray[curSongSelected], 2);
						FlxTween.tween(text, {alpha: 0.5}, 0.5, {ease: FlxEase.expoOut, type: FlxTween.PINGPONG});
					}
				});
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		// C'è una sola "casella" (too-slow-encore): si naviga solo tra le canzoni una volta selezionata.
		if (!selecting)
			return;

		var nextSelected = curSongSelected + change;
		if (nextSelected < 0)
			nextSelected = songArray.length - 1;
		if (nextSelected >= songArray.length)
			nextSelected = 0;

		if (curSongSelected != nextSelected)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			curSongSelected = nextSelected;
			if (textgrp.members != null)
			{
				textgrp.forEach(function(text:FlxText)
				{
					FlxTween.cancelTweensOf(text);
					text.alpha = 1;
					if (text.ID == curSongSelected)
					{
						scoreText.text = "Score: " + Highscore.getScore(songArray[curSongSelected], 2);
						FlxTween.tween(text, {alpha: 0.5}, 0.5, {ease: FlxEase.expoOut, type: FlxTween.PINGPONG});
					}
				});
			}
		}
	}
}
