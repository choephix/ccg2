package duel.cards.factory
{
	import chimichanga.debug.logging.error;
	import chimichanga.global.app.Platform;
	import duel.cards.buffs.Buff;
	import duel.cards.buffs.GlobalBuff;
	import duel.cards.Card;
	import duel.cards.CardFAQ;
	import duel.cards.GameplayFAQ;
	import duel.cards.properties.cardprops;
	import duel.cards.temp_database.TempDatabaseUtils;
	import duel.DamageType;
	import duel.G;
	import duel.otherlogic.OngoingEffect;
	import duel.otherlogic.SpecialEffect;
	import duel.otherlogic.TrapEffect;
	import duel.players.Player;
	import duel.processes.GameplayProcess;
	import duel.processes.gameprocessgetter;
	import duel.table.CardLotType;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.fieldlists.CreatureFieldsRow;
	import duel.table.TrapField;
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
			//{ DEV
			
			F[ "___test___" ] = function( c:Card ):void
			{
				var special:SpecialEffect;
				
				/** SPECIAL 1 * BUFF UP + DMG* * /
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.propsC.basePower += 5;
					//if ( c.indexedField.opposingCreature )
						//TempDatabaseUtils.doPutInHand( 
							//c.indexedField.opposingCreature, 
							//c.indexedField.opposingCreature.controller );
				}
				/**/
				
				/** SPECIAL 2 * BUFF DRAW * * /
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DRAW_CARD_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.propsC.basePower += c.primalData.getVarInt( 0 );
					//TempDatabaseUtils.doDealDirectDamage( c.controller.opponent, 1, c );
				}
				/**/
				
				/** SPECIAL 3 * POOP TOKENS * */
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.controller.fieldsC.forEachField( TempDatabaseUtils.doSpawnTokenCreatureIfEmpty );
				}
				/**/
				
				/** SPECIAL 4 * UNDIE * */
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( c, c.controller );
				}
				/**/
			}
			
			F[ "___kami___" ] = function( c:Card ):void
			{
				c.cost = 0;
				c.propsC.hasSwap = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					if ( c.controller.grave.cardsCount > 0 )
						TempDatabaseUtils.doPutInHand( c.controller.grave.topCard, c.controller );
					if ( c.controller.creatureCount == 1 )
					{
						TempDatabaseUtils.doDiscardFromDeck( c.controller, 4 );
						TempDatabaseUtils.doDiscardFromDeck( c.controller.opponent, 4 );
					}
				}
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.TURN_START_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( c, c.controller );
				}
				
				var ongoing:OngoingEffect;
				ongoing = c.propsC.addOngoing();
				ongoing.funcUpdate =
				function( p:GameplayProcess ):void {
					c.propsC.basePower = c.controller.mana.current * c.controller.mana.current;
					c.statusC.actionsAttack = 0;
					c.statusC.actionsRelocate = 0;
					c.statusC.hasSummonExhaustion = false;
				}
			}
			
			F[ "_______" ] = 
			function( c:Card ):void
			{
				
			}
			
			/* * * /
			F[ "time_lord" ] = 
			function( c:Card ):void
			{
				const HANDCARDS:int = c.primalData.getVarInt( 0 );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ENTER_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					if ( c.controller.hand.cardsCount < HANDCARDS )
						TempDatabaseUtils.doDraw( c.controller, HANDCARDS - c.controller.hand.cardsCount );
					if ( c.controller.opponent.hand.cardsCount < HANDCARDS )
						TempDatabaseUtils.doDraw( c.controller, HANDCARDS - c.controller.opponent.hand.cardsCount );
				}
			}
			/* * */
			
			//}
			
			/// /// /// /// // /// /// /// ///
			/// /// /// TEST SPACE /// /// ///
			/// /// ///            /// /// ///
			
			//{ IN TESTING
			
			//}
			
			//{ ON HOLD
			
			F[ "taunting_dance" ] = // // PERMANENT
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.TURN_START );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					return c.controller.opponent == p.getPlayer();
				}
				
				c.propsT.effect.watcherTriggered.watchFor( GameplayProcess.TURN_END );
				c.propsT.effect.watcherTriggered.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					return c.controller.opponent == p.getPlayer();
				}
				c.propsT.effect.watcherTriggered.funcEffect = 
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller.opponent, 
						c.indexedField.opposingCreature.statusC.realPowerValue, c );
				}
				
				c.propsT.effect.watcherDeactivate.watchFor( GameplayProcess.TURN_END );
				c.propsT.effect.watcherDeactivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
			}
			
			F[ "taunt" ] = // // PERMANENT
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.TURN_START );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					return c.controller.opponent == p.getPlayer();
				}
				
				c.propsT.effect.watcherTriggered.watchFor( GameplayProcess.TURN_END );
				c.propsT.effect.watcherTriggered.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					return c.controller.opponent == p.getPlayer();
				}
				c.propsT.effect.watcherTriggered.funcEffect = 
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doForceAttack( c.indexedField.opposingCreature, true );
				}
				
				c.propsT.effect.watcherDeactivate.watchFor( GameplayProcess.TURN_END );
				c.propsT.effect.watcherDeactivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
			}
			
			//
			
			F[ "trapsaver2" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.LEAVE_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !p.getSourceCard().isTrap ) return false;
					if ( c.controller == p.getSourceCard().controller ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doSetTrap( p.getSourceCard(), p.getSourceCard().history.lastIndexedField as TrapField );
				}
			}
			
			F[ "trapsaver3" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.LEAVE_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !p.getSourceCard().isTrap ) return false;
					if ( c.controller == p.getSourceCard().controller ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doSetTrap( p.getSourceCard(), p.getSourceCard().history.lastIndexedField as TrapField );
				}
			}
			
			//F[ "redo" ] = 
			//function( c:Card ):void
			//{
				//c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				//c.propsT.effect.watcherActivate.funcCondition =
				//function( p:GameplayProcess ):Boolean
				//{
					//if ( c.controller.grave.topCard == null ) return false;
					//if ( !c.controller.grave.topCard.isTrap ) return false;
					//return c.controller.grave.topCard.propsT.effect.funcActivateCondition( p );
				//}
				//c.propsT.effect.watcherActivate.funcEffect =
				//function( p:GameplayProcess ):void
				//{
					//if ( c.controller.grave.topCard == null ) return;
					//if ( !c.controller.grave.topCard.isTrap ) return;
					//c.controller.grave.topCard.propsT.effect.funcActivate( p );
				//}
			//}
			
			//F[ "taunt" ] = 
			//function( c:Card ):void
			//{
				//
			//}
			//
			//F[ "mana_decktruction" ] = 
			//function( c:Card ):void
			//{
				//
			//}
			//
			//F[ "last_stand" ] = 
			//function( c:Card ):void
			//{
				//
			//}
			//
			//F[ "empower" ] = 
			//function( c:Card ):void
			//{
				//
			//}
			//
			//F[ "depower" ] = 
			//function( c:Card ):void
			//{
				//
			//}
			
			//}
			
			/// /// ///            /// /// ///
			/// /// /// TEST SPACE /// /// ///
			/// /// /// /// // /// /// /// ///
			
			//{ TRAP
			
			F[ "tokens_shield" ] =
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchForAny();
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent.isMyTurn && c.controller.creatureCount == 0;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					c.controller.fieldsC.forEachField( TempDatabaseUtils.doSpawnTokenCreatureIfEmpty );
				}
			}
			
			F[ "ritual_t_f1" ] =
			function( c:Card ):void
			{
				const SUMMONEE:String = c.primalData.getVarSlug( 0 );
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.DIE_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					//if ( p.getSourceCard().propsC.isGrand ) return false;
					return c.indexedField.samesideCreatureField == p.getSourceCard().history.lastIndexedField;
				}
				c.propsT.effect.watcherActivate.funcEffect = 
				function( p:GameplayProcess ):void {
					var cc:Card;
					cc = c.controller.hand.findBySlug( SUMMONEE );
					//if ( cc == null ) cc = c.controller.deck.findBySlug( SUMMONEE );
					if ( cc == null ) return;
					TempDatabaseUtils.doSummonFromDeckOrHand( cc, c.indexedField.samesideCreatureField );
					cc.statusC.addNewBuff( true ).powerOffset = 2 * p.getSourceCard().statusC.basePowerValue;
				}
			}
			
			F[ "ritual_t_f2" ] =
			function( c:Card ):void
			{
				const SUMMONEE:String = c.primalData.getVarSlug( 0 );
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getAttacker();
				}
				c.propsT.effect.watcherActivate.funcEffect = 
				function( p:GameplayProcess ):void {
					var cc:Card;
					cc = c.controller.hand.findBySlug( SUMMONEE );
					//if ( cc == null ) cc = c.controller.deck.findBySlug( SUMMONEE );
					if ( cc == null ) return;
					TempDatabaseUtils.doSummonFromDeckOrHand( cc, c.indexedField.samesideCreatureField );
					
					if ( c.indexedField.samesideCreature != null )
					{
						TempDatabaseUtils.doKill( c.indexedField.samesideCreature, c );
						cc.statusC.addNewBuff( true ).powerOffset = c.indexedField.samesideCreature.statusC.realPowerValue;
					}
				}
			}
			
			F[ "ritual_t_f3" ] =
			function( c:Card ):void
			{
				const SUMMONEE:String = c.primalData.getVarSlug( 0 );
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.samesideCreature == null && c.indexedField.opposingCreature == p.getAttacker();
				}
				c.propsT.effect.watcherActivate.funcEffect = 
				function( p:GameplayProcess ):void {
					var cc:Card;
					cc = c.controller.hand.findBySlug( SUMMONEE );
					//if ( cc == null ) cc = c.controller.deck.findBySlug( SUMMONEE );
					if ( cc == null ) return;
					TempDatabaseUtils.doSummonFromDeckOrHand( cc, c.indexedField.samesideCreatureField );
				}
			}
			
			F[ "swap_ultimatum" ] =
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.TURN_START );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( c.indexedField.samesideCreature == null ) return false;
					return c.controller.opponent == p.getPlayer();
				}
				
				c.propsT.effect.watcherTriggered.watchFor( GameplayProcess.TURN_END );
				c.propsT.effect.watcherTriggered.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.samesideCreature == null ) return false;
					return c.controller.opponent == p.getPlayer();
				}
				c.propsT.effect.watcherTriggered.funcEffect = 
				function( p:GameplayProcess ):void {
					if ( c.indexedField.opposingCreature == null )
						TempDatabaseUtils.doKill( c.indexedField.samesideCreature, c );
					else
						TempDatabaseUtils.doForceSwap( c.indexedField.samesideCreature,
							c.indexedField.opposingCreatureField, true );
				}
				
				c.propsT.effect.watcherDeactivate.watchFor( GameplayProcess.TURN_END );
				c.propsT.effect.watcherDeactivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
			}
			
			F[ "enemyhealer" ] = // // PERMANENT
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.DIRECT_DAMAGE );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				
				c.propsT.effect.watcherTriggered.watchFor( GameplayProcess.DIRECT_DAMAGE );
				c.propsT.effect.watcherTriggered.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				c.propsT.effect.watcherTriggered.funcEffect = 
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doHeal( c.controller.opponent, p.getDamage().amount );
				}
				
				c.propsT.effect.watcherDeactivate.watchFor( GameplayProcess.TURN_END );
				c.propsT.effect.watcherDeactivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
			}
			
			F[ "last_stand" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.samesideCreature != null ) return false;
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( c.indexedField.opposingCreature.statusC.realPowerValue < c.controller.lifePoints ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect = 
				function( p:GameplayProcess ):void {
					doPlayer( c.controller );
					doPlayer( c.controller.opponent );
				}
				function doPlayer( pp:Player ):void {
					var i:int = 0;
					var cc:Card;
					var ff:CreatureField;
					var aa:Array = [];
					for ( i = 0; i < G.FIELD_COLUMNS; i++ ) 
					{
						ff = pp.fieldsC.getAt( i );
						if ( !ff.isEmpty ) continue;
						cc = pp.grave.findFirstCard( isUsable );
						if ( cc == null ) continue;
						TempDatabaseUtils.doResurrectCreature( cc, ff, c );
						aa.push( cc );
					}
					function isUsable( ccc:Card ):Boolean
					{ return ccc.isCreature && ccc.statusC.canBeSummonedOn( ff, false ) && aa.indexOf( ccc ) < 0 }
				}
			}
			
			F[ "depowering_gas" ] = // // PERMANENT
			function( c:Card ):void
			{
				var target:Card;
				
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getAttacker();
				}
				
				c.propsT.effect.watcherTriggered.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherTriggered.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getAttacker();
				}
				c.propsT.effect.watcherTriggered.funcEffect = 
				function( p:GameplayProcess ):void {
					target = c.indexedField.opposingCreature;
					var b:Buff = target.statusC.addNewBuff( true )
					b.powerOffset = -c.primalData.getVarInt( 0 );
				}
				
				c.propsT.effect.watcherDeactivate.watchFor( GameplayProcess.LEAVE_INDEXED_FIELD_COMPLETE );
				c.propsT.effect.watcherDeactivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return target == p.getSourceCard();
				}
				c.propsT.effect.watcherDeactivate.funcEffect = 
				function( p:GameplayProcess ):void {
					target = null;
				}
			}
			
			F[ "depower" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.samesideCreature == null ) return false;
					return c.indexedField.opposingCreature == p.getAttacker();
				}
				c.propsT.effect.watcherActivate.funcEffect = 
				function( p:GameplayProcess ):void {
					var b:Buff = c.indexedField.opposingCreature.statusC.addNewBuff( true );
					b.powerOffset = -c.primalData.getVarInt( 0 );
					b.expiryCondition = expireBuff;
				}
				function expireBuff( p:GameplayProcess ):Boolean {
					return p.name == GameplayProcess.TURN_END;
				}
			}
			
			F[ "empower" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.samesideCreature == null ) return false;
					return c.indexedField.opposingCreature == p.getAttacker();
				}
				c.propsT.effect.watcherActivate.funcEffect = 
				function( p:GameplayProcess ):void {
					var b:Buff = c.indexedField.samesideCreature.statusC.addNewBuff( true );
					b.powerOffset = c.primalData.getVarInt( 0 );
					b.expiryCondition = expireBuff;
				}
				function expireBuff( p:GameplayProcess ):Boolean {
					return p.name == GameplayProcess.TURN_END;
				}
			}
			
			F[ "mana_decktruction" ] = // // PERMANENT
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.TURN_START );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
				
				c.propsT.effect.watcherTriggered.watchFor( GameplayProcess.SPEND_MANA_COMPLETE );
				c.propsT.effect.watcherTriggered.funcEffect = 
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDiscardFromDeck( p.getPlayer(), c.primalData.getVarInt( 0 ) );
				}
				
				c.propsT.effect.watcherDeactivate.watchFor( GameplayProcess.TURN_END );
				c.propsT.effect.watcherDeactivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
			}
			
			F[ "surprise_attack" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.SUMMON_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.samesideCreature == null ) return false;
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect = 
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doForceAttack( c.indexedField.samesideCreature, true );
				}
			}
			
			F[ "red_cross_reverse" ] = // // PERMANENT
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.DIRECT_DAMAGE );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					if ( !c.controller.opponent.isMyTurn ) return false;
					return c.controller == p.getPlayer();
				}
				
				c.propsT.effect.watcherTriggered.watchFor( GameplayProcess.DIRECT_DAMAGE );
				c.propsT.effect.watcherTriggered.funcEffect = 
				function( p:GameplayProcess ):void {
					p.getDamage().type = DamageType.HEALING;
				}
				
				c.propsT.effect.watcherDeactivate.watchFor( GameplayProcess.TURN_END );
				c.propsT.effect.watcherDeactivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
			}
			
			F[ "waste" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.SUMMON_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect = 
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( p.getSourceCard(), p.getSourceCard().controller );
				}
			}
			
			F[ "equality" ] = // // PERMANENT
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.TURN_START );
				c.propsT.effect.watcherActivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
				
				c.propsT.effect.watcherTriggered.watchFor( GameplayProcess.DRAW_CARD_COMPLETE );
				c.propsT.effect.watcherTriggered.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
				c.propsT.effect.watcherTriggered.funcEffect = 
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDraw( c.controller, 1 );
				}
				
				c.propsT.effect.watcherDeactivate.watchFor( GameplayProcess.TURN_END );
				c.propsT.effect.watcherDeactivate.funcCondition = 
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
			}
			
			F[ "megatrap" ] = 
			function( c:Card ):void
			{
				const PWR:int = c.primalData.getVarInt( 0 );
				c.propsT.effect.watcherActivate.watchForAny();
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( c.controller.isMyTurn ) return false;
					return c.indexedField.opposingCreature.statusC.realPowerValue > PWR;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( c.indexedField.opposingCreature, c );
				}
			}
			
			F[ "redirect_in" ] = 
			function( c:Card ):void
			{
				const SPOUSE:String = c.primalData.getVarSlug( 0 );
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.DIRECT_DAMAGE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.samesideCreature != null ) return false;
					if ( p.getDamage().type != DamageType.COMBAT ) return false;
					if ( p.getDamage().source != c.indexedField.opposingCreature ) return false;
					if ( !c.controller.fieldsT.hasAnyFieldThat( check ) ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.abort();
				}
				function check( field:TrapField ):Boolean {
					return field.topCard && field.topCard.slug == SPOUSE;
				}
			}
			
			F[ "redirect_out" ] = 
			function( c:Card ):void
			{
				const SPOUSE:String = c.primalData.getVarSlug( 0 );
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ACTIVATE_TRAP_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller != p.getSourceCard().controller ) return false;
					return SPOUSE == p.getSourceCard().slug;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller.opponent, 
						p.getSourceCard().indexedField.opposingCreature.statusC.realPowerValue, c );
				}
			}
			
			F[ "weird_swap" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.SUMMON_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getSourceCard() ) return false;
					if ( c.indexedField.samesideCreature == null ) return false;
					if ( c.indexedField.samesideCreature.statusC.realPowerValue < p.getSourceCard().statusC.realPowerValue ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doForceSwap( p.getSourceCard(), c.indexedField.samesideCreatureField, true );
				}
			}
			
			F[ "eject" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ENTER_INDEXED_FIELD_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( p.getSourceCard(), p.getSourceCard().owner );
				}
			}
			
			F[ "antiflip_combat" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.COMBAT_FLIP_EFFECT );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.abort()
				}
			}
			
			F[ "antiflip_safe" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.SAFE_FLIP_EFFECT );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.abort()
				}
			}
			
			F[ "manadrain" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.SUMMON_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !p.isSummonManual() ) return false;
					if ( c.indexedField.opposingCreature != p.getSourceCard() ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					const PLR:Player = p.getSourceCard().controller;
					TempDatabaseUtils.doOffsetMana( PLR, -PLR.mana.current );
				}
			}
			
			F[ "enough" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.SUMMON_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !p.isSummonManual() ) return false;
					if ( c.indexedField.samesideCreature != null ) return false;
					if ( c.indexedField.opposingCreature != p.getSourceCard() ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doEndTurn( c.controller.opponent );
				}
			}
			
			F[ "move2atk" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.RELOCATE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doForceAttack( p.getSourceCard(), true );
				}
			}
			
			F[ "scorch" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.DIE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.samesideCreature == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					const PWR:int = p.getSourceCard().statusC.realPowerValue + 1;
					TempDatabaseUtils.doBurnCreaturesRow( PWR, c.controller, c, p.getSourceCard() );
					TempDatabaseUtils.doBurnCreaturesRow( PWR, c.controller.opponent, c, p.getSourceCard() );
				}
			}
			
			F[ "weakshield" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( c.indexedField.samesideCreature != null ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					var buff:Buff = p.getAttacker().statusC.addNewBuff( true )
					buff.powerOffset = -c.primalData.getVarInt( 0 );
					buff.expiryCondition = 
					function( p:GameplayProcess ):Boolean {
						return p.name == GameplayProcess.TURN_END;
					}
				}
			}
			
			F[ "one_last_save" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.DIRECT_DAMAGE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller != p.getPlayer() ) return false;
					if ( c.controller.lifePoints > p.getDamage().amount ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.getDamage().amount = 0;
					TempDatabaseUtils.doDraw( c.controller, 1 );
				}
			}
			
			F[ "trappeek" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.SET_TRAP_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getSourceCard().controller;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPeekAt( p.getSourceCard() );
				}
			}
			
			F[ "them_damn_tokens" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !c.indexedField.samesideCreatureField.isEmpty ) return false;
					return p.getSourceCard() == c.indexedField.opposingCreature;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					c.controller.fieldsC.forEachField( TempDatabaseUtils.doSpawnTokenCreatureIfEmpty );
					c.controller.opponent.fieldsC.forEachField( TempDatabaseUtils.doSpawnTokenCreatureIfEmpty );
				}
			}
			
			F[ "empower1" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( c.indexedField.samesideCreature == null ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					if ( c.indexedField.samesideCreature == null ) return;
					c.indexedField.samesideCreature.statusC.addNewBuff( true ).powerOffset
						= c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "phase_through" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( c.indexedField.samesideCreature == null ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doDealDirectDamage( c.controller, p.getAttacker().statusC.realPowerValue, c );
				}
			}
			
			F[ "anti_flip1" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.SUMMON_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return p.getSourceCard() == c.indexedField.opposingCreature && c.indexedField.opposingCreature.faceDown;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doSilentFlip( c.indexedField.opposingCreature );
				}
			}
			
			F[ "cripple" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getAttacker();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					if ( c.indexedField.opposingCreature == null ) return;
					c.indexedField.opposingCreature.statusC.addNewBuff( true ).powerOffset
						= -c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "dmgup" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.DIRECT_DAMAGE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !c.controller.opponent.isMyTurn ) return false;
					return c.controller.opponent == p.getPlayer();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.getDamage().amount += c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "deadly_nonsacrifice" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( c.indexedField.samesideCreature == null ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					if ( c.indexedField.opposingCreature == null ) return;
					if ( c.indexedField.samesideCreature == null ) return;
					const DMG:int = c.indexedField.opposingCreature.statusC.realPowerValue
								  + c.indexedField.samesideCreature.statusC.realPowerValue;
					TempDatabaseUtils.doDealDirectDamage( c.controller, DMG, c );
					TempDatabaseUtils.doKill( c.indexedField.opposingCreature, c );
				}
			}
			
			F[ "deadly_sacrifice" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( c.indexedField.samesideCreature == null ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller, 
						c.indexedField.opposingCreature.statusC.realPowerValue, c );
					if ( c.indexedField.opposingCreature == null ) return;
					TempDatabaseUtils.doKill( c.indexedField.opposingCreature, c );
					if ( c.indexedField.samesideCreature == null ) return;
					TempDatabaseUtils.doKill( c.indexedField.samesideCreature, c );
				}
			}
			
			F[ "deadly_sacrifice2" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( c.indexedField.samesideCreature == null ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					if ( c.indexedField.samesideCreature == null ) return;
					if ( c.indexedField.opposingCreature == null ) return;
					TempDatabaseUtils.doKill( c.indexedField.samesideCreature, c );
					TempDatabaseUtils.doPutInHand( c.indexedField.opposingCreature,
											c.indexedField.opposingCreature.controller);
				}
			}
			
			F[ "column_cleanup" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ACTIVATE_TRAP );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingTrap == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.abort();
					if ( c.indexedField.opposingTrap )
						TempDatabaseUtils.doDestroyTrap( c.indexedField.opposingTrap, c );
					if ( c.indexedField.opposingCreature )
						TempDatabaseUtils.doKill( c.indexedField.opposingCreature, c );
					if ( c.indexedField.samesideCreature )
						TempDatabaseUtils.doKill( c.indexedField.samesideCreature, c );
					if ( c.indexedField.samesideTrap )
						TempDatabaseUtils.doDestroyTrap( c.indexedField.samesideTrap, c );
				}
			}
			
			F[ "trapsteal" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.LEAVE_PLAY );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingTrap == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doPutInHand( p.getSourceCard(), c.controller );
				}
			}
			
			F[ "trapsteal2" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ACTIVATE_TRAP );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.samesideCreature == null ) return false;
					return c.indexedField.opposingTrap == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					if ( c.indexedField.samesideCreature == null ) return;
					p.abort();
					TempDatabaseUtils.doPutInHand( p.getSourceCard(), c.controller );
					TempDatabaseUtils.doKill( c.indexedField.samesideCreature, c );
				}
			}
			
			F[ "traptrap" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ACTIVATE_TRAP );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingTrap == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.abort();
				}
			}
			
			F[ "traptrap2" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ACTIVATE_TRAP );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.samesideCreature == null ) return false;
					return c.controller.opponent == p.getSourceCard().controller;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doKill( c.indexedField.samesideCreature, c );
				}
			}
			
			F[ "fury" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.DIRECT_DAMAGE_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( p.getDamage().source as Card == null ) return false;
					if ( c.indexedField.opposingCreature == null ) return false;
					return c.indexedField.opposingCreature == p.getDamage().source as Card;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					var dmg:int = p.getDamage().amount;
					var cc:Card;
					for ( var i:int = 0; i < c.controller.opponent.fieldsC.count; i++ ) 
					{
						cc = c.controller.opponent.fieldsC.getAt( i ).topCard;
						if ( cc == null ) continue;
						if ( cc == c ) continue;
						if ( cc.faceDown ) continue;
						if ( cc.statusC.realPowerValue >= dmg ) continue;
						TempDatabaseUtils.doKill( cc, c );
					}
				}
			}
			
			F[ "move2ctrl" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.RELOCATE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !c.controller.opponent.isMyTurn ) return false;
					if ( c.indexedField.samesideCreature == null ) return false;
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.abort();
					if ( c.indexedField.samesideCreature == null ) return;
					TempDatabaseUtils.doForceRelocate( p.getSourceCard(), c.indexedField.samesideCreatureField, true );
					TempDatabaseUtils.doKill( c.indexedField.samesideCreature, c );
				}
			}
			
			F[ "turnend" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !c.controller.opponent.isMyTurn ) return false;
					return c.indexedField.opposingCreature == p.getAttacker();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doEndTurn( c.controller.opponent );
				}
			}
			
			F[ "pow2lp" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.DIE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !p.getDeathIsFromCombat() ) return false;
					return c.indexedField.samesideCreature == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doHeal( c.controller, p.getSourceCard().statusC.realPowerValue );
				}
			}
			
			F[ "defmove_left" ] = 
			F[ "defmove_right" ] = 
			function( c:Card ):void
			{
				const FDELTA:int = c.primalData.getVarInt( 0 );
				
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !c.indexedField.samesideCreatureField.isEmpty ) return false;
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( findTarget() == null ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doForceRelocate( findTarget(), c.indexedField.samesideCreatureField, true );
				}
				function findTarget():Card {
					return c.controller.samesideCreatureAtIndex( c.indexedField.index + FDELTA );
				}
			}
			
			F[ "move_trap_hole" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.RELOCATE_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller.opponent != p.getSourceCard().controller ) return false;
					if ( c.indexedField.opposingCreatureField != p.getRelocationDestination() ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( p.getSourceCard(), c );
				}
			}
			
			F[ "grandtraphole" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.SUMMON_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getSourceCard() ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					if ( c.indexedField.opposingCreature.propsC.isGrand )
						TempDatabaseUtils.doKill( c.indexedField.opposingCreature, c );
					else
						TempDatabaseUtils.doDealDirectDamage( c.controller, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "grandtraphole2" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.SUMMON_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getSourceCard() ) return false;
					if ( c.indexedField.samesideCreatureField.isEmpty ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					if ( c.indexedField.opposingCreature.propsC.isGrand )
						TempDatabaseUtils.doKill( c.indexedField.opposingCreature, c );
					else
						TempDatabaseUtils.doKill( c.indexedField.samesideCreature, c );
				}
			}
			
			F[ "atk2move1" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != null ) return false;
					if ( c.controller.opponent != p.getAttacker().controller ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doForceRelocate( p.getAttacker(), c.indexedField.opposingCreatureField, true );
				}
			}
			
			F[ "atk2move2" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != null ) return false;
					if ( c.controller.opponent != p.getAttacker().controller ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.abort();
					p.getAttacker().statusC.actionsAttack--;
					TempDatabaseUtils.doForceAttack( p.getAttacker(), false );
					TempDatabaseUtils.doForceRelocate( p.getAttacker(), c.indexedField.opposingCreatureField, true );
				}
			}
			
			F[ "final_heal" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.DIRECT_DAMAGE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller != p.getPlayer() ) return false;
					if ( c.controller.lifePoints > p.getDamage().amount ) return false;
					if ( p.getDamage().type != DamageType.COMBAT ) return false;
					if ( p.getDamage().source != c.indexedField.opposingCreature ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					p.getDamage().type = DamageType.HEALING;
					//TempDatabaseUtils.doHeal( c.controller, p.getDamage().amount );
					//p.getDamage().amount = 0;
				}
			}
			
			F[ "grandlock" ] = // // PERMANENT
			function( c:Card ):void
			{
				var _lockedField:CreatureField;
				
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.TRIBUTE_CREATURE_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !p.isTributeForGrand() ) return false;
					return c.indexedField.index == p.getSourceCard().history.lastIndexedField.index;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					_lockedField = p.getSourceCard().history.lastIndexedField as CreatureField;
					_lockedField.addLock();
				}
				
				c.propsT.effect.watcherDeactivate.watchFor( GameplayProcess.TURN_END );
				c.propsT.effect.watcherDeactivate.funcEffect =
				function( p:GameplayProcess ):void {
					_lockedField.removeLock();
					_lockedField = null;
				}
			}
			
			F[ "summon2atk" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.SUMMON_COMPLETE );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					var TARGET:Card = p.getSourceCard();
					TARGET.statusC.hasSummonExhaustion = false;
					if ( TARGET.statusC.canAttack )
						TempDatabaseUtils.doForceAttack( TARGET, false );
				}
			}
			
			F[ "sneakshot" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watcherActivate.watchFor( GameplayProcess.ATTACK );
				c.propsT.effect.watcherActivate.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( c.indexedField.samesideCreature != null ) return false;
					return true;
				}
				c.propsT.effect.watcherActivate.funcEffect =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller.opponent, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			//}
			
			//{ CREATURES
			
			F[ "good_offender" ] =
			function( c:Card ):void
			{
				var buff:Buff = new Buff( true );
				buff.powerOffset = c.primalData.getVarInt( 0 );
				
				var special:SpecialEffect;
				
				// ADD BUFF ON ATTACK START
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker() && !c.statusC.hasBuff( buff );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addBuff( buff );
				}
				
				// REMOVE BUFF ON ATTACK FINISH
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker() && c.statusC.hasBuff( buff );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.removeBuff( buff );
				}
			}
			
			F[ "good_defender" ] =
			function( c:Card ):void
			{
				var buff:Buff = new Buff( true );
				buff.powerOffset = c.primalData.getVarInt( 0 );
				
				var special:SpecialEffect;
				
				// ADD BUFF ON ATTACK START
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getAttacker() && !c.statusC.hasBuff( buff );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addBuff( buff );
				}
				
				// REMOVE BUFF ON ATTACK FINISH
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.statusC.hasBuff( buff );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.removeBuff( buff );
				}
			}
			
			F[ "mana_powered_bitch" ] =
			function( c:Card ):void
			{
				var buff:Buff = new Buff( true );
				buff.powerOffset =
				function( cc:Card ):int {
					return c.controller.mana.current;
				}
				
				var special:SpecialEffect;
				
				// ADD BUFF ON ATTACK START
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker() && !c.statusC.hasBuff( buff );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addBuff( buff );
				}
				
				// REMOVE BUFF ON ATTACK FINISH
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker() && c.statusC.hasBuff( buff );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.removeBuff( buff );
				}
			}
			
			F[ "fatal_spirit" ] =
			function( c:Card ):void
			{
				c.statusC.addNewBuff( false ).cannotRelocate = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard() && p.getDeathIsFromCombat();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( p.getDeathCauser(), c );
				}
			}
			
			F[ "unstable_mech" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( c, c );
					TempDatabaseUtils.doKill( c.indexedField.opposingCreature, c );
				}
			}
			
			F[ "antizero" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					burnLine( c.controller );
					burnLine( c.controller.opponent );
				}
				function burnLine( pp:Player ):void {
					var i:int;
					var cc:Card;
					for ( i = 0; i < pp.fieldsC.count; i++ ) 
					{
						cc = pp.fieldsC.getAt( i ).topCard;
						if ( cc == null ) continue;
						if ( cc == c ) continue;
						if ( cc.faceDown ) continue;
						if ( cc.statusC.realPowerValue > 0 ) continue;
						TempDatabaseUtils.doKill( cc, c );
					}
				}
			}
			
			F[ "power_healer" ] =
			function( c:Card ):void
			{
				c.statusC.addNewBuff( false ).cannotRelocate = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doHeal( c.controller, p.getAttacker().statusC.realPowerValue );
				}
			}
			
			F[ "handy" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDraw( c.controller.opponent, c.primalData.getVarInt( 1 ) );
					TempDatabaseUtils.doDraw( c.controller, c.primalData.getVarInt( 0 ) );
				}
			}
			
			F[ "linked_bro1" ] =
			F[ "linked_bro2" ] =
			F[ "linked_bro3" ] =
			F[ "linked_bro4" ] =
			function( c:Card ):void
			{
				const BRO:String = c.primalData.getVarString( 0 );
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller != p.getPlayer() ) return false;
					if ( c.controller.fieldsC.countCreaturesThat( checkBro ) > 2 ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( c, c );
				}
				function checkBro( c:Card ):Boolean {
					return c.slug.indexOf( BRO ) > -1;
				}
			}
			
			F[ "ace1_lvl2" ] =
			function( c:Card ):void
			{
				const BROTHER:String = c.primalData.getVarSlug( 0 );
				c.propsC.summonConditionManual = 
				function( field:CreatureField ):Boolean {
					return !field.isEmpty && field.topCard.slug == BROTHER;
				}
				c.propsC.summonConditionAutomatic = 
				function( field:CreatureField ):Boolean {
					return false;
				}
			}
			
			F[ "ace1_lvl3" ] =
			function( c:Card ):void
			{
				const BROTHER:String = c.primalData.getVarSlug( 0 );
				c.propsC.summonConditionManual = 
				function( field:CreatureField ):Boolean {
					return !field.isEmpty && field.topCard.slug == BROTHER;
				}
				c.propsC.summonConditionAutomatic = 
				function( field:CreatureField ):Boolean {
					return false;
				}
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard() && !p.getDeathIsFromCombat();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
				}
			}
			
			F[ "problematic_sam" ] =
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				c.propsC.summonConditionAutomatic = 
				function( field:CreatureField ):Boolean {
					return field.opposingCreatureField.isEmpty;
				}
			}
			
			F[ "angered" ] =
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.isActive = 
				function( c:Card ):Boolean {
					return c.isInPlay 
						&& !c.indexedField.opposingCreatureField.isEmpty;
				}
				buff.powerOffset = c.primalData.getVarInt( 0 );
			}
			
			F[ "angered2" ] =
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.isActive = 
				function( c:Card ):Boolean {
					return c.isInPlay 
						&& !c.indexedField.opposingCreatureField.isEmpty 
						&& c.indexedField.opposingCreature.faceDown;
				}
				buff.powerOffset = c.primalData.getVarInt( 0 );
			}
			
			F[ "angered3" ] =
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.isActive = 
				function( c:Card ):Boolean {
					return c.isInPlay
						&& c.controller.creatureCount < c.controller.opponent.creatureCount;
				}
				buff.powerOffset = c.primalData.getVarInt( 0 );
			}
			
			F[ "dual_force_spirit" ] =
			function( c:Card ):void
			{
				c.statusC.addNewBuff( false ).powerOffset =
				function( cc:Card ):int {
					var r:int = 0;
					if ( cc.isInPlay )
					{
						if ( !c.indexedField.samesideCreatureFieldToTheLeft.isEmpty )
							r += c.indexedField.samesideCreatureToTheLeft.statusC.basePowerValue;
						if ( !c.indexedField.samesideCreatureFieldToTheRight.isEmpty )
							r += c.indexedField.samesideCreatureToTheRight.statusC.basePowerValue;
					}
					return r;
				}
			}
			
			F[ "ritual_c_f1" ] =
			F[ "ritual_c_f2" ] =
			F[ "ritual_c_f3" ] =
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				function( field:CreatureField ):Boolean {
					return false;
				}
			}
			
			F[ "piercing_george2" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( c.indexedField.opposingCreature.statusC.realPowerValue
						>= c.statusC.realPowerValue ) return false;
					return isInvolvedInBattle( c, p );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					const DMG:int = c.statusC.realPowerValue - c.indexedField.opposingCreature.statusC.realPowerValue;
					TempDatabaseUtils.doDealDirectDamage( c.controller.opponent, DMG, c );
				}
			}
			
			F[ "antiflipper" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.PRE_ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( !c.indexedField.opposingCreature.faceDown ) return false;
					return c == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doSilentFlip( c.indexedField.opposingCreature );
				}
			}
			
			F[ "miller" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller.opponent, c.controller.opponent.creatureCount, c );
					c.statusC.addNewBuff( true ).powerOffset = -c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "antisocial_archknight" ] =
			function( c:Card ):void
			{
				c.statusC.addNewBuff( false ).powerOffset =
				function( cc:Card ):int {
					var r:int;
					for ( var i:int = 0; i < G.FIELD_COLUMNS; i++ ) 
						if ( c.controller.fieldsC.getAt( i ).topCard )
							if ( c.controller.fieldsC.getAt( i ).topCard != c )
								r -= c.controller.fieldsC.getAt( i ).topCard.statusC.realPowerValue;
					return r;
				}
			}
			
			F[ "resque_zack" ] =
			function( c:Card ):void
			{
				c.statusC.addNewBuff( false ).powerOffset =
				function( cc:Card ):int {
					if ( c.controller.lifePoints >= c.controller.opponent.lifePoints )
						return 0;
					return c.controller.opponent.lifePoints - c.controller.lifePoints;
				}
			}
			
			F[ "social_fiend" ] =
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				c.propsC.summonConditionAutomatic = 
				function( field:CreatureField ):Boolean {
					return c.controller.trapCount == 0;
				}
				
				const PWR:int = c.primalData.getVarInt( 0 );
				c.statusC.addNewBuff( false ).powerOffset =
				function( cc:Card ):int {
					return PWR * c.controller.fieldsC.countOccupied;
				}
			}
			
			F[ "unkillable_barny" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.TURN_START );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c != c.controller.grave.topCard ) return false;
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( c, c.controller );
				}
			}
			
			F[ "mana_thing" ] =
			F[ "mana_beast" ] =
			function( c:Card ):void
			{
				const PWR:int = c.primalData.getVarInt( 0 );
				c.statusC.addNewBuff( false ).powerOffset =
				function( cc:Card ):int {
					return PWR * c.controller.mana.current;
				}
			}
			
			F[ "serious" ] =
			function( c:Card ):void
			{
				const PWR:int = c.primalData.getVarInt( 0 );
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getSourceCard().controller;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addNewBuff( true ).powerOffset = PWR;
				}
			}
			
			F[ "serious2" ] =
			function( c:Card ):void
			{
				const PWR:int = c.primalData.getVarInt( 0 );
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addNewBuff( true ).powerOffset = PWR;
				}
			}
			
			F[ "grand__bloodrager" ] =
			function( c:Card ):void
			{
				const PWR:int = c.primalData.getVarInt( 0 );
				var buff:Buff = new Buff( true );
				buff.powerOffset = 0;
				
				var special:SpecialEffect;
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ENTER_GRAVE_COMPLETE );
				special.funcActivate =
				function( p:GameplayProcess ):void {
					if ( !c.statusC.hasBuff( buff ) )
						c.statusC.addBuff( buff );
					buff.powerOffset += PWR;
				}
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					buff.powerOffset = 0;
				}
			}
			
			F[ "traprage" ] =
			function( c:Card ):void
			{
				const PWR:int = c.primalData.getVarInt( 0 );
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ACTIVATE_TRAP_COMPLETE );
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addNewBuff( true ).powerOffset = PWR;
				}
			}
			
			F[ "bloodhaggler2" ] =
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					if ( c.indexedField.opposingCreature )
					{
						var b:Buff = c.indexedField.opposingCreature.statusC.addNewBuff( true )
						b.cannotAttack = true;
						b.expiryCondition = 
						function( p:GameplayProcess ):Boolean {
							return p.name == GameplayProcess.TURN_END;
						}
					}
					TempDatabaseUtils.doPutInHand( c, c.controller );
					TempDatabaseUtils.doDealDirectDamage( c.controller, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "timereverser" ] =
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					if ( c.controller.grave.isEmpty )
						return;
					TempDatabaseUtils.doPutInDeck( c.controller.grave.topCard, c.controller, false, false );
				}
			}
			
			F[ "paulgrand2" ] =
			function( c:Card ):void
			{
				addHaste( c );
			}
			
			F[ "shy_warrior" ] =
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.cannotAttack = true;
				buff.isActive = 
				function( c:Card ):Boolean {
					if ( !c.isInPlay ) return false;
					if ( c.indexedField.samesideCreatureToTheLeft != null ) return true;
					if ( c.indexedField.samesideCreatureToTheRight != null ) return true;
					return false;
				}
			}
			
			F[ "loneshield" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.CREATURE_DAMAGE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller.creatureCount == 0 ) return false;
					if ( p.getDamage().type != DamageType.COMBAT ) return false;
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
				}
			}
			
			F[ "the_blood_king" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "grand_dk" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "quickfeet" ] =
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					TempDatabaseUtils.doPutInHand( c, c.controller );
				}
			}
			
			F[ "trapkiller0" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c != p.getSourceCard() ) return false;
					if ( c.indexedField.opposingTrap == null ) return false;
					if ( c.indexedField.opposingTrap.faceDown ) return false;
					if ( !c.indexedField.opposingTrap.propsT.effect.isActive ) return false;
					if ( !c.indexedField.opposingTrap.propsT.isPersistent ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDestroyTrap( c.indexedField.opposingTrap, c );
				}
			}
			
			F[ "trapsaver" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DESTROY_TRAP );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.samesideTrap == null ) return false;
					if ( c.indexedField.samesideTrap.faceDown ) return false;
					if ( !c.indexedField.samesideTrap.propsT.effect.isActive ) return false;
					if ( !c.indexedField.samesideTrap.propsT.isPersistent ) return false;
					return c.indexedField.samesideTrap == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "safebuffer" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					for ( var j:int = 0; j < c.controller.fieldsC.count; j++ )
						if ( c.controller.fieldsC.getAt( j ).topCard )
							c.controller.fieldsC.getAt( j ).topCard.statusC.addNewBuff( true ).powerOffset
								= c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "stunbot" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					var b:Buff = c.indexedField.opposingCreature.statusC.addNewBuff( true )
					b.cannotAttack = true;
					b.expiryCondition = 
					function( p:GameplayProcess ):Boolean {
						return p.name == GameplayProcess.TURN_END;
					}
				}
			}
			
			F[ "tactical_joe" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreatureField.isEmpty ) return false;
					return c.controller.opponent == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( c, c.controller );
				}
			}
			
			F[ "token_summoner4" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doSpawnTokenCreatureIfEmpty( c.history.lastIndexedField as CreatureField );
				}
			}
			
			F[ "hastegiver" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getSourceCard().controller;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.getSourceCard().statusC.hasSummonExhaustion = false;
				}
			}
			
			F[ "hastegiver2" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.getSourceCard().statusC.hasSummonExhaustion = false;
				}
			}
			
			F[ "lategamer" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					if ( c.controller.lifePoints > c.primalData.getVarInt( 0 ) )
						TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "mario" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c != p.getAttacker() ) return false;
					if ( GameplayFAQ.canRelocateHere( c, c.indexedField.samesideCreatureFieldToTheRight, true ) ) return true;
					if ( GameplayFAQ.canRelocateHere( c, c.indexedField.samesideCreatureFieldToTheLeft, true ) ) return true;
					return false;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					if ( GameplayFAQ.canRelocateHere( c, c.indexedField.samesideCreatureFieldToTheRight, true ) )
						TempDatabaseUtils.doForceRelocate( c, c.indexedField.samesideCreatureFieldToTheRight, true );
					else
					if ( GameplayFAQ.canRelocateHere( c, c.indexedField.samesideCreatureFieldToTheLeft, true ) )
						TempDatabaseUtils.doForceRelocate( c, c.indexedField.samesideCreatureFieldToTheLeft, true );
				}
			}
			
			F[ "megasweeper" ] = 
			function( c:Card ):void
			{
				const PWR:int = c.primalData.getVarInt( 0 );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller != p.getPlayer() ) return false;
					return c.controller.fieldsC.hasAnyFieldThat( checkField ) ||
							c.controller.opponent.fieldsC.hasAnyFieldThat( checkField );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					cleanRow( c.controller.fieldsC );
					cleanRow( c.controller.opponent.fieldsC );
				}
				function cleanRow( row:CreatureFieldsRow ):void
				{
					for ( var i:int = 0; i < row.count; i++ )
					{
						if ( row.getAt( i ).topCard == null ) continue;
						if ( row.getAt( i ).topCard.statusC.realPowerValue <= PWR ) continue;
						TempDatabaseUtils.doKill( row.getAt( i ).topCard, c );
					}
				}
				function checkField( field:CreatureField ):Boolean {
					return field.topCard && field.topCard.statusC.realPowerValue > PWR;
				}
			}
			
			F[ "fair_manaup" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.controller.mana.raiseCap();
					c.controller.opponent.mana.raiseCap();
				}
			}
			
			F[ "bomb" ] = 
			function( c:Card ):void
			{
				const DMG:int = c.primalData.getVarInt( 0 );
				c.propsC.onSafeFlipFunc =
				function():void {
					cleanRow( c.controller.fieldsC );
					cleanRow( c.controller.opponent.fieldsC );
				}
				function cleanRow( row:CreatureFieldsRow ):void
				{
					for ( var i:int = 0; i < row.count; i++ )
					{
						if ( row.getAt( i ).topCard == null ) continue;
						TempDatabaseUtils.doDealDirectDamage( c.controller, DMG, c );
						TempDatabaseUtils.doKill( row.getAt( i ).topCard, c );
					}
				}
			}
			
			F[ "swapper" ] = 
			F[ "swapper2" ] = 
			F[ "swapper3" ] = 
			function( c:Card ):void
			{
				c.propsC.hasSwap = true;
			}
			
			F[ "swap_right" ] = 
			F[ "swap_left" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					const FIELD:CreatureField = c.controller.samesideCreatureFieldAtIndex(
						c.indexedField.index + c.primalData.getVarInt( 0 ) );
					TempDatabaseUtils.doForceSwap( c, FIELD, true );
				}
			}
			
			F[ "autoattacker" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.cannotBeTribute = true;
				buff.cannotAttack = true;
				
				addHaste( c );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doForceAttack( c, true );
				}
			}
			
			F[ "doomsday" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKillCreaturesRow( c.controller, c );
					TempDatabaseUtils.doKillCreaturesRow( c.controller.opponent, c );
				}
			}
			
			F[ "badpiercer" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !p.getDeathIsFromCombat() ) return false;
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( c.statusC.realPowerValue == c.indexedField.opposingCreature.statusC.realPowerValue ) return false;
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
				}
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( c.indexedField.opposingCreature.statusC.realPowerValue
						== c.statusC.realPowerValue ) return false;
					return isInvolvedInBattle( c, p );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					const DMG:int = Math.abs( c.statusC.realPowerValue - c.indexedField.opposingCreature.statusC.realPowerValue );
					TempDatabaseUtils.doDealDirectDamage( c.controller, DMG, c );
				}
			}
			
			F[ "specialo" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( p.isSummonManual() ) return false;
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addNewBuff( true ).powerOffset = c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "producer" ] = 
			function( c:Card ):void
			{
				const POW:int = c.primalData.getVarInt( 0 );
				c.statusC.addNewBuff( false ).powerOffset =
				function( cc:Card ):int {
					return POW * c.controller.hand.cardsCount;
				}
			}
			
			F[ "ferocious_sara" ] = 
			function( c:Card ):void
			{
				const POW:int = c.primalData.getVarInt( 0 );
				c.statusC.addNewBuff( false ).powerOffset = 
				function( cc:Card ):int {
					return POW * c.controller.opponent.creatureCount;
				}
			}
			
			F[ "trapkiller1" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					TempDatabaseUtils.doDestroyTrapsRow( c.controller.opponent, c );
					TempDatabaseUtils.doDestroyTrapsRow( c.controller, c );
				}
			}
			
			F[ "trapkiller2" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					TempDatabaseUtils.doPutInHandTrapsRow( c.controller.opponent );
				}
			}
			
			F[ "trapkiller3" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					TempDatabaseUtils.doEndTurn( c.controller );
					TempDatabaseUtils.doDestroyTrapsRow( c.controller.opponent, c );
				}
			}
			
			
			F[ "token_pooper" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.RELOCATE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( p.isRelocationFree() ) return false;
					if ( c.history.lastIndexedField == null ) return false;
					return c == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doSpawnTokenCreatureIfEmpty( c.history.lastIndexedField as CreatureField );
				}
			}
			
			F[ "grower" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.faceDown ) return false;
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addNewBuff( true ).powerOffset = c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "enraged" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getSourceCard().controller;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var b:Buff = c.statusC.addNewBuff( true );
					b.powerOffset = c.primalData.getVarInt( 0 );
					b.expiryCondition = 
					function( p:GameplayProcess ):Boolean {
						if ( p.name != GameplayProcess.ATTACK_COMPLETE && 
							 p.name != GameplayProcess.ATTACK_ABORT ) return false;
						if ( p.getAttacker() != c ) return false;
						return true;
					}
				}
			}
			
			F[ "copycat" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					if ( c.indexedField.opposingCreature == null ) return;
					if ( c.indexedField.opposingCreature.faceDown ) return;
					if ( c.indexedField.opposingCreature.statusC.realPowerValue < 1 ) return;
					c.statusC.addNewBuff( true ).powerOffset = c.indexedField.opposingCreature.statusC.realPowerValue - 1;
				}
			}
			
			F[ "grand_copycat" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( c.indexedField.opposingCreature.faceDown ) return false;
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					if ( c.indexedField.opposingCreature == null ) return;
					c.statusC.addNewBuff( true ).powerOffset = c.indexedField.opposingCreature.statusC.realPowerValue + 1;
				}
			}
			
			F[ "antigrando" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.powerOffset = c.primalData.getVarInt( 0 );
				buff.isActive = 
				function( c:Card ):Boolean {
					if ( !c.isInPlay ) return false;
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( c.indexedField.opposingCreature.faceDown ) return false;
					if ( !c.indexedField.opposingCreature.propsC.isGrand ) return false;
					return true;
				}
			}
			
			F[ "trapowered2" ] = 
			function( c:Card ):void
			{
				const PWR_STEP:int = c.primalData.getVarInt( 0 );
				c.statusC.addNewBuff( false ).powerOffset =
				function( c:Card ):int {
					return PWR_STEP * c.controller.trapCount;
				}
			}
			
			F[ "evo_g_f1" ] = 
			F[ "evo_g_f2" ] = 
			F[ "evo_g_f3" ] = 
			function( c:Card ):void
			{
				const TRIBUTE:String = c.primalData.getVarSlug( 0 );
				
				c.propsC.summonConditionManual = 
				function( field:CreatureField ):Boolean
				{ return field.topCard.slug == TRIBUTE }
				
				c.propsC.summonConditionAutomatic = 
				function( field:CreatureField ):Boolean
				{ return false }
			}
			
			F[ "evo_a_f2" ] = 
			function( c:Card ):void
			{
				c.statusC.addNewBuff( false ).cannotAttack = true;
			}
			
			F[ "trapkiller" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					if ( c.indexedField.opposingTrap != null )
						TempDatabaseUtils.doDestroyTrap( c.indexedField.opposingTrap, c );
				}
			}
			
			F[ "devouerer2" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getDeathCauser() && p.getDeathIsFromCombat();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addNewBuff( true ).powerOffset = p.getSourceCard().statusC.basePowerValue;
				}
				
				addHaste( c );
			}
			
			F[ "devouerer" ] = //////TODO must work as one effect
			function( c:Card ):void
			{
				var delta:int = 0;
				var special:SpecialEffect;
				
				/// Remember real power value
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getDeathCauser() && p.getDeathIsFromCombat();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					delta = p.getSourceCard().statusC.realPowerValue;
				}
				
				/// Apply power delta
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getDeathCauser() && p.getDeathIsFromCombat();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addNewBuff( true ).powerOffset = delta;
					delta = 0;
				}
			}
			
			F[ "necropy" ] = 
			function( c:Card ):void
			{
				c.statusC.addNewBuff( true ).powerOffset =
				function( cc:Card ):int {
					return getTopCardBasePower( c.controller.opponent.grave );
				}
			}
			
			F[ "grandbro1" ] = 
			F[ "grandbro2" ] = 
			function( c:Card ):void
			{
				const BROTHER:String = c.primalData.getVarSlug( 1 );
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.powerOffset = c.primalData.getVarInt( 0 );
				buff.isActive = 
				function( c:Card ):Boolean {
					return c.controller.fieldsC.findBySlug( BROTHER ) != null;
				}
			}
			
			F[ "ed" ] = 
			F[ "edd" ] = 
			F[ "eddy" ] = 
			function( c:Card ):void
			{
				const BRO1:String = c.primalData.getVarSlug( 0 );
				const BRO2:String = c.primalData.getVarSlug( 1 );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c != p.getSourceCard() ) return false;
					if ( c.controller.fieldsC.findBySlug( BRO1 ) )
						if ( c.controller.deck.findBySlug( BRO2 ) )
							return true;
					if ( c.controller.fieldsC.findBySlug( BRO2 ) )
						if ( c.controller.deck.findBySlug( BRO1 ) )
							return true;
					return false;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var target:Card;
					if ( c.controller.fieldsC.findBySlug( BRO1 ) )
						target = c.controller.deck.findBySlug( BRO2 );
					if ( c.controller.fieldsC.findBySlug( BRO2 ) )
						target = c.controller.deck.findBySlug( BRO1 );
					if ( target == null )
						return;
					TempDatabaseUtils.doPutInHand( target, c.controller );
				}
			}
			
			F[ "cowardly_giant" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == p.getAttacker() ) return true;
					return c.indexedField.opposingCreatureField == p.getAttacker().history.lastIndexedField;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( c, c.controller );
				}
			}
			
			F[ "lonely_golem" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.LEAVE_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.creatureCount == 1;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "grandtraitor" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.LEAVE_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller.creatureCount > 1 ) return false;
					if ( !c.indexedField.opposingCreatureField.isEmpty ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doForceRelocate( c, c.indexedField.opposingCreatureField, true );
				}
			}
			
			F[ "yin" ] = 
			F[ "yang" ] = 
			function( c:Card ):void
			{
				const BROTHER:String = c.primalData.getVarSlug( 1 );
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.powerOffset = c.primalData.getVarInt( 0 );
				buff.isActive = 
				function( c:Card ):Boolean {
					if ( !c.isInPlay ) return false;
					if ( c.indexedField.samesideCreatureToTheLeft != null )
						if ( c.indexedField.samesideCreatureToTheLeft.slug == BROTHER )
							return true;
					if ( c.indexedField.samesideCreatureToTheRight != null )
						if ( c.indexedField.samesideCreatureToTheRight.slug == BROTHER )
							return true;
					return false;
				}
			}
			
			F[ "gcontract_haste" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller.grave.topCard != c ) return false;
					if ( c.controller != p.getSourceCard().controller ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller, c.primalData.getVarInt( 0 ), c );
					p.getSourceCard().statusC.hasSummonExhaustion = false;
				}
			}
			
			F[ "token_summoner2" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c != p.getSourceCard() ) return false;
					if ( c.indexedField.samesideCreatureFieldToTheLeft != null && c.indexedField.samesideCreatureFieldToTheLeft.isEmpty ) return true;
					if ( c.indexedField.samesideCreatureFieldToTheRight != null && c.indexedField.samesideCreatureFieldToTheRight.isEmpty ) return true;
					return false;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doSpawnTokenCreatureIfEmpty( c.indexedField.samesideCreatureFieldToTheLeft );
					TempDatabaseUtils.doSpawnTokenCreatureIfEmpty( c.indexedField.samesideCreatureFieldToTheRight );
				}
			}
			
			F[ "balloonbrute" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( p.getAttacker().statusC.realPowerValue >= c.statusC.realPowerValue ) return false;
					return c.indexedField.opposingCreature == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "piercing_george" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( c.indexedField.opposingCreature.statusC.realPowerValue
						== c.statusC.realPowerValue ) return false;
					return isInvolvedInBattle( c, p );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					const DMG:int = Math.abs( c.statusC.realPowerValue - c.indexedField.opposingCreature.statusC.realPowerValue );
					const PLR:Player = c.statusC.realPowerValue < c.indexedField.opposingCreature.statusC.realPowerValue ?
									c.controller : c.controller.opponent;
					TempDatabaseUtils.doDealDirectDamage( PLR, DMG, c );
				}
			}
			
			F[ "flappy_bird" ] = 
			function( c:Card ):void
			{
				c.propsC.hasSwift = true;
			}
			
			F[ "flappy_bird2" ] = 
			function( c:Card ):void
			{
				c.propsC.hasSwift = true;
				
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.isActive = 
				function( c:Card ):Boolean {
					return c.isInPlay && c.indexedField.opposingCreature == null;
				}
				buff.cannotAttack = true;
			}
			
			F[ "berserker" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doForceAttack( c, false );
				}
			}
			
			F[ "flappy_rooster" ] = 
			function( c:Card ):void
			{
				c.propsC.hasSwift = true;
			}
			
			F[ "vouerer" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !c.controller.isMyTurn ) return false;
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addNewBuff( true ).powerOffset = -p.getSourceCard().statusC.realPowerValue;
				}
			}
			
			F[ "time_lord" ] = 
			function( c:Card ):void
			{
				const HANDCARDS:int = c.primalData.getVarInt( 0 );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ENTER_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var o:Player;
					var i:int;
					
					o = c.controller;
					for ( i = 0; i < HANDCARDS - o.hand.cardsCount; i++ )
						if ( i < o.grave.cardsCount )
							TempDatabaseUtils.doPutInHand(
								o.grave.getCardAt( o.grave.cardsCount - 1 - i ), o );
					
					o = c.controller.opponent;
					for ( i = 0; i < HANDCARDS - o.hand.cardsCount; i++ )
						if ( i < o.grave.cardsCount )
							TempDatabaseUtils.doPutInHand(
								o.grave.getCardAt( o.grave.cardsCount - 1 - i ), o );
				}
			}
			
			F[ "for_a_lid" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !p.isSummonManual() ) return false;
					if ( !c.controller.isMyTurn ) return false;
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doEndTurn( c.controller.opponent );
				}
			}
			
			F[ "shield8" ] = 
			function( c:Card ):void
			{
				c.statusC.addNewBuff( false ).cannotAttack = true;
				
				var special:SpecialEffect;
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIRECT_DAMAGE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.faceDown ) return false;
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.getDamage().amount = 0;
				}
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.faceDown ) return false;
					if ( c.controller.mana.current >= c.primalData.getVarInt( 0 ) ) return false;
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "divine_syphon" ] = 
			function( c:Card ):void
			{
				var gb:GlobalBuff = new GlobalBuff( c );
				gb.setEffect( null, true, null, null );
				gb.appliesTo = 
				function ( cc:Card ):Boolean { return cc != c }
				registerGlobalBuffWhileInPlay( c, gb );
				
				c.statusC.addNewBuff( false ).powerOffset =
				function( cc:Card ):int {
					var r:int;
					for ( var i:int = 0; i < c.controller.fieldsC.count; i++ ) 
					{
						cc = c.controller.fieldsC.getAt( i ).topCard;
						if ( cc == null ) continue;
						if ( cc == c ) continue;
						if ( cc.faceDown ) continue;
						r += cc.statusC.realPowerValue;
					}
					return r;
				}
			}
			
			F[ "impatient_goeff" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.HAND );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDiscard( c.controller, c );
				}
			}
			
			F[ "blood_fiend" ] = 
			function( c:Card ):void
			{
				c.statusC.addNewBuff( false ).powerOffset =
				function( cc:Card ):int {
					return getPwr( c.controller ) + getPwr( c.controller.opponent );
				}
				function getPwr( p:Player ):int {
					if ( p.grave.isEmpty ) return 0;
					if ( !p.grave.topCard.isCreature ) return 0;
					return p.grave.topCard.statusC.realPowerValue;
				}
			}
			
			//
			
			F[ "nuke_virus" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					TempDatabaseUtils.doDealDirectDamage( c.controller, 
						c.indexedField.opposingCreature.statusC.realPowerValue, c );
					TempDatabaseUtils.doKill( c, c );
					TempDatabaseUtils.doKill( c.indexedField.opposingCreature, c );
				}
			}
			
			F[ "trapowered" ] = 
			function( c:Card ):void
			{
				const PWR_STEP:int = c.primalData.getVarInt( 0 );
				c.statusC.addNewBuff( false ).powerOffset =
				function( c:Card ):int {
					return PWR_STEP * c.controller.grave.countCardsThat( CardFAQ.isTrap );
				}
			}
			
			F[ "evo_flip_a" ] = 
			function( c:Card ):void
			{
				const GRAND:String = c.primalData.getVarSlug( 0 );
				c.propsC.onSafeFlipFunc =
				function():void {
					var target:Card;
					target = c.controller.hand.findBySlug( GRAND );
					if ( target == null ) target = c.controller.deck.findBySlug( GRAND );
					if ( target == null ) return;
					TempDatabaseUtils.doSummonFromDeckOrHand( target, c.fieldC );
				}
			}
			
			F[ "evo_flip_g" ] = 
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				function( f:CreatureField ):Boolean { return false }
			}
			
			F[ "provoked_nina" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "shield1" ] = 
			function( c:Card ):void
			{
				c.statusC.addNewBuff( false ).cannotAttack = true;
			}
			
			F[ "fateforward" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					TempDatabaseUtils.doDraw( c.controller, 3 );
					TempDatabaseUtils.doDraw( c.controller.opponent, 3 );
				}
			}
			
			F[ "spying_james" ] = 
			function( c:Card ):void
			{
				var ongoing:OngoingEffect;
				ongoing = c.propsC.addOngoing();
				ongoing.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.isInPlay && !c.controller.opponent.deck.isEmpty;
				}
				ongoing.funcUpdate =
				function( p:GameplayProcess ):void {
					c.controller.opponent.deck.topCard.faceDown = false;
				}
			}
			
			F[ "big_shield" ] = 
			function( c:Card ):void
			{
				c.statusC.addNewBuff( false ).cannotAttack = true;
			}
			
			F[ "nightelf1" ] = 
			F[ "nightelf2" ] = 
			F[ "nightelf3" ] = 
			F[ "nightelf4" ] = 
			F[ "broodelf1" ] = 
			F[ "broodelf2" ] = 
			F[ "broodelf3" ] = 
			F[ "broodelf4" ] = 
			function( c:Card ):void
			{
				const BROTHER:String = c.primalData.getVarString( 0 );
				const POWER:int = c.primalData.getVarInt( 1 );
				
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.powerOffset =
				function( c:Card ):int {
					return POWER * c.controller.grave.countCardsThat( isBro );
				}
				function isBro( cc:Card ):Boolean {
					return cc.slug.indexOf( BROTHER ) > -1;
				}
			}
			
			F[ "bloodmerc" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.ENTER_GRAVE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "thieving_monkey" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					if ( c.controller.opponent.grave.isEmpty ) return;
					TempDatabaseUtils.doPutInHand( c.controller.opponent.grave.topCard, c.controller );
				}
			}
			F[ "mana_dispenser_2" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					c.controller.mana.increase( 2 );
				}
			}
			
			F[ "mana_drainer" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					c.controller.opponent.mana.decrease( c.controller.opponent.mana.current );
				}
			}
			
			F[ "deckstructor" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( p.getAttacker().statusC.realPowerValue <= c.statusC.realPowerValue ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					const COUNT:int = p.getAttacker().statusC.realPowerValue - c.statusC.realPowerValue;
					TempDatabaseUtils.doDiscardFromDeck( p.getAttacker().controller, COUNT );
				}
			}
			
			F[ "badfate" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					TempDatabaseUtils.doDiscardHand( c.controller );
					TempDatabaseUtils.doDiscardHand( c.controller.opponent );
				}
			}
			
			F[ "shield2" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.cannotAttack = true;
				
				c.propsC.onCombatFlipFunc =
				function():void {
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "jerry" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					var buff:Buff = c.statusC.addNewBuff( true );
					buff.powerOffset = c.primalData.getVarInt( 0 );
					buff.expiryCondition = 
					function( p:GameplayProcess ):Boolean {
						return p.name == GameplayProcess.TURN_END;
					}
				}
			}
			
			F[ "trapowered3" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					var buff:Buff = c.statusC.addNewBuff( true )
					buff.powerOffset = c.primalData.getVarInt( 0 ) * c.controller.trapCount;
				}
			}
			
			F[ "crowdpowered" ] = 
			function( c:Card ):void
			{
				const PWR_STEP:int = c.primalData.getVarInt( 0 );
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.powerOffset =
				function( c:Card ):int {
					return PWR_STEP * ( c.controller.creatureCount + c.controller.opponent.creatureCount - ( c.isInPlay ? 1 : 0 ) );
				}
			}
			
			F[ "socialgnome" ] = 
			function( c:Card ):void
			{
				const PWR_STEP:int = c.primalData.getVarInt( 0 );
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.powerOffset =
				function( c:Card ):int {
					return PWR_STEP * c.controller.creatureCount;
				}
			}
			
			F[ "decksummoner" ] =
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller.deck.isEmpty ) return false;
					if ( c.controller.isMyTurn ) return false;
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					const CARD:Card = c.controller.deck.topCard;
					if ( CARD == null ) return;
					CARD.faceDown = false;
					if ( CARD.isCreature && !CARD.propsC.isGrand )
						TempDatabaseUtils.doSummonFromDeckOrHand( CARD, c.history.lastIndexedField as CreatureField );
					TempDatabaseUtils.delay( .350 );
				}
			}
			
			F[ "younghealer" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					TempDatabaseUtils.doHeal( c.controller, c.primalData.getVarInt( 0 ) );
				}
			}
			
			F[ "cheerleader1" ] = 
			F[ "cheerleader2" ] = 
			F[ "cheerleader3" ] = 
			F[ "cheerleader4" ] = 
			F[ "forsaken1" ] = 
			F[ "forsaken2" ] = 
			F[ "forsaken3" ] = 
			F[ "forsaken4" ] = 
			function( c:Card ):void
			{
				const BROTHER:String = c.primalData.getVarString( 1 );
				const POWER:int = c.primalData.getVarInt( 0 );
				c.statusC.addNewBuff( false ).powerOffset =
				function( cc:Card ):int {
					return Number.max( 0, POWER * ( c.controller.fieldsC.countCreaturesThat( isBro ) - 1 ) );
				}
				function isBro( cc:Card ):Boolean {
					return cc.slug.indexOf( BROTHER ) > -1;
				}
			}
			
			F[ "flipmike" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					TempDatabaseUtils.doDraw( c.controller, c.primalData.getVarInt( 0 ) );
				}
			}
			
			F[ "mr_mirakul" ] = 
			function( c:Card ):void
			{
				/* * * /
				c.propsC.summonConditionManual = 
				function( field:CreatureField ):Boolean {
					return c.history.tribute != null || field.topCard.propsC.isGrand;
				}
				/* * */
				
				const PWR:int = c.primalData.getVarInt( 0 );
				
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.powerOffset = 0;
				buff.isActive = true;
				
				var ongoing:OngoingEffect;
				ongoing = c.propsC.addOngoing();
				ongoing.funcUpdate =
				function( p:GameplayProcess ):void {
					buff.powerOffset = c.controller.opponent.fieldsC.countOccupied * PWR;
				}
			}
			
			F[ "black_hood" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					burnLine( c.controller );
					burnLine( c.controller.opponent );
				}
				function burnLine( p:Player ):void {
					var i:int;
					var cc:Card;
					for ( i = 0; i < p.fieldsC.count; i++ ) 
					{
						cc = p.fieldsC.getAt( i ).topCard;
						if ( cc == null ) continue;
						if ( cc == c ) continue;
						if ( cc.faceDown ) continue;
						if ( cc.statusC.realPowerValue >= c.statusC.realPowerValue ) continue;
						TempDatabaseUtils.doKill( cc, c );
					}
				}
			}
			
			F[ "black_hood2" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					burnLine( c.controller );
					burnLine( c.controller.opponent );
				}
				function burnLine( p:Player ):void {
					var i:int;
					var cc:Card;
					for ( i = 0; i < p.fieldsC.count; i++ ) 
					{
						cc = p.fieldsC.getAt( i ).topCard;
						if ( cc == null ) continue;
						if ( cc == c ) continue;
						if ( cc.faceDown ) continue;
						if ( cc.statusC.realPowerValue >= c.statusC.realPowerValue ) continue;
						TempDatabaseUtils.doKill( cc, c );
					}
				}
			}
			
			F[ "dark_one" ] = 
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				function( field:CreatureField ):Boolean {
					return c.history.tribute != null || c.controller.creatureCount >= c.primalData.getVarInt( 0 );
				}
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var i:int;
					var cc:Card;
					for ( i = 0; i < c.controller.fieldsC.count; i++ ) 
					{
						cc = c.controller.fieldsC.getAt( i ).topCard;
						if ( cc == null ) continue;
						if ( cc == c ) continue;
						TempDatabaseUtils.doKill( cc, c );
					}
				}
			}
			
			F[ "shmester" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.powerOffset = 0;
				buff.isActive = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ENTER_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c != p.getSourceCard() && p.getSourceCard().isCreature;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					buff.powerOffset -= c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "drawhater" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.powerOffset = 0;
				buff.isActive = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DRAW_CARD_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					buff.powerOffset -= c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "drawrager2" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.powerOffset = 0;
				buff.isActive = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DRAW_CARD_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					buff.powerOffset += c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "drawrager" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.powerOffset = 0;
				buff.isActive = true;
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DRAW_CARD_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					buff.powerOffset += c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "grandegrand" ] = 
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				function( field:CreatureField ):Boolean {
					return c.history.tribute != null || field.topCard.propsC.isGrand;
				}
			}
			
			F[ "harrasser1" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.cannotBeTribute = true;
				
				c.cost = c.primalData.getVarInt( 0 );
				
				addHaste( c );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( c, c.controller );
				}
			}
			
			F[ "harrasser2" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.cannotBeTribute = true;
				
				c.propsC.summonConditionManual = 
				c.propsC.summonConditionAutomatic = 
				function( field:CreatureField ):Boolean {
					return c.controller.creatureCount == 0;
				}
				
				addHaste( c );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( c, c.controller );
				}
			}
			
			F[ "grandgrandpaul" ] = 
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				function( field:CreatureField ):Boolean {
					return c.history.tribute != null || field.topCard.propsC.isGrand;
				}
				
				addHaste( c );
			}
			
			F[ "general" ] = 
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				function( f:CreatureField ):Boolean {
					return c.history.tribute != null ||
						c.controller.fieldsC.count == c.controller.fieldsC.countOccupied;
				}
			}
			
			F[ "paul2" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.cannotBeTribute = true;
				
				c.propsC.summonConditionManual = 
				function( field:CreatureField ):Boolean {
					return field.opposingCreature != null;
				}
				
				addHaste( c );
			}
			
			F[ "paul3" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.cannotBeTribute = true;
				buff.cannotAttack =
				function( cc:Card ):Boolean {
					return c.isInPlay && c.indexedField.opposingCreature == null;
				}
				
				addHaste( c );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK_COMPLETE, GameplayProcess.ATTACK_ABORT );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "tempower2" ] = 
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
					c.statusC.addNewBuff( true ).powerOffset = -c.primalData.getVarInt( 0 );
				}
			}
			
			F[ "tempower" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					c.statusC.addNewBuff( true ).powerOffset = c.primalData.getVarInt( 0 );
				}
				
				const STEP:int = c.primalData.getVarInt( 1 );
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer() && c.statusC.realPowerValue >= STEP;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.addNewBuff( true ).powerOffset = -STEP;
				}
			}
			
			F[ "force_field" ] = 
			function( c:Card ):void
			{
				const STEP:int = c.primalData.getVarInt( 1 );
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIRECT_DAMAGE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.getDamage().amount = 0;
				}
			}
			
			F[ "johnny1" ] = 
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				function( field:CreatureField ):Boolean {
					return field.opposingCreature == null;
				}
			}
			
			F[ "emma" ] = 
			function( c:Card ):void
			{
				var ongoing:OngoingEffect;
				ongoing = c.propsC.addOngoing();
				ongoing.funcUpdate =
				function( p:GameplayProcess ):void {
					c.cost = c.controller.mana.current <= 0 ? 0 : 1;
				}
			}
			
			F[ "force_field2" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.cannotAttack = true;
				
				var gb:GlobalBuff = new GlobalBuff( c );
				gb.setEffect( null, true, null, null );
				gb.appliesTo = c.faq.isNotOpposingCreature;
				gb.isActive =
				function():Boolean {
					return c.isInPlay
						&& c.indexedField.opposingCreature 
						&& c.indexedField.opposingCreature.statusC.canAttack;
				}
				registerGlobalBuffWhileInPlay( c, gb );
			}
			
			F[ "vendeto" ] = 
			function( c:Card ):void
			{
				const GRAND:String = c.primalData.getVarSlug( 0 );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean
				{
					if ( c != p.getSourceCard() ) return false;
					if ( !p.getDeathIsFromCombat() ) return false;
					var target:Card;
					target = c.controller.hand.findBySlug( GRAND );
					if ( target == null )
						target = c.controller.deck.findBySlug( GRAND );
					if ( target == null )
						return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void
				{
					var target:Card;
					target = c.controller.hand.findBySlug( GRAND );
					if ( target == null )
						target = c.controller.deck.findBySlug( GRAND );
					if ( target == null )
						return;
					var field:CreatureField = c.history.lastIndexedField as CreatureField ;
					if ( !target.statusC.canBeSummonedOn( field, false ) )
						return;
					TempDatabaseUtils.doSummonFromDeckOrHand( target, field );
				}
			}
			
			F[ "vendeto_grand" ] = 
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				function( f:CreatureField ):Boolean { return false }
				
				const GRAND:String = c.primalData.getVarSlug( 0 );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watchAll()
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.grave.findBySlug( GRAND ) == null;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "spike" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					TempDatabaseUtils.doDealDirectDamage( 
						c.controller.opponent, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "paulgrand" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard() && c.indexedField.opposingCreature != null;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.hasSummonExhaustion = false;
				}
			}
			
			F[ "specialhaste" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard() && !p.isSummonManual();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.statusC.hasSummonExhaustion = false;
				}
			}
			
			F[ "crippler" ] = 
			function( c:Card ):void
			{
				var b:Buff;
				b = new Buff( true );
				b.powerOffset = -c.primalData.getVarInt( 0 );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( p.getSourceCard().faceDown ) return false;
					return c.controller.opponent == p.getSourceCard().controller;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.getSourceCard().statusC.addBuff( b );
				}
			}
			
			F[ "general2" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.powerOffset = c.primalData.getVarInt( 0 );
				buff.isActive = 
				function( cc:Card ):Boolean {
					return c.controller.fieldsC.countOccupied >= c.controller.fieldsC.count;
				}
			}
			
			F[ "all_out_joe" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDiscardHand( c.controller );
				}
			}
			
			F[ "paul1" ] = 
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				c.propsC.summonConditionAutomatic = 
				function( f:CreatureField ):Boolean {
					return c.controller.creatureCount == 0;
				}
				
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.cannotBeTribute = true;
				
				addHaste( c );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "tranquility" ] = 
			function( c:Card ):void
			{
				var gb:GlobalBuff = new GlobalBuff( c );
				gb.setEffect( null, true, null, null );
				gb.appliesTo = c.faq.isOpposingCreature;
				registerGlobalBuffWhileInPlay( c, gb );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer() 
						&& c.indexedField.opposingCreature == null;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "glassspike" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					TempDatabaseUtils.doDealDirectDamage( 
						c.controller.opponent, c.statusC.realPowerValue, c );
				}
			}
			
			F[ "managiver" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.controller.mana.increase( c.primalData.getVarInt( 0 ) );
				}
			}
			
			F[ "actiontaker" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !c.statusC.canAttack ) return false;
					return c.controller == p.getSourceCard().controller;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.getSourceCard().statusC.actionsAttack--;
					c.statusC.actionsAttack++;
				}
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.RELOCATE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !c.statusC.canRelocate ) return false;
					return c.controller == p.getSourceCard().controller;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.getSourceCard().statusC.actionsRelocate--;
					c.statusC.actionsRelocate++;
				}
			}
			
			F[ "upgrade" ] = 
			function( c:Card ):void
			{
				var b:Buff = new Buff( true );
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					b.powerOffset = c.history.tribute.statusC.realPowerValue;
					c.statusC.addBuff( b );
				}
			}
			
			F[ "stunner" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					var buff:Buff = c.indexedField.opposingCreature.statusC.addNewBuff( true )
					buff.cannotAttack = true;
					buff.cannotRelocate = true;
					buff.expiryCondition = 
					function( p:GameplayProcess ):Boolean {
						return p.name == GameplayProcess.TURN_END;
					}
				}
			}
			
			F[ "grand_powerhealer" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doHeal( c.controller, c.history.tribute.statusC.realPowerValue );
				}
			}
			
			F[ "resurrecter2" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					const TARGET:Card = c.controller.opponent.grave.topCard;
					if ( TARGET == null ) return;
					if ( !TARGET.isCreature ) return;
					if ( !TARGET.statusC.canBeSummonedOn( c.fieldC, false ) ) return;
					TempDatabaseUtils.doResurrectCreature( TARGET, c.fieldC, c );
				}
			}
			
			F[ "resurrecter4" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					const TARGET:Card = c.controller.grave.topCard;
					if ( TARGET == null ) return;
					if ( !TARGET.isCreature ) return;
					if ( !TARGET.statusC.canBeSummonedOn( c.fieldC, false ) ) return;
					TempDatabaseUtils.doResurrectCreature( TARGET, c.fieldC, c );
				}
			}
			
			F[ "resurrecter66" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller != p.getPlayer() ) return false;
					return c.controller.grave.findFirstCard( isViableTarget ) != null;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					const TARGET:Card = c.controller.grave.findFirstCard( isViableTarget );
					if ( TARGET == null ) return;
					TempDatabaseUtils.doResurrectCreature( TARGET, c.fieldC, c );
					TempDatabaseUtils.doDealDirectDamage( c.controller, TARGET.propsC.basePower, c );
				}
				function isViableTarget( cc:Card ):Boolean {
					if ( !cc.isCreature ) return false;
					if ( !cc.propsC.isGrand ) return false;
					if ( !cc.statusC.canBeSummonedOn( c.fieldC, false ) ) return false;
					return true;
				}
			}
			
			F[ "compromiser1" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.skipTribute = true;
				buff.isActive =
				function( cc:Card ):Boolean {
					return c.controller.creatureCount == 0;
				}
			}
			
			F[ "compromiser2" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.skipTribute = true;
				buff.isActive =
				function( cc:Card ):Boolean {
					return c.controller.hand.cardsCount == 1;
				}
			}
			
			F[ "compromiser3" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.skipTribute = true;
				buff.isActive =
				function( cc:Card ):Boolean {
					if ( c.controller.trapCount > 0 ) return false;
					if ( c.controller.opponent.fieldsC.countOccupied < c.controller.opponent.fieldsC.count ) return false;
					return true;
				}
			}
			
			F[ "motivator" ] = 
			function( c:Card ):void
			{
				var gb:GlobalBuff = new GlobalBuff( c );
				gb.setEffect( c.primalData.getVarInt( 0 ), null, null, null );
				gb.appliesTo = c.faq.isFriendly;
				
				var special:SpecialEffect;
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.registerGlobalBuff( gb );
				}
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.LEAVE_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.removeGlobalBuff( gb );
				}
			}
			
			F[ "confusor" ] = 
			function( c:Card ):void
			{
				var gb:GlobalBuff = new GlobalBuff( c );
				gb.setEffect( -c.primalData.getVarInt( 0 ), null, null, null );
				gb.appliesTo = c.faq.isEnemy;
				
				var special:SpecialEffect;
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.registerGlobalBuff( gb );
				}
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.LEAVE_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.removeGlobalBuff( gb );
				}
			}
			
			F[ "badclown" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller.opponent != p.getPlayer() ) return false;
					if ( c.controller.opponent.grave.isEmpty ) return false;
					if ( !c.controller.opponent.grave.topCard.isTrap ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller.opponent, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "kamikaze2" ] = 
			function( c:Card ):void
			{
				c.propsC.onCombatFlipFunc =
				function():void {
					if ( c.indexedField.opposingCreature == null )
						return;
					const DMG:int = c.indexedField.opposingCreature.statusC.realPowerValue;
					TempDatabaseUtils.doKill( c, c );
					TempDatabaseUtils.doKill( c.indexedField.opposingCreature, c );
					TempDatabaseUtils.doDealDirectDamage( c.controller, DMG, c );
				}
			}
			
			F[ "kamikaze" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c != p.getSourceCard() ) return false;
					return c.indexedField.opposingCreature != null;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					const DMG:int = c.indexedField.opposingCreature.statusC.realPowerValue;
					TempDatabaseUtils.doKill( c, c );
					TempDatabaseUtils.doKill( c.indexedField.opposingCreature, c );
					TempDatabaseUtils.doDealDirectDamage( c.controller, DMG, c );
				}
			}
			
			F[ "nona" ] = 
			function( c:Card ):void
			{
				c.propsC.onSafeFlipFunc =
				function():void {
					var b:Buff = new Buff( true );
					b.powerOffset = c.primalData.getVarInt( 0 );
					c.statusC.addBuff( b );
				}
			}
			
			F[ "freefred" ] = 
			function( c:Card ):void
			{
				c.cost = 0;
			}
			
			F[ "emptyshell" ] = 
			function( c:Card ):void
			{
				addHaste( c );
			}
			
			F[ "tripplemana" ] = 
			function( c:Card ):void
			{
				c.cost = 3;
			}
			
			F[ "doublemana" ] = 
			function( c:Card ):void
			{
				c.cost = 2;
			}
			
			F[ "blocker" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c != p.getSourceCard() ) return false;
					if ( !p.getDeathIsFromCombat() ) return false;
					if ( c.controller.creatureCount > 1 ) return false;
					return  true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
				}
			}
			
			F[ "drawban3" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.DRAW_CARD_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller.grave.topCard != c ) return false;
					if ( c.controller.opponent != p.getPlayer() ) return false;
					if ( !p.getDrawIsManual() ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDiscard( c.controller.opponent, p.getDrawnCard() );
				}
			}
			
			F[ "drawban2" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DRAW_CARD_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDiscard( c.controller.opponent, p.getDrawnCard() );
					TempDatabaseUtils.doDealDirectDamage( c.controller, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "drawban" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DRAW_CARD_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getPlayer() && p.getDrawIsManual();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDiscard( c.controller.opponent, p.getDrawnCard() );
					TempDatabaseUtils.doDealDirectDamage( c.controller, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "jack" ] = 
			F[ "jill" ] = 
			function( c:Card ):void
			{
				const BROTHER:String = c.primalData.getVarSlug( 0 );
				const FDELTA:String = c.primalData.getVarInt( 1 );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c != p.getSourceCard() ) return false;
					const FIELD:CreatureField = findTargetField();
					if ( FIELD == null ) return false;
					if ( !FIELD.isEmpty ) return false;
					const CARD:Card = c.controller.grave.findBySlug( BROTHER );
					if ( CARD == null ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					const FIELD:CreatureField = findTargetField();
					if ( FIELD == null ) return;
					if ( !FIELD.isEmpty ) return;
					const CARD:Card = c.controller.grave.findBySlug( BROTHER );
					if ( CARD == null ) return;
					TempDatabaseUtils.doResurrectCreature( CARD, FIELD, c );
				}
				function findTargetField():CreatureField {
					return c.controller.samesideCreatureFieldAtIndex( c.indexedField.index + FDELTA );
				}
			}
			
			F[ "hired_mage" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_END );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer() && c.controller.mana.current <= 0;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "darkassasin3" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c == p.getAttacker() ) return true;
					if ( c.indexedField.opposingCreature == p.getAttacker() ) return true;
					return false;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "darkassasin2" ] = 
			F[ "darkassasin1" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "immortal2" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watchAll();
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.hand.cardsCount == 0;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( c, c.controller );
				}
			}
			
			F[ "immortal1" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.LEAVE_PLAY_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.creatureCount == 0;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutInHand( c, c.controller );
				}
			}
			
			F[ "deathdraw" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.GRAVEYARD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDraw( c.controller, c.primalData.getVarInt( 0 ) );
				}
			}
			
			F[ "directrager" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getSourceCard().controller;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller.opponent, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "man_of_honor" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.cannotAttack = true;
				buff.isActive = 
				function( c:Card ):Boolean {
					return c.isInPlay && c.indexedField.opposingCreature == null;
				}
			}
			
			F[ "unbreakable" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					if ( c.indexedField == null ) return;
					if ( c.indexedField.samesideCreatureToTheLeft == null ) return;
					if ( c.indexedField.samesideCreatureToTheRight == null ) return;
					p.abort();
				}
			}
			
			F[ "witchbetsy" ] = 
			function( c:Card ):void
			{
				c.propsC.summonConditionManual = 
				c.propsC.summonConditionAutomatic = 
				function( f:CreatureField ):Boolean {
					return c.controller.creatureCount == 0;
				}
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard() && c.indexedField.opposingCreature != null;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var foe:Card = c.indexedField.opposingCreature;
					if ( foe == null ) return;
					foe.statusC.setLifeLinks( c );
				}
			}
			
			F[ "finalrage" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false )
				buff.powerOffset = c.primalData.getVarInt( 0 );
				buff.isActive = 
				function( cc:Card ):Boolean {
					return c.controller.lifePoints <= c.primalData.getVarInt( 1 );
				}
			}
			
			F[ "haggler" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller.deck.topCard == null ) return false;
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var dc:Card = c.controller.deck.topCard;
					if ( dc == null ) return;
					dc.faceDown = false;
					if ( !dc.isTrap ) return;
					p.abort();
				}
			}
			
			F[ "drawhealer" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DRAW_CARD_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doHeal( c.controller, c.primalData.getVarInt( 0 ) );
				}
			}
			
			F[ "deckstructor1" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ENTER_GRAVE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.grave == p.getSourceCard().field;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doPutToGrave( c.controller.opponent.deck.topCard );
				}
			}
			
			F[ "battle_healer" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !TempDatabaseUtils.isInBattle( c, p ) ) return false;
					if ( c.indexedField.opposingCreature.statusC.realPowerValue
						 <= c.statusC.realPowerValue ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doHeal( c.controller,
						c.indexedField.opposingCreature.statusC.realPowerValue
						- c.statusC.realPowerValue );
				}
			}
			
			F[ "fairturnhealer" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doHeal( p.getPlayer(), c.primalData.getVarInt( 0 ) );
				}
			}
			
			F[ "powerhealer2" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller != p.getPlayer() ) return false;
					if ( c.indexedField.opposingCreature == null ) return false;
					if ( c.indexedField.opposingCreature.faceDown ) return false;
					if ( c.indexedField.opposingCreature.propsC.isGrand ) return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doHeal( c.controller, 
						c.indexedField.opposingCreature.statusC.realPowerValue );
				}
			}
			
			F[ "fairhealer" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doHeal( c.controller, c.primalData.getVarInt( 0 ) );
					TempDatabaseUtils.doHeal( c.controller.opponent, c.primalData.getVarInt( 0 ) );
				}
			}
			
			F[ "turnhealer" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller == p.getPlayer();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doHeal( c.controller, c.primalData.getVarInt( 0 ) );
				}
			}
			
			F[ "harshfred" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SPEND_MANA_COMPLETE );
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( p.getPlayer(), c.primalData.getVarInt( 0 ), c );
				}
			}
			
			F[ "drawson2" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker() && c.controller.opponent.deck.cardsCount >= c.primalData.getVarInt( 0 );
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDraw( c.controller.opponent, c.primalData.getVarInt( 0 ) );
				}
			}
			
			F[ "drawson1" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.ATTACK );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getAttacker();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDraw( c.controller.opponent, c.primalData.getVarInt( 0 ) );
				}
			}
			
			F[ "grand_bloodhaggler" ] = 
			function( c:Card ):void
			{
				const LP_PRICE:uint = c.primalData.getVarInt( 0 );
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard() && c.controller.lifePoints > LP_PRICE;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doDealDirectDamage( c.controller, LP_PRICE, c );
				}
			}
			
			F[ "bloodhaggler" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard() && p.getDeathIsFromCombat();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					p.abort();
					TempDatabaseUtils.doDealDirectDamage( c.controller, c.primalData.getVarInt( 0 ), c );
				}
			}
			
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
					if ( c.indexedField.opposingCreature.statusC.realPowerValue
						>= c.statusC.realPowerValue ) return false;
					
					if ( c == p.getAttacker() ) return true;
					if ( c.indexedField.opposingCreature == p.getAttacker() ) return true;
					return false;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller,
						c.statusC.realPowerValue - 
						c.indexedField.opposingCreature.statusC.realPowerValue,
						c );
				}
			}
			
			F[ "fateup" ] = 
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
					TempDatabaseUtils.doDraw( c.controller, c.primalData.getVarInt( 0 ) );
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
					TempDatabaseUtils.doKill( c, c );
				}
			}
			
			F[ "traitor" ] = //////
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.TURN_START );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.controller != p.getPlayer() ) return false;
					if ( c.controller.lifePoints >= c.controller.opponent.lifePoints ) return false;
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
				const BROTHER:String = c.primalData.getVarSlug( 0 );
				
				var f:Function =
				function ():void {
					var cc:Card = c.controller.grave.findBySlug( BROTHER );
					if ( cc != null )
						TempDatabaseUtils.doPutInHand( cc, c.controller );
				}
				
				if ( c.slug == "marco" )
					c.propsC.onSafeFlipFunc = f;
				else
					c.propsC.onCombatFlipFunc = f;
			}
			
			F[ "zig" ] = 
			F[ "zag" ] = 
			function( c:Card ):void
			{
				const BROTHER:String = c.primalData.getVarSlug( 0 );
				
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
				const BROTHER:String = c.primalData.getVarSlug( 0 );
				
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
			
			F[ "forbidden1" ] = 
			F[ "forbidden2" ] = 
			F[ "forbidden3" ] = 
			F[ "forbidden4" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.powerOffset = c.primalData.getVarInt( 2 );
				buff.isActive = 
				function( cc:Card ):Boolean {
					return c.controller.fieldsC.countCreaturesThat( checkBro ) >= 4;
				}
				function checkBro( c:Card ):Boolean {
					return c.slug.indexOf( c.primalData.getVarString( 0 ) ) > -1;
				}
			}
			
			F[ "8ball_1" ] = 
			F[ "8ball_2" ] = 
			F[ "8ball_3" ] = 
			F[ "8ball_4" ] = 
			function( c:Card ):void
			{
				const GROUP:String = c.primalData.getVarString( 0 );
				
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
						TempDatabaseUtils.doSummonFromDeckOrHand( 
							cc, c.history.lastIndexedField as CreatureField );
				}
			}
			
			//}
			
			///
			
			//{ NOT WORKING, MUST FIX
			F[ "reflipper" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getSourceCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
				}
			}
			
			//}
			
			/// /// /// // ///
			initialized = true;
			
			var len:int;
			for ( var o:* in F ) len++;
			trace ( len + " card behaviours initialized." );
			/// /// /// // ///
		}
		
		//
		
		static private function addHaste( c:Card ):void 
		{
			var special:SpecialEffect;
			special = c.propsC.addTriggered();
			special.allowIn( CardLotType.CREATURE_FIELD );
			special.watch( GameplayProcess.SUMMON_COMPLETE );
			special.funcCondition =
			function( p:GameplayProcess ):Boolean {
				return c == p.getSourceCard();
			}
			special.funcActivate =
			function( p:GameplayProcess ):void {
				p.getSourceCard().statusC.hasSummonExhaustion = false;
			}
		}
		
		static private function registerGlobalBuffWhileInPlay( c:Card, gb:GlobalBuff ):void 
		{
			var special:SpecialEffect;
			
			special = c.propsC.addTriggered();
			special.allowIn( CardLotType.CREATURE_FIELD );
			special.watch( GameplayProcess.SUMMON_COMPLETE );
			special.funcCondition =
			function( p:GameplayProcess ):Boolean {
				return c == p.getSourceCard();
			}
			special.funcActivate =
			function( p:GameplayProcess ):void {
				c.registerGlobalBuff( gb );
			}
			
			special = c.propsC.addTriggered();
			special.allowIn( CardLotType.CREATURE_FIELD );
			special.watch( GameplayProcess.LEAVE_PLAY_COMPLETE );
			special.funcCondition =
			function( p:GameplayProcess ):Boolean {
				return c == p.getSourceCard();
			}
			special.funcActivate =
			function( p:GameplayProcess ):void {
				c.removeGlobalBuff( gb );
			}
		}
		
		//
		
		static private function isInvolvedInBattle( c:Card, p:GameplayProcess ):Boolean
		{
			if ( !c.isInPlay ) return false;
			if ( c == p.getAttacker() ) return true;
			if ( c.indexedField.opposingCreature == p.getAttacker() ) return true;
			return false;
		}
		
		static private function getTopCardBasePower( list:Field ):int
		{
			if ( list.isEmpty ) return 0;
			if ( !list.topCard.isCreature ) return 0;
			return list.topCard.statusC.basePowerValue;
		}
		
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
				throw new Error( "No CPD for " + data );
			
			// PRIMAL
			c.primalData = cpd;
			if ( cpd.type == CardPrimalData.TYPE_TRAP_NORMAL || cpd.type == CardPrimalData.TYPE_TRAP_PERSISTENT )
			{
				TempDatabaseUtils.setToTrap( c );
				c.propsT.persistent = cpd.type == CardPrimalData.TYPE_TRAP_PERSISTENT;
				c.propsT.effect = new TrapEffect( c.propsT.persistent );
			}
			else
			{
				TempDatabaseUtils.setToCreature( c );
				c.propsC.isFlippable = cpd.type == CardPrimalData.TYPE_CREATURE_FLIPPABLE;
				c.propsC.isGrand = cpd.type == CardPrimalData.TYPE_CREATURE_GRAND;
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
			
			c.props.isToken = c.slug == "token1";
			
			//
			c.initialize();
			
			CONFIG::heavytest
			{ c.heavyTest() }
			
			return c;
		}
		
		//
		private static function chance( value:Number ):Boolean { return Math.random() < value }
	}
}