package ecs.components 
{
	import ecs.core.ComponentBase;
	import mx.core.IBorder;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class PointBounds extends ComponentBase implements IBoundsComponent
	{
		private var x:Number;
		private var y:Number;
		
		public function PointBounds( x:Number = 0.0, y:Number = 0.0 ) 
		{
			this.x = x;
			this.y = y;
		}
		
		public function get xLeft():Number		{ return entity.x + x; }
		public function get xRight():Number 	{ return entity.x + x; }
		public function get yTop():Number 		{ return entity.y + y; }
		public function get yBottom():Number	{ return entity.y + y; }
	}

}