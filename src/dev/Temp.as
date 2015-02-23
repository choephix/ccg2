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
			
			/**  HELPERS  **/
			"___kami___", 
			"___test___", 
			//"compromiser1",
			//"sneakshot",
			//"motivator",
			"tranquility",
			
			/**  TEST  **/
			"paul1",
			//"all_out_joe",
			//"general2",
			//"crippler",
			//"specialhaste",
			//"paulgrand",
			//"vendeto",
			//"vendeto_grand",
			"spike",
			"devouerer",
			"force_field",
			"emma",
			
			"sneakshot",
			"blinding_rage",
			"final_heal",
			
			/**  DONE (CREATURES)  **/
			"tranquility",
			"glassspike",
			"managiver",
			"actiontaker",
			"up5",
			"stunner",
			"grand_powerhealer", 
			"resurrecter2",
			"resurrecter4",
			"resurrecter66",
			"compromiser1",
			"compromiser2",
			"compromiser3",
			"motivator",
			"confusor",
			"badclown",
			"kamikaze2",
			"kamikaze",
			"nona",
		"freefred",
			"emptyshell",
			"tripplemana",
			"doublemana",
			"blocker",
			"drawban3",
			"drawban2",
			"drawban",
			"jack",
			"jill",
			"hired_mage",
			"darkassasin3",
			"darkassasin2",
			"darkassasin1",
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
			"harshfred", 
			"turnhealer", 
			"bloodhaggler", 
			"grand_bloodhaggler", 
			"drawson2",
			"drawson1", 
			"drawttack",
			"traitor",
			"fateup", 
			"marco",
			"polo",
			"zig",
			"zag",
			"banana_a",
			"banana_b",
			"forsaken1",
			"forsaken2",
			"forsaken3",
			"forsaken4",
			"8ball_1", 
		    "8ball_2", 
		    "8ball_3", 
		    "8ball_4", 
			"joe1",
			"joe2",
			"joe3",
			"doe1",
			"doe2",
			"doe3",
			
			/**  DONE (TRAPS)  **/
			"sneakshot",
			
			/**  TO DO  **/
			"necropy0",
			"badpiercer",
			"shield8",
			"antigrando",
			"autoattacker",
			"gcontract_haste",
			"resurrecter3",
			"grandtraitor",
			"trapsaver",
			"ferocious_sara",
			"trapowered_3",
			"grandegrand",
			"drawrage",
			"lonely_golem",
			"black_hood",
			"piercing_george",
			"devouerer2",
			"dark_one",
			"cowardly_giant",
			"yin",
			"yang",
			"ed",
			"edd",
			"eddy",
			"cheerleader1",
			"cheerleader2",
			"cheerleader3",
			"cheerleader4",
			"flappy_rooster",
			"empower_0",
			"grandlock",
			"phase_through",
			
			/**  FROZEN  **/
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
				if ( card.propsC.isGrand ) 
					return ColorScheme.getColorForCreatureNeedsTribute( true );
				if ( card.propsC.isFlippable ) 
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