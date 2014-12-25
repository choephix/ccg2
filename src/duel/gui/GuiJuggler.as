package duel.gui {
	import starling.animation.IAnimatable;
	import starling.animation.Juggler;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class GuiJuggler extends Juggler
	{
		
		override public function add( object:IAnimatable ):void
		{
			super.add( object );
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