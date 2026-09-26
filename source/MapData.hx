import openfl.display.BitmapData;

enum abstract MapData(RawMapData) from RawMapData to RawMapData
{
	public function new(tiles:Array<String>, images:Array<String>)
	{
		this = {
			images: images,
			tiles: tiles,
		};
	}

	public function data() return this;

	@:to
	public function toString() return '$this';
}
