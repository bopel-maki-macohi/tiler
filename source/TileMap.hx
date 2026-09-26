import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class TileMap extends FlxSpriteGroup
{
	public static var TILE_SIZE:Int = 16;

	public var tiles:Array<TileData> = [];

	public var cursor:FlxSprite;

	public var tile:FlxSprite;

	public function new()
	{
		super();

		cursor = new FlxSprite();
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
			final key = _tile?.getKey() ?? null;
			final graphic = (key == null || key < 0 || key > PlayState.getImages().length - 1) ? null : PlayState.getImage(key);

			try
			{
				if (graphic != null && !graphic.isDestroyed) tile.loadGraphic(graphic);
				else tile.loadGraphic('flixel/images/logo/default.png');
			}
			catch (e)
			{
				tile.loadGraphic('flixel/images/logo/default.png');
			}

			// tile.setGraphicSize(TILE_SIZE);

			tile.setPosition(_tile.getX() * TILE_SIZE, _tile.getY() * TILE_SIZE);

			tile.cameras = cameras;
			tile.draw();
		}

		if (cursor != null && cursor.visible)
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
		final DELETE = FlxG.keys.anyJustPressed([DELETE, ESCAPE, BACKSPACE]);

		if (ENTER) if (PlayState.hadImages()) PlayState.placeTile(cursor);
		if (DELETE) PlayState.removeTile(cursor);

		PlayState.refresh();
	}

	public function refresh()
	{
		cursor.color = (PlayState.hadImages()) ? 0xFFFFFFFF : 0xFFFF0000;
		cursor.alpha = (PlayState.canPlace(cursor)) ? .25 : .125;

		cursor.scale.set(1, 1);

		if (!PlayState.hadImages())
		{
			cursor.makeGraphic(1, 1);
			cursor.scale.set(TILE_SIZE, TILE_SIZE);
		}
		else cursor.loadGraphic(PlayState.getImage(PlayState.getCurrentTile()));

		cursor.updateHitbox();
	}
}
