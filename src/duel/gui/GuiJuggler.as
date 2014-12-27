package duel.gui {
	import starling.animation.IAnimatable;
	import starling.animation.Juggler;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class GuiJuggler extends Juggler
	{
		public var speed:Number = 1.0;
		
		override public function advanceTime( time:Number ):void 
		{
			time *= speed;
			super.advanceTime( time );
		}
		
		public function get isIdle():Boolean
		{
			return objects.length <= 0;
		}
		
		public function xtween(target:Object, time:Number, properties:Object):IAnimatable 
		{
			super.removeTweens( target );
			return super.tween(target, time, properties);
		}
	}
}