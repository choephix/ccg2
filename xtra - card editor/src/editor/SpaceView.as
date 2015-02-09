package editor
{
	
	/**
	 * ...
	 * @author choephix
	 */
	public class SpaceView
	{
		public const groups:Vector.<CardGroup> = new Vector.<CardGroup>();
		private var _space:Space;
		private var _active:Boolean;
		
		private var _y:Number;
		
		public function SpaceView( space:Space, y:Number, defaultGroup:CardGroup )
		{
			this._y = y;
			this._space = space;
			addGroup( defaultGroup );
		}
		
		public function addGroup( g:CardGroup ):void
		{
			g.view = this;
			g.tformContracted.y = _y + .5 * ( _space.height - 100 );
			g.tformContracted.x = 90 + groups.length * 180;
			groups.push( g );
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function set active( value:Boolean ):void
		{
			_active = value;
			var gi:int;
			//for ( gi = 0; gi < groups.length; gi++ )
				//groups[ gi ].visible = value;
		}
		
		public function get y():Number
		{
			return _y;
		}
	
	}

}