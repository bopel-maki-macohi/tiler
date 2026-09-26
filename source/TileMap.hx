import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class TileMap extends FlxSpriteGroup
{
	public static final TILE_SIZE:Int = 16;

	public var tiles:Array<TileData> = [];

	public var cursor:FlxSprite;

	public var tile:FlxSprite;

	public function new()
	{
		super();

		cursor = new FlxSprite().makeGraphic(1, 1);
		cursor.scale.set(TILE_SIZE, TILE_SIZE);
		cursor.updateHitbox();
		cursor.alpha = .25;

		tile = new FlxSprite();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ANY) onKeyPressed();
	}

	override function draw()
	{
		super.draw();

		if (tile != null) for (_tile in tiles)
		{
			final graphic = PlayState.getTile(_tile.getKey());

			if (graphic != null) tile.loadGraphic(graphic);
			else tile.loadGraphic('flixel/images/logo/default.png');

			// tile.setGraphicSize(TILE_SIZE);

			tile.setPosition(_tile.getX() * TILE_SIZE, _tile.getY() * TILE_SIZE);

			tile.cameras = cameras;
			tile.draw();
		}

		if (cursor != null)
		{
			cursor.cameras = cameras;
			cursor.draw();
		}
	}

	function onKeyPressed()
	{
		final LEFT = FlxG.keys.anyJustPressed([A, LEFT]);
		final DOWN = FlxG.keys.anyJustPressed([S, DOWN]);
		final UP = FlxG.keys.anyJustPressed([W, UP]);
		final RIGHT = FlxG.keys.anyJustPressed([D, RIGHT]);

		if (LEFT) cursor.x -= TILE_SIZE;
		if (DOWN) cursor.y += TILE_SIZE;
		if (UP) cursor.y -= TILE_SIZE;
		if (RIGHT) cursor.x += TILE_SIZE;

		final ENTER = FlxG.keys.anyJustPressed([ENTER]);
		final SHIFT_P = FlxG.keys.anyPressed([SHIFT]);

		if (ENTER) if (PlayState.hasTiles())
		{
			if (SHIFT_P) PlayState.removeTile(cursor);
			else PlayState.placeTile(cursor);
		}

		PlayState.refresh();
	}

	public function refresh()
	{
		cursor.color = (PlayState.hasTiles()) ? 0xFFFFFFFF : 0xFFFF0000;
	}
}
