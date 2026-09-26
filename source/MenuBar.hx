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
	var removeImage:FlxText;
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

		add(removeImage = new FlxText(0, 0, 0, 'Remove Image', 16));
		removeImage.x = importImage.x + importImage.width + removeImage.size;
		removeImage.y = removeImage.size / 4;

		add(tileNumber = new FlxText(0, 0, 0, 'Tile : # / #', 16));
		tileNumber.x = removeImage.x + removeImage.width + tileNumber.size;
		tileNumber.y = tileNumber.size / 4;

		add(position = new FlxText(0, 0, 0, 'Position', 16));
		position.y = position.size / 4;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justMoved) PlayState.refresh();
		if (FlxG.mouse.justPressed) onMouseClicked();
		if (FlxG.keys.justPressed.ANY) onKeyPressed();
	}

	function onMouseClicked()
	{
		if (FlxG.mouse.overlaps(importImage)) onImportImageClicked();
		if (FlxG.mouse.overlaps(removeImage)) onRemoveImageClicked();
		if (FlxG.mouse.overlaps(tileNumber)) onTileNumberClicked();
	}

	function onKeyPressed()
	{
		var TAB = FlxG.keys.anyJustPressed([TAB]);
		if (TAB) onTileNumberClicked();
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

	function onRemoveImageClicked()
	{
		if (!PlayState.hasTiles()) return;

		for (_tile in PlayState.placedTiles()) if (_tile.getKey() == tile) _tile.setKey(-1);
		PlayState.tiles().remove(PlayState.tiles()[tile]);
		incrementTile(-1);
	}

	function onTileNumberClicked() incrementTile((FlxG.keys.pressed.SHIFT) ? -1 : 1);

	public function incrementTile(amount:Int, ?refresh = true)
	{
		tile += amount;

		if (tile > PlayState.tiles().length - 1) tile = 0;
		if (tile < 0) tile = PlayState.tiles().length - 1;

		if (refresh) PlayState.refresh();
	}

	public function refresh()
	{
		incrementTile(0, false);

		position.text = PlayState.getPositionText();
		position.x = bg.width - position.size - position.width;

		importImage.color = (FlxG.mouse.overlaps(importImage)) ? 0xFFFFFF00 : 0xFFFFFFFF;

		tileNumber.text = 'Tile : ' + ((PlayState.hasTiles()) ? '${tile + 1} / ${PlayState.tiles().length}' : '0 / 0');
		tileNumber.color = (PlayState.hasTiles()) ? 0xFFFFFFFF : 0xFFFF0000;
		if (FlxG.mouse.overlaps(tileNumber) && (PlayState.hasTiles())) tileNumber.color = 0xFFFFFF00;

		removeImage.color = (PlayState.hasTiles()) ? 0xFFFFFFFF : 0xFF222222;
		removeImage.alpha = (PlayState.hasTiles()) ? 1 : 0.5;
		if (FlxG.mouse.overlaps(removeImage) && (PlayState.hasTiles())) removeImage.color = 0xFFFFFF00;
	}
}
