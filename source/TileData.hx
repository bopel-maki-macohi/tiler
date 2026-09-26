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

	public function getX() return this.x;

	public function getY() return this.y;

	public function getKey() return this.key;

	public function is(tiledata:TileData) return getX() == tiledata.getX() && getY() == tiledata.getY() && getKey() == tiledata.getKey();

	@:to
	public function toString():String return 'x_${this.x}@y_${this.y}@key_${this.key}@';
}
