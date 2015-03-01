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
			
			//"spike", 
			//"grand_powerhealer", 
			//"emptyshell",
			//"emptyshell",
			//"emptyshell",
			//"tempower2",
			//"paulgrand",
			//"resurrecter66",
			//"resurrecter2",
			//"resurrecter4",
			//"compromiser1",
			//"motivator",
			//"deckstructor",
			//"deckstructor",
			
			//"sneakshot",
			//"grandlock",
			
			/**  RE-TEST  **/
			//"devouerer",
			//"stunner"
			
			/**  TEST  **/
			
			//"taunt",
			//"empower",
			//"mana_decktruction",
			//"last_stand",
			//"depower",
			//"trapsaver",
			
			//"cheerleader1",
			//"cheerleader2",
			//"cheerleader3",
			//"cheerleader4",
			//"badpiercer",
			//"antigrando",
			//"autoattacker",
			//"resurrecter3",
			//"ferocious_sara",
			//"bomb",
			//"blinding_rage",
			//"redo",
			//"token_summoner",
			//"bomb2",
			//"brainleech",
			//"copycat",
			//"trapreturner",
			//"trapkiller1",
			//"trapkiller2",
			//"trapkiller3",
			
			/**  DONE (TRAPS)  **/
			"move2atk",
			"scorch",
			"weakshield",
			"one_last_save",
			"trappeek",
			"them_damn_tokens",
			"empower1",
			"phase_through",
			"anti_flip1",
			"cripple",
			"dmgup",
			"deadly_nonsacrifice",
			"deadly_sacrifice",
			"deadly_sacrifice2",
			"column_cleanup",
			"trapsteal",
			"trapsteal2",
			"traptrap",
			"traptrap2",
			"fury",
			"move2ctrl",
			"turnend",
			"pow2lp",
			"defmove_right",
			"defmove_left",
			"move_trap_hole",
			"grandtraphole",
			"grandtraphole2",
			"atk2move1",
			"atk2move2",
			"final_heal",
			"grandlock",
			"summon2atk",
			"sneakshot",
			
			/**  DONE (CREATURES)  **/
			"evo_a_f1",
			"evo_a_f2",
			"evo_a_f3",
			"evo_g_f1",
			"evo_g_f2",
			"evo_g_f3",
			"trapkiller",
			"devouerer2",
			"devouerer",
			"necropy",
			"grandbro1",
			"grandbro2",
			"ed",
			"edd",
			"eddy",
			"cowardly_giant",
			"lonely_golem",
			"grandtraitor",
			"yin",
			"yang",
			"gcontract_haste",
			"token_summoner2",
			"balloonbrute",
			"piercing_george",
			"flappy_bird",
			"flappy_bird2",
			
			"trapsaver2",
			"berserker",
			"flappy_rooster",
			"vouerer",
			"time_lord",
			"for_a_lid",
			"shield8",
			"impatient_goeff",
			"divine_syphon",
			"blood_fiend",
			
			"nuke_virus",
			"trapowered",
			"evo_flip_a",
			"evo_flip_g",
			"provoked_nina",
			"shield1",
			"fateforward",
			"spying_james",
			"big_shield",
			"nightelf1",
			"nightelf2",
			"nightelf3",
			"nightelf4",
			"broodelf1",
			"broodelf2",
			"broodelf3",
			"broodelf4",
			"bloodmerc",
			"thieving_monkey",
			"mana_dispenser_2",
			"mana_drainer",
			"deckstructor",
			"badfate",
			"shield2",
			"jerry",
			"trappowered9",
			"crowdpowered",
			"socialgnome",
			"decksummoner",
			"younghealer",
			"forsaken1",
			"forsaken2",
			"forsaken3",
			"forsaken4",
			"flipmike",
			"mr_mirakul",
			"black_hood2",
			"black_hood",
			"dark_one",
			"shmester",
			"drawhater",
			"drawrager",
			"drawrager2",
			"grandegrand",
			"harrasser1",
			"harrasser2",
			"grandgrandpaul",
			"general",
			"paul2",
			"paul3",
			"force_field",
			"johnny1",
			"tempower2",
			"tempower",
			"paulgrand",
			"vendeto",
			"vendeto_grand",
			"spike",
			"force_field2",
			"emma",
			"specialhaste",
			"crippler",
			"general2",
			"all_out_joe",
			"paul1",
			"tranquility",
			"glassspike",
			"managiver",
			"actiontaker",
			"upgrade",
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
			"forbidden1",
			"forbidden2",
			"forbidden3",
			"forbidden4",
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
			
			/**  TO DO  **/
			
			/**  FROZEN  **/
			//"blinding_rage",
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