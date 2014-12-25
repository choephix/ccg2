package ecs.core 
{
	import starling.display.DisplayObjectContainer;
	/**
	 * ...
	 * @author choephix
	 */
	public class Camera 
	{
		private var target:DisplayObjectContainer;
		public var width:Number;
		public var height:Number;
		
		private var centerX:Number;
		private var centerY:Number;
		
		public function Camera( target:DisplayObjectContainer, width:Number, height:Number ) 
		{
			this.target = target;
			this.width = width;
			this.height = height;
			
			this.centerX = width / 2;
			this.centerY = height / 2;
			
			x = 0.0;
			y = 0.0;
		}
		
		/* DELEGATE starling.display.Sprite */
		
		public function get rotation():Number 
		{
			return target.rotation;
		}
		
		public function set rotation(value:Number):void 
		{
			target.rotation = value;
		}
		
		public function get zoom():Number 
		{
			return target.scaleX;
		}
		
		public function set zoom(value:Number):void 
		{
			if ( value < 0.0 )
				value = 0.0;
			target.scaleX = value;
			target.scaleY = value;
		}
		
		public function get x():Number 
		{
			return target.pivotX;
		}
		
		public function set x(value:Number):void 
		{
			target.x = centerX;
			target.pivotX = value;
		}
		
		public function get y():Number 
		{
			return -target.pivotY;
		}
		
		public function set y(value:Number):void 
		{
			target.y = centerY;
			target.pivotY = -value;
		}
		
	}

}