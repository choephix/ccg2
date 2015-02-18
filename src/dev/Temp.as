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
			
			// DONE
			"immortal1",
			"immortal2",
			"man_of_honor",
			"deathdraw",
			"directrager",
			"witchbetsy", 
			"unbreakable", 
			"finalrage", 
			"haggler", 
			"drawhealer", 
			"deckstructor1",
			"battle_healer", 
			"fairturnhealer",
			"powerhealer2", 
			"fairhealer",
			"saviour",
			"reversepiercer",
			"darkassasin2",
			"darkassasin",
			"harshfred", 
			"turnhealer", 
			"bloodhaggler", 
			"grand_bloodhaggler", 
			"drawson2",
			"drawson1", 
			"drawttack",
			"traitor",
			"fateup", 
			"marco", "polo",
			"zig", "zag",
			"banana_a", "banana_b",
			"8ball_1", 
		    "8ball_2", 
		    "8ball_3", 
		    "8ball_4", 
			"joe1", "joe2", "joe3",
			"doe1", "doe2", "doe3",
			
			// TO DO
			
			// FROZEN
			"grand_powerhealer", 
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