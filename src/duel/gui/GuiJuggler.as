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
		
		private var _fakeTime:Number = .0;
		
		override public function advanceTime( time:Number ):void 
		{
			time *= speed;
			
			_fakeTime -= time;
			if ( _fakeTime < .0 )
				_fakeTime = .0;
			
			super.advanceTime( time );
		}
		
		public function get isIdle():Boolean
		{
			return objects.length <= 0 && _fakeTime < Number.MIN_VALUE;
		}
		
		public function xtween(target:Object, time:Number, properties:Object):IAnimatable 
		{
			super.removeTweens( target );
			return super.tween(target, time, properties);
		}
		
		public function addFakeTime( time:Number ):void
		{
			_fakeTime += time;
		}
	}
}