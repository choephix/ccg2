package duel.display.fx 
{
	import chimichanga.common.display.Sprite;
	import chimichanga.global.utils.MathF;
	import duel.display.cards.CardSprite;
	import duel.GameSprite;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.MovieClip;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardFlames extends GameSprite implements IAnimatable
	{
		public var on:Boolean = true;
		
		private var mc:MovieClip;
		
		public function CardFlames() 
		{
			mc  = App.assets.generateMovieClip( "fx-flaming-", false, true, 30 );
			mc.blendMode = BlendMode.ADD;
			mc.scaleX =
			mc.scaleY = 1.0 / 0.67;
			mc.play();
			mc.alpha = 0.0;
			addChild( mc );
		}
		
		public function advanceTime( time:Number ):void 
		{
			mc.advanceTime( time );
			mc.alpha = MathF.lerp( mc.alpha, on && game.interactable ? 1.0 : 0.0, .29 );
			
			if ( cardSprite )
				this.scaleX = Math.abs( cardSprite.flippedness );
		}
		
		public function get cardSprite():CardSprite { return parent as CardSprite }
	}
}