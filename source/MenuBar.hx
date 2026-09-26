import openfl.display.PNGEncoderOptions;
import haxe.crypto.Base64;
import haxe.Json;
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

	final textSize = 16;

	var bg:FlxSprite;

	var importImage:FlxText;
	var removeImage:FlxText;
	var tileNumber:FlxText;

	var importMap:FlxText;
	var exportMap:FlxText;

	var position:FlxText;

	public function new()
	{
		super();

		add(bg = new FlxSprite().makeGraphic(1, 1));
		bg.scale.set(FlxG.width, 32);
		bg.updateHitbox();
		bg.color = 0xFF7F7F7F;

		add(importImage = new FlxText(0, 0, 0, 'Import Image', textSize));
		importImage.x = importImage.size;
		importImage.y = importImage.size / 4;

		add(removeImage = new FlxText(0, 0, 0, 'Remove Image', textSize));
		removeImage.x = importImage.x + importImage.width + removeImage.size;
		removeImage.y = removeImage.size / 4;

		add(tileNumber = new FlxText(0, 0, 0, 'Tile : # / #', textSize));
		tileNumber.x = removeImage.x + removeImage.width + tileNumber.size;
		tileNumber.y = tileNumber.size / 4;

		add(importMap = new FlxText(0, 0, 0, 'Import Map', textSize));
		importMap.y = importMap.size / 4;

		add(exportMap = new FlxText(0, 0, 0, 'Export Map', textSize));
		exportMap.y = exportMap.size / 4;

		add(position = new FlxText(0, 0, 0, 'Position', textSize));
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

		if (FlxG.mouse.overlaps(importMap)) onImportMapClicked();
		if (FlxG.mouse.overlaps(exportMap)) onExportMapClicked();
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
					PlayState.loadImage(bmp.bitmapData, fr.name);
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
		if (!PlayState.hadImages()) return;

		var image = PlayState.getImages()[tile];

		var tileTiles = [for (_tile in PlayState.getTiles()) if (_tile.getKey() == tile) _tile];

		for (_tile in PlayState.getTiles()) if (_tile.getKey() > tile) _tile.setKey(_tile.getKey() - 1);
		for (_tile in tileTiles) PlayState.getTiles().remove(_tile);

		final finalEntry = tile == PlayState.getImages().length;
		final firstEntry = tile == 0;

		FlxG.bitmap.removeByKey(image.key);
		PlayState.getImages().remove(image);

		incrementTile((finalEntry && firstEntry) ? 0 : (firstEntry) ? 0 : -1);
	}

	function onTileNumberClicked() incrementTile((FlxG.keys.pressed.SHIFT) ? -1 : 1);

	function onImportMapClicked() {}

	final pngEncoder = new PNGEncoderOptions();

	function onExportMapClicked()
	{
		var date = Date.now();
		var dateStr = '${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}_${date.getTime() / 1000}';

		var mapData:MapData = new MapData([for (tile in PlayState.getTiles()) tile.toString()], [
			for (image in PlayState.getImages()) Base64.encode(image.bitmap.encode(image.bitmap.rect, pngEncoder))
		]);

		var fr:FileReference = new FileReference();
		fr.save(Json.stringify(mapData, null, '\t'), 'TilerMap-${dateStr}.json');
	}

	public function incrementTile(amount:Int, ?refresh = true)
	{
		tile += amount;

		if (tile > PlayState.getImages().length - 1) tile = 0;
		if (tile < 0) tile = PlayState.getImages().length - 1;

		if (refresh) PlayState.refresh();
	}

	public function refresh()
	{
		incrementTile(0, false);

		position.text = PlayState.getPositionText();
		position.x = bg.width - position.size - position.width;

		importImage.color = (FlxG.mouse.overlaps(importImage)) ? 0xFFFFFF00 : 0xFFFFFFFF;

		tileNumber.text = 'Tile : ' + ((PlayState.hadImages()) ? '${tile + 1} / ${PlayState.getImages().length}' : '0 / 0');
		tileNumber.color = (PlayState.hadImages()) ? 0xFFFFFFFF : 0xFFFF0000;
		if (FlxG.mouse.overlaps(tileNumber) && (PlayState.hadImages())) tileNumber.color = 0xFFFFFF00;

		removeImage.color = (PlayState.hadImages()) ? 0xFFFFFFFF : 0xFF222222;
		removeImage.alpha = (PlayState.hadImages()) ? 1 : 0.5;
		if (FlxG.mouse.overlaps(removeImage) && (PlayState.hadImages())) removeImage.color = 0xFFFFFF00;

		importMap.x = tileNumber.x + tileNumber.width + (importMap.size * 4);
		importMap.color = (FlxG.mouse.overlaps(importMap)) ? 0xFFFFFF00 : 0xFFFFFFFF;

		exportMap.x = importMap.x + importMap.width + exportMap.size;
		exportMap.color = (FlxG.mouse.overlaps(exportMap)) ? 0xFFFFFF00 : 0xFFFFFFFF;
	}
}
