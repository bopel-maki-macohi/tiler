package;

import flixel.FlxObject;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;
import openfl.display.BitmapData;
import flixel.FlxState;

class PlayState extends FlxState
{
	public static var instance:PlayState;

	public static function loadImage(image:BitmapData)
	{
		if (instance == null || image == null) return;

		var graphic = FlxGraphic.fromBitmapData(image);
		graphic.persist = true;

		instance.images.push(graphic);
		refresh();
	}

	public static function hasTiles() return (instance == null) ? false : instance.images.length > 0;

	public static function getTileData(cursor:FlxSprite) return (cursor == null) ? null : new TileData(Math.floor(cursor.x / TileMap.TILE_SIZE),
		Math.floor(cursor.y / TileMap.TILE_SIZE), instance.menubar.tile);

	public static function canPlace(cursor:FlxSprite)
	{
		if (instance == null || cursor == null || !hasTiles()) return false;

		var placeable = true;

		var tile = getTileData(cursor);
		for (_tile in instance.tilemap.tiles)
		{
			if (!placeable) break;
			placeable = !_tile.is(tile);
		}

		return placeable;
	}

	public static function placeTile(cursor:FlxSprite)
	{
		if (instance == null) return;

		var tile = getTileData(cursor);
		if (tile != null) instance.tilemap.tiles.push(tile);
	}

	public static function removeTile(cursor:FlxSprite)
	{
		if (instance == null) return;

		var tile = getTileData(cursor);

		for (_tile in instance.tilemap.tiles) if (_tile.is(tile)) instance.tilemap.tiles.remove(_tile);
	}

	public static function getTile(key:Int):FlxGraphicAsset return instance?.images[key] ?? null;

	public static function getPositionText()
		return (instance?.tilemap?.cursor == null) ? '(X: N / A | Y: N / A)' : '(X: ${Math.floor(instance.tilemap.cursor.x / TileMap.TILE_SIZE)} | Y: ${Math.floor(instance.tilemap.cursor.y / TileMap.TILE_SIZE)})';

	public static function refresh() if (instance != null) instance._refresh();

	public static function tiles() return instance?.images ?? [];

	public var images:Array<FlxGraphic> = [];

	public var menubar:MenuBar;
	public var tilemap:TileMap;

	public var menubarCamera:FlxCamera;
	public var tilemapCamera:FlxCamera;

	public var tilemapCameraFollow:FlxObject;

	override public function create()
	{
		super.create();

		instance = null;
		instance = this;

		FlxG.cameras.reset(menubarCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1));
		FlxG.cameras.add(tilemapCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1), false);

		FlxG.cameras.insert(menubarCamera, Math.floor(FlxG.cameras.list.length / 2), true);
		menubarCamera.bgColor.alpha = 0;

		add(menubar = new MenuBar());

		add(tilemapCameraFollow = new FlxObject());
		add(tilemap = new TileMap());
		tilemapCameraFollow.cameras = tilemap.cameras = [tilemapCamera];

		tilemapCamera.follow(tilemapCameraFollow);

		_refresh();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		tilemapCameraFollow.setPosition(tilemap.cursor.getGraphicMidpoint().x, tilemap.cursor.y);
	}

	override function destroy()
	{
		super.destroy();

		instance = null;
	}

	override function revive()
	{
		super.revive();

		instance = this;
	}

	public function _refresh()
	{
		tilemap.refresh();
		menubar.refresh();
	}
}
