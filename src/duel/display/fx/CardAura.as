package duel.display.fx 
{
	import duel.display.cards.CardSprite;
	import duel.GameSprite;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CardAura extends GameSprite implements IAnimatable 
	{
		public var on:Boolean = true;
		
		public function CardAura() 
		{
			this.touchable = false;
		}
		
		public function advanceTime( time:Number ):void 
		{
			//alpha = lerp( alpha, on && game.interactable ? 1.0 : 0.0, .29 );
			if ( cardSprite )
				this.scaleX = Math.abs( cardSprite.flippedness );
		}
		
		public function get cardSprite():CardSprite { return parent as CardSprite }
	}

}