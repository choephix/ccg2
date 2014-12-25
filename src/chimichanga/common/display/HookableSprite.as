package chimichanga.common.display {
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	/**
	 * HookableSprite behaves like any regular Sprite, only you can also use 
	 * the method hookTo() to make sure the Sprite and its contents are always 
	 * rendered relative tp the position of the target DisplayObject instead 
	 * of its parent as usual.
	 * 
	 * Particular uses for this are when you want visual elements to follow
	 * the position of a certain DisplayObject, but don't want to add it as
	 * a child for reasons which have to do with draw call order or the 
	 * structure of your code.
	 * 
	 * Examples:
		 * Character health bar - you want it to always be positioned relative 
		 to the character, but also need it to render over the world in which
		 the character exists, and possibly use the same draw call as the 
		 rest of your UI
	 * 
     * @see DisplayObject
     * @see DisplayObjectContainer
     * @see Sprite
	 * 
	 * @inheritDoc
	 * 
	 * @author choephix
	 */
	public class HookableSprite extends Sprite {
		
		private var mHookee:DisplayObject;
		
        /** @inheritDoc */
		public function HookableSprite()
		{
			super();
		}
		
		//
		
		/** Set a new hook-target for this Sprite. The sprite will then always 
		 * render relative not to its parent, but to this target. Any previously 
		 * defined hook-target will be overriden. */
		public function hookTo( target:DisplayObject ):void
		{
			if ( mHookee )
			{
				unhook();
			}
			mHookee = target;
		}
		
		/** Unhook this Sprite from its previously defined hook-target if any.
		 * This object will then continue to render relative to its parent
		 * as any regular starling Sprite would. */
		public function unhook():void 
		{
			mHookee = null;
		}
		
		// overrides
				
        /** @inheritDoc */
        public override function render(support:RenderSupport, parentAlpha:Number):void
        {
			if ( mHookee != null )
			{
				support.transformMatrix(mHookee);
			}
			super.render( support, parentAlpha );
        }
		
	}
	
}