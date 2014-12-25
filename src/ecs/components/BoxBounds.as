package ecs.components 
{
	import ecs.core.ComponentBase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class BoxBounds extends ComponentBase implements IBoundsComponent 
	{
		private var _xLeft:Number;
		private var _xRight:Number;
		private var _yTop:Number;
		private var _yBottom:Number;
		
		public function BoxBounds( left:Number, right:Number, top:Number, bottom:Number ) 
		{
			_xLeft = left;
			_xRight = right;
			_yTop = top;
			_yBottom = bottom;
		}
		
		public function get xRight():Number 	{ return entity.x + _xRight; }
		public function get xLeft():Number 		{ return entity.x + _xLeft; }
		public function get yTop():Number 		{ return entity.y + _yTop; }
		public function get yBottom():Number 	{ return entity.y + _yBottom; }
		
		public function get xRightLocal():Number 	{ return _xRight; }
		public function get xLeftLocal():Number 	{ return _xLeft; }
		public function get yTopLocal():Number 		{ return _yTop; }
		public function get yBottomLocal():Number 	{ return _yBottom; }
	}

}