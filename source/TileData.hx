enum abstract TileData(RawTileData) from RawTileData to RawTileData
{
	public function new(x:Int, y:Int, key:Int)
	{
		this = {
			x: x,
			y: y,
			key: key,
		};
	}

	public function data() return this;

	public function getX() return data().x;

	public function getY() return data().y;

	public function getKey() return data().key;

	public function setKey(key:Int) return data().key = key;

	public function samePosition(tiledata:TileData) return getX() == tiledata.getX() && getY() == tiledata.getY();

	public function is(tiledata:TileData) return samePosition(tiledata) && getKey() == tiledata.getKey();

	@:to
	public function toString():String return 'x_${getX()}@y_${getY()}@key_${getKey()}@';
}
