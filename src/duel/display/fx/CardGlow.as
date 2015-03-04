package duel.display.fx 
{
	import chimichanga.common.display.Sprite;
	import chimichanga.global.utils.MathF;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.MovieClip;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardGlow extends Sprite implements IAnimatable
	{
		public var on:Boolean;
		
		private var mc:MovieClip;
		
		public function CardGlow() 
		{
			mc  = App.assets.generateMovieClip( "glowB", false, true, 30 );
			mc.blendMode = BlendMode.ADD;
			mc.scaleX =
			mc.scaleY = 1.0 / .355;
			mc.play();
			mc.alpha = 0.0;
			addChild( mc );
		}
		
		public function advanceTime( time:Number ):void 
		{
			mc.advanceTime( time );
			mc.alpha = MathF.lerp( mc.alpha, on ? 1.0 : 0.0, .09 );
		}
		
	}

}