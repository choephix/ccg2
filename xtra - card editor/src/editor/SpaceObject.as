package editor 
{
	import starling.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class SpaceObject extends DisplayObjectContainer 
	{
		public var space:Space;
		
		public function SpaceObject() 
		{
			super();
		}
		
		protected function lerp( from:Number, to:Number, ratio:Number ):Number
		{
			return from + ( to - from ) * ratio;
		}
		
	}

}