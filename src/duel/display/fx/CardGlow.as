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
	public class CardGlow extends GameSprite implements IAnimatable
	{
		public var on:Boolean;
		
		private var mc:MovieClip;
		
		public function CardGlow() 
		{
			mc  = App.assets.generateMovieClip( "glowB", false, true, 30 );
			mc  = App.assets.generateMovieClip( "card-mist", false, true, 30 );
			mc.blendMode = BlendMode.ADD;
			mc.scaleX =
			mc.scaleY = 1.0 / .449;
			//mc.scaleX =
			//mc.scaleY = 1.0 / .355;
			mc.play();
			mc.alpha = 0.0;
			//mc.color = 0x1155BB;
			//mc.color = 0xFFDD22;
			//mc.color = 0xEE4499;
			addChild( mc );
		}
		
		public function advanceTime( time:Number ):void 
		{
			mc.advanceTime( time );
			mc.alpha = MathF.lerp( mc.alpha, on && game.interactable ? 1.0 : 0.0, .09 );
			
			if ( cardSprite )
				this.scaleX = Math.abs( cardSprite.flippedness );
		}
		
		public function get cardSprite():CardSprite { return parent as CardSprite }
	}
}