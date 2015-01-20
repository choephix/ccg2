package dev 
{
	import duel.cards.Card;
	import duel.cards.properties.cardprops;
	import duel.display.utils.ColorScheme;
	import starling.core.Starling;
	
	use namespace cardprops;
	/**
	 * ...
	 * @author choephix
	 */
	public class Temp 
	{
		public static function getColorForCard( card:Card ):uint 
		{
			if ( card.type.isCreature )
			{
				if ( card.propsC.isToken ) 
					return ColorScheme.getColorForCreatureToken( true );
				if ( card.propsC.needTribute ) 
					return ColorScheme.getColorForCreatureNeedsTribute( true );
				if ( card.propsC.flippable ) 
					return ColorScheme.getColorForCreatureFlippable( true );
				return ColorScheme.getColorForCreature( true );
			}
			if ( card.type.isTrap )
			{
				if ( card.propsT.isPersistent )
					return ColorScheme.getColorForTrapPersistent( true );	
				else
					return ColorScheme.getColorForTrap( true );	
			}
			return 0x0;
		}
		
		public static function tweenAppSize( w:Number, h:Number, onComplete:Function=null ):void
		{
			Starling.juggler.removeTweens( Main.me );
			Starling.juggler.tween( Main.me, .250,
				{ 
					appWidth : w,
					appHeight : h,
					onComplete : onComplete
				} );
		}
		
	}
}