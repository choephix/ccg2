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
		public static const DECK1:Array = [
			"___kami___", 
			
			// TEST
			"reversepiercer", "drawson2",  "drawson1", 
			"harsh_fred", "turn_healer", 
			"darkassasin2", "darkassasin3",
			"draw_healer", "deckstructor1",
			"direct_rager", "fair_healer", 
			"man_of_honor", "mike",
			"final_rage", "haggler", 
			
			// DONE
			"saviour", "drawttack",
			"traitor", "fate_up", 
			"marco", "polo",
			"zig", "zag",
			"joe1", "joe2", "joe3",
			"doe1", "doe2", "doe3",
			"banana_a", "banana_b",
			"8ball_1", 
		    "8ball_2", 
		    "8ball_3", 
		    "8ball_4", 
		];
		
		public static const DECK2:Array = DECK1;
		//public static const DECK2:Array = [
			//"marco", "polo",
			//"zig", "zag",
			//"banana_a", "banana_b",
		//];
		
		
		public static function getColorForCard( card:Card ):uint 
		{
			if ( card.isCreature )
			{
				if ( card.propsC.isToken ) 
					return ColorScheme.getColorForCreatureToken( true );
				if ( card.propsC.needTribute ) 
					return ColorScheme.getColorForCreatureNeedsTribute( true );
				if ( card.propsC.flippable ) 
					return ColorScheme.getColorForCreatureFlippable( true );
				return ColorScheme.getColorForCreature( true );
			}
			if ( card.isTrap )
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
		
		static public function toCharCodeSum( text:String ):int
		{
			var r:int = 0;
			var i:int = text.length;
			while ( i-- >= 0 )
				r += text.charCodeAt( i );
			return r;
		}
		
	}
}