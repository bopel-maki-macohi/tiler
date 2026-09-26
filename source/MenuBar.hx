import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.LoaderInfo;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class MenuBar extends FlxSpriteGroup
{
	public var tile:Int = 0;

	var bg:FlxSprite;

	var importImage:FlxText;
	var tileNumber:FlxText;

	var position:FlxText;

	public function new()
	{
		super();

		add(bg = new FlxSprite().makeGraphic(1, 1));
		bg.scale.set(FlxG.width, 32);
		bg.updateHitbox();
		bg.color = 0xFF7F7F7F;

		add(importImage = new FlxText(0, 0, 0, 'Import Image', 16));
		importImage.x = importImage.size;
		importImage.y = importImage.size / 4;

		add(tileNumber = new FlxText(0, 0, 0, 'Tile : #', 16));
		tileNumber.x = importImage.x + importImage.width + tileNumber.size;
		tileNumber.y = tileNumber.size / 4;

		add(position = new FlxText(0, 0, 0, 'Position', 16));
		position.y = position.size / 4;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justMoved) onMouseMove();
		if (FlxG.mouse.justPressed) onMouseClicked();
	}

	function onMouseMove()
	{
		importImage.color = 0xFFFFFFFF;
		if (FlxG.mouse.overlaps(importImage)) importImage.color = 0xFFFFFF00;

		tileNumber.color = (PlayState.hasTiles()) ? 0xFFFFFFFF : 0xFFFF0000;
		if (FlxG.mouse.overlaps(tileNumber)) tileNumber.color = 0xFFFFFF00;
	}

	function onMouseClicked()
	{
		if (FlxG.mouse.overlaps(importImage)) onImportImageClicked();
		if (FlxG.mouse.overlaps(tileNumber)) onTileNumberClicked();
	}

	function onImportImageClicked()
	{
		// https://github.com/HaxeFlixel/flixel-demos/blob/dev/UserInterface/FileBrowse/source/PlayState.hx

		var fr:FileReference = new FileReference();
		fr.addEventListener(Event.SELECT, E ->
		{
			var onLoad:Event->Void;

			trace('Loading File: ${fr.name}');
			fr.addEventListener(Event.COMPLETE, onLoad = F ->
			{
				fr.removeEventListener(Event.COMPLETE, onLoad);

				var loader:Loader = new Loader();
				var onImageLoad:Event->Void;

				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoad = G ->
				{
					var loaderInfo:LoaderInfo = cast G.target;
					loaderInfo.removeEventListener(Event.COMPLETE, onImageLoad);
					var bmp:Bitmap = cast(loaderInfo.content, Bitmap);
					PlayState.loadImage(bmp.bitmapData);
				});
				loader.loadBytes(fr.data);
			}, false, 0, true);
			fr.load();
		}, false, 0, true);
		// fr.addEventListener(Event.CANCEL, onCancel, false, 0, true);

		var filters:Array<FileFilter> = new Array<FileFilter>();
		filters.push(new FileFilter("PNG Files", "*.png"));
		filters.push(new FileFilter("JPEG Files", "*.jpg;*.jpeg"));

		fr.browse(filters);
	}

	function onTileNumberClicked()
	{
		if (FlxG.keys.pressed.SHIFT) tile--;
		else tile++;

		if (tile > PlayState.tiles().length - 1) tile = 0;
		if (tile < 0) tile = PlayState.tiles().length - 1;

		refresh();
	}

	public function refresh()
	{
		position.text = PlayState.getPositionText();
		position.x = bg.width - position.size - position.width;

		tileNumber.text = (PlayState.hasTiles()) ? 'Tile : $tile' : 'No Tiles';
	}
}
