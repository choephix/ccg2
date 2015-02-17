package duel.cards
{
	import chimichanga.debug.logging.error;
	import duel.cards.Card;
	import duel.cards.properties.cardprops;
	import duel.cards.temp_database.TempDatabaseUtils;
	import duel.otherlogic.SpecialEffect;
	import duel.processes.GameplayProcess;
	import duel.processes.gameprocessgetter;
	import duel.table.CardLotType;
	import duel.table.CreatureField;
	import flash.utils.Dictionary;
	import global.CardPrimalData;
	
	use namespace cardprops;
	use namespace gameprocessgetter;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardFactory
	{
		static private var uid:uint = 0;
		static private var F:Dictionary = new Dictionary();
		static private var initialized:Boolean = false;
		
		//
		private static function initialize():void
		{
			/* * * /
			
			F[ "unnamed" ] = 
			function( c:Card ):void
			{
			}
			
			/* * */
			
			/// /// /// TEST SPACE /// /// ///
			
			F[ "reversepiercer" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( c.indexedField.opposingCreature.statusC.currentPowerValue
						>= c.statusC.currentPowerValue ) return false;
					
					if ( c == p.getAttacker() ) return true;
					if ( c.indexedField.opposingCreature == p.getAttacker() ) return true;
					return false;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller,
						c.statusC.currentPowerValue - 
						c.indexedField.opposingCreature.statusC.currentPowerValue,
						c );
				}
			}
			
			/// /// /// TEST SPACE /// /// ///
			
			F[ "fate_up" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDraw( p.getPlayer(), 1 );
				}
			}
			
			F[ "drawttack" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDraw( c.controller, 1 );
				}
			}
			
			F[ "saviour" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c == p.getSourceCard() ) return false;
					if ( c.controller != p.getSourceCard().controller ) return false;
					if ( !p.getDeathIsFromCombat() ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doKill( c );
				}
			}
			
			F[ "traitor" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller != p.getPlayer() ) return false;
					return c.indexedField.opposingCreature == null;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doForceRelocate( c, c.indexedField.opposingCreatureField, true );
				}
			}
			
			F[ "marco" ] = 
			F[ "polo" ] = 
			function( c:Card ):void
			{
				const IS_1:Boolean = c.slug == "marco";
				const BROTHER:String = IS_1 ? "polo" : "marco";
				
				var f:Function =
				function ():void {
					var cc:Card = c.controller.grave.findBySlug( BROTHER );
					if ( cc != null )
						TempDatabaseUtils.doPutInHand( cc, c.controller );
				}
				
				if ( IS_1 )
					c.propsC.onSafeFlipFunc = f;
				else
					c.propsC.onCombatFlipFunc = f;
			}
			
			F[ "zig" ] = 
			F[ "zag" ] = 
			function( c:Card ):void
			{
				const IS_1:Boolean = c.slug == "zig";
				const BROTHER:String = IS_1 ? "zag" : "zig";
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller != p.getPlayer() ) return false;
					if ( c.controller.grave.findBySlug( BROTHER ) == null ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var cc:Card = c.controller.grave.findBySlug( BROTHER );
					if ( cc != null )
						TempDatabaseUtils.doPutInHand( cc, c.controller );
				}
			}
			
			F[ "banana_a" ] =
			F[ "banana_b" ] = 
			function( c:Card ):void
			{
				const IS_1:Boolean = c.slug == "banana_a";
				const BROTHER:String = IS_1 ? "banana_b" : "banana_a";
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.HAND );
				special.watch( GameplayProcess.DRAW_CARD_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller.deck.findBySlug( BROTHER ) == null ) return false;
					return c == p.getDrawnCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var cc:Card = c.controller.deck.findBySlug( BROTHER );
					if ( cc != null )
						TempDatabaseUtils.doPutInHand( cc, c.controller );
				}
			}
			
			F[ "8ball_1" ] = 
			F[ "8ball_2" ] = 
			F[ "8ball_3" ] = 
			F[ "8ball_4" ] = 
			function( c:Card ):void
			{
				const GROUP:String = "8ball";
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c != p.getSourceCard() ) return false;
					if ( c.controller.deck.findBySlug( GROUP, false ) == null ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var cc:Card = c.controller.deck.findBySlug( GROUP, false );
					if ( cc != null )
						TempDatabaseUtils.doSummonFromDeck( 
							cc, c.history.lastIndexedField as CreatureField );
				}
			}
			
			// DEV
			F[ "___kami___" ] = 
			function( c:Card ):void
			{
				c.propsC.haste = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.actionsAttack = 0;
				}
			}
			
			/// /// /// // ///
			initialized = true;
			/// /// /// // ///
		}
		
		//
		
		//
		
		//
		
		//
		
		//
		public static function produceCard( data:* ):Card
		{
			if ( !initialized )
				initialize();
			uid++;
			
			var c:Card = new Card();
			var cpd:CardPrimalData;
			
			if ( data is CardPrimalData )
				cpd = data as CardPrimalData;
			else
			if ( data is int )
				cpd = App.cardsData.findByID( data as int ) ;
			else
			if ( data is String )
				cpd = App.cardsData.findBySlug( data as String );
			else
				error( "WTF is this data?" );
			
			if ( cpd == null )
				throw new Error( "No such CPD" );
			
			// PRIMAL
			c.primalData = cpd;
			if ( cpd.type == CardPrimalData.TYPE_TRAP )
				TempDatabaseUtils.setToTrap( c );
			else
			{
				TempDatabaseUtils.setToCreature( c );
				c.propsC.flippable = cpd.type == CardPrimalData.TYPE_CREATURE_FLIPPABLE;
				c.propsC.needTribute = cpd.type == CardPrimalData.TYPE_CREATURE_GRAND;
				c.propsC.basePower = cpd.power;
			}
			
			// ADVANCED
			var f:* = F[ cpd.slug ];
			if ( f is Function )
				f( c );
			
			CONFIG::development
			{
				if ( f == null && cpd.description.length > 0 )
					c.unimplemented = true;
			}
			
			//
			c.initialize();
			return c;
		}
		
		//
		private static function chance( value:Number ):Boolean { return Math.random() < value }
	}

}