package duel.display.fields 
{
	import duel.cards.Card;
	import duel.G;
	import duel.GameSprite;
	import duel.table.CreatureField;
	import starling.animation.IAnimatable;
	import starling.display.Image;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureFieldOverlay extends GameSprite implements IAnimatable
	{
		private var exhaustClock:Image;
		private var field:CreatureField;
		
		public function initialize( field:CreatureField ):void
		{
			this.field = field;
			
			juggler.add( this );
			
			exhaustClock = assets.generateImage( "exhaustClock", false, true );
			exhaustClock.x = G.CARD_W * 0.25;
			exhaustClock.y = G.CARD_H * 0.00;
			exhaustClock.alpha = 0.0;
			exhaustClock.touchable = false;
			this.addChild( exhaustClock );
		}
		
		public function advanceTime(time:Number):void 
		{
			exhaustClock.alpha = lerp( exhaustClock.alpha, 
				( !field.isEmpty && field.topCard.exhausted ? 1.0 : 0.0 ), .1 );
		}
	}
}