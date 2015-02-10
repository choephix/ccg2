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
		
		protected function get context():SpaceContext
		{ return space.context }
		
		protected function lerp( from:Number, to:Number, ratio:Number ):Number
		{ return from + ( to - from ) * ratio }
	}
}