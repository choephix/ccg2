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
		public static var DECK1:Array = [ "marco", "jerry", "broodelf2", "handy", "defmove_left", "shmester", "polo", "turnend", "berserker", "token_summoner4", "jack", "trappeek", "spike", "darkassasin3", "cripple", "flappy_rooster", "saviour", "jill", "sneakshot", "vendeto", "powerhealer2", "broodelf1", "surprise_attack", "emma", "paulgrand", "emptyshell", "broodelf3", "doe1", "ritual_t_f2", "swapper2", "broodelf4", "doublemana", "badfate", "last_stand", "vendeto_grand", "ritual_c_f2", ];
		
		public static var DECK2:Array = [ "zag", "cheerleader1", "empower", "cheerleader2", "drawson1", "equality", "cheerleader3", "zig", "cheerleader4", "mario", "manadrain", "confusor", "turnhealer", "tempower2", "them_damn_tokens", "grandegrand", "swap_right", "ed", "deathdraw", "unkillable_barny", "move_trap_hole", "edd", "evo_g_f2", "evo_a_f2", "antigrando", "hired_mage", "freefred", "drawhater", "ritual_t_f1", "man_of_honor", "deckstructor", "force_field", "final_heal", "doe2", "eddy", "ritual_c_f1", ];
		
		
		public static const DECK_TEST:Array = [
			
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
			//"paulgrand",
			//"paulgrand",
			//"devouerer2",
			//"resurrecter66", ///turn-end: Res your 1st GC
			//"resurrecter2", ///CF: Res enemy grv's top card
			//"resurrecter4", ///SF: Res your grv's top card
			//"compromiser1",
			//"motivator",
			//"deckstructor",
			//"deckstructor",
			//"trapowered",
			//"trapowered2",
			//"trapowered3",
			//"bloodhaggler2",
			
			//"eject",
			//"sneakshot",
			//"grandlock",
			
			/**  RE-TEST  **/
			//"devouerer",
			//"stunner"
			//"trapsaver2",
			//"trapsaver3",
			
			//"harrasser1",
			//"harrasser2",
			//"paul1",
			//"paul2",
			//"paul3",
			//"paulgrand",
			
			/**  TEST  **/
			
			/**  DONE (TRAPS)  **/
			
			///**
			"tokens_shield",
			"ritual_t_f1",
			"ritual_t_f2",
			"ritual_t_f3",
			"swap_ultimatum",
			"last_stand",
			"enemyhealer",
			"depowering_gas",  
			"depower",
			"empower",
			"mana_decktruction",
			"surprise_attack",
			"red_cross_reverse",
			"waste",
			"equality",
			"megatrap",
			"redirect_in",
			"redirect_out",
			"weird_swap",
			"eject",
			"manadrain",
			"enough",
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
			
			"good_defender",
			"good_offender",
			"mana_powered_bitch",
			"fatal_spirit",
			"unstable_mech",
			"antizero",
			"power_healer",
			"handy",
			"linked_bro1",
			"linked_bro2",
			"linked_bro3",
			"linked_bro4",
			"mana_thing",
			"ace1_lvl1",
			"ace1_lvl2",
			"ace1_lvl3",
			"problematic_sam",
			"angered",
			"angered2",
			"angered3",
			"dual_force_spirit",
			"ritual_c_f1",
			"ritual_c_f2",
			"ritual_c_f3",
			"piercing_george2",
			"antiflipper",
			"miller",
			"antisocial_archknight",
			"resque_zack",
			"social_fiend",
			"unkillable_barny",
			"mana_beast",
			"serious",
			"serious2",
			"grand__bloodrager",
			"traprage",
			"bloodhaggler2",
			"timereverser",
			"paulgrand2",
			"shy_warrior",
			"loneshield",
			"the_blood_king",
			"grand_dk",
			"quickfeet",
			"trapkiller0",
			"trapsaver",  
			"safebuffer",
			"stunbot",
			"tactical_joe",
			"token_summoner4",
			"hastegiver",
			"hastegiver2",
			"lategamer",
			"mario",
			"megasweeper",
			"fair_manaup",
			"bomb",
			"swap_right",
			"swap_left",
			"swapper",
			"swapper2",
			"swapper3",
			"autoattacker",
			"doomsday",
			"badpiercer",
			"specialo",
			"producer",
			"ferocious_sara",
			"antiflip_combat",
			"antiflip_safe",
			"trapkiller1",
			"trapkiller2",
			"trapkiller3",
			"antigrando",
			"cheerleader1",
			"cheerleader2",
			"cheerleader3",
			"cheerleader4",
			"token_pooper",
			"grower",
			"enraged",
			"copycat",
			"grand_copycat",
			"trapowered2",
			
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
			"trapowered3",
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
		
		public static function getColorForCard( card:Card ):uint 
		{
			if ( card.isCreature )
			{
				if ( card.props.isToken ) 
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