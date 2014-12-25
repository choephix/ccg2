package ecs.components
{
	import ecs.core.ComponentBase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Transform extends ComponentBase
	{
		private var _x:Number;
		private var _y:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _rotation:Number;
		
		private var _dirty:Boolean;
		
		public function Transform()
		{
			_x = 0.0;
			_y = 0.0;
			_scaleX = 1.0;
			_scaleY = 1.0;
			_rotation = 0.0;
			_dirty = true;
		}
		
		public function get dirty():Boolean 
		{
			return _dirty;
		}
		
		public function get rotation():Number 
		{
			return _rotation;
		}
		
		public function set rotation(value:Number):void 
		{
			if ( _rotation == value ) return;
			_rotation = value;
			_dirty = true;
		}
		
		public function get scaleY():Number 
		{
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void 
		{
			if ( _scaleY == value ) return;
			_scaleY = value;
			_dirty = true;
		}
		
		public function get scaleX():Number 
		{
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void 
		{
			if ( _scaleX == value ) return;
			_scaleX = value;
			_dirty = true;
		}
		
		public function get y():Number 
		{
			return _y;
		}
		
		public function set y(value:Number):void 
		{
			if ( _y == value ) return;
			_y = value;
			_dirty = true;
		}
		
		public function get x():Number 
		{
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			if ( _x == value ) return;
			_x = value;
			_dirty = true;
		}
	
	}

}