package duel.cards
{
	import chimichanga.debug.logging.error;
	import duel.cards.buffs.Buff;
	import duel.cards.buffs.GlobalBuff;
	import duel.cards.Card;
	import duel.cards.properties.cardprops;
	import duel.cards.temp_database.TempDatabaseUtils;
	import duel.otherlogic.OngoingEffect;
	import duel.otherlogic.SpecialEffect;
	import duel.players.Player;
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
			F[ "___test___" ] = 
			function( c:Card ):void
			{
				var special:SpecialEffect;
				
				/// SPECIAL 1
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
				
				/// SPECIAL 2
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c.controller.opponent == p.getSourceCard().controller;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					c.propsC.basePower -= 1;
				}
				
				/// SPECIAL 3
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
			}
			
			/// /// /// /// // /// /// /// ///
			/// /// /// TEST SPACE /// /// ///
			/// /// ///            /// /// ///
			
			F[ "grandlock" ] = 
			function( c:Card ):void
			{
				c.propsT.persistent = true;
				
				c.propsT.effect.watchForActivation( GameplayProcess.TRIBUTE_CREATURE_COMPLETE );
				c.propsT.effect.funcActivateCondition =
				function( p:GameplayProcess ):Boolean {
					if ( !p.isTributeForGrand() ) return false;
					return c.indexedField.index == p.getSourceCard().history.lastIndexedField.index;
				}
				c.propsT.effect.funcActivate =
				function( p:GameplayProcess ):void {
					p.getSourceCard().history.lastIndexedField.addLock();
				}
				
				c.propsT.effect.watchForDeactivation( GameplayProcess.TURN_END );
				c.propsT.effect.funcDeactivateCondition =
				function( p:GameplayProcess ):Boolean {
					return true;
				}
				c.propsT.effect.funcDeactivate =
				function( p:GameplayProcess ):void {
					p.getSourceCard().history.lastIndexedField.removeLock();
				}
			}
			
			/// /// ///            /// /// ///
			/// /// /// TEST SPACE /// /// ///
			/// /// /// /// // /// /// /// ///
			
			///
			
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
						if ( cc.statusC.realPowerValue >= c.statusC.realPowerValue ) return;
						TempDatabaseUtils.doKill( p.fieldsC.getAt( i ).topCard, c );
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
						if ( cc.statusC.realPowerValue >= c.statusC.realPowerValue ) return;
						TempDatabaseUtils.doKill( p.fieldsC.getAt( i ).topCard, c );
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
						TempDatabaseUtils.doKill( c.controller.fieldsC.getAt( i ).topCard, c );
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
					return c != p.getSourceCard();
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
					c.statusC.hasSummonExhaustion = false;
				}
				
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
					c.statusC.hasSummonExhaustion = false;
				}
				
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
					c.statusC.hasSummonExhaustion = false;
				}
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
					c.statusC.hasSummonExhaustion = false;
				}
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
					c.statusC.hasSummonExhaustion = false;
				}
				
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
			
			F[ "devouerer" ] = 
			function( c:Card ):void
			{
				var delta:int;
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.powerOffset = 0;
				
				var special:SpecialEffect;
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getDeathCauser();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					delta = p.getSourceCard().statusC.realPowerValue;
				}
				
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.DIE_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getDeathCauser();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					buff.powerOffset += delta;
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
					buff.powerOffset = 0;
				}
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
				var doCheck:Boolean;
				
				var ongoing:OngoingEffect;
				ongoing = c.propsC.addOngoing();
				ongoing.funcCondition =
				function( p:GameplayProcess ):Boolean
				{
					return doCheck;
				}
				ongoing.funcUpdate =
				function( p:GameplayProcess ):void
				{
					if ( !doCheck )
					{
						if ( p.name == GameplayProcess.SUMMON_COMPLETE && p.getSourceCard() == c )
							doCheck = true;
						else
							return;
					}
					if ( c.controller.grave.findBySlug( GRAND ) == null )
					{
						doCheck = false;
						TempDatabaseUtils.doKill( c, c );
					}
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
				function():Boolean {
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
					c.statusC.hasSummonExhaustion = false;
				}
				
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
			
			F[ "stunner" ] = ///////
			function( c:Card ):void
			{
				var b:Buff = new Buff( true );
				b.cannotAttack = true;
				b.cannotRelocate = true;
				b.expiryCondition =
				function( p:GameplayProcess ):Boolean {
					return p.name == GameplayProcess.TURN_END;
				}
				
				c.propsC.onCombatFlipFunc =
				function():void {
					if ( c.indexedField.opposingCreature == null )
						return;
					c.indexedField.opposingCreature.statusC.addBuff( b );
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
				function():Boolean {
					return c.controller.creatureCount == 0;
				}
			}
			
			F[ "compromiser2" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.skipTribute = true;
				buff.isActive =
				function():Boolean {
					return c.controller.hand.cardsCount == 1;
				}
			}
			
			F[ "compromiser3" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.skipTribute = true;
				buff.isActive =
				function():Boolean {
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
					c.statusC.hasSummonExhaustion = false;
				}
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
				
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.CREATURE_FIELD );
				special.watch( GameplayProcess.SUMMON_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c != p.getSourceCard() ) return false;
					
					const FIELD:CreatureField = c.slug == "jack" ? c.fieldC.adjacentRight : c.fieldC.adjacentLeft;
					if ( !FIELD.isEmpty ) return false;
					
					const CARD:Card = c.controller.grave.findBySlug( BROTHER );
					if ( CARD == null )
						return false;
					return true;
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					const FIELD:CreatureField = c.slug == "jack" ? c.fieldC.adjacentRight : c.fieldC.adjacentLeft;
					TempDatabaseUtils.doResurrectCreature( c.controller.grave.findBySlug( BROTHER ), FIELD, c );
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
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == null;
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
					var cf:CreatureField = c.indexedField as CreatureField;
					if ( cf == null ) return;
					if ( cf.adjacentCreatureLeft == null ) return;
					if ( cf.adjacentCreatureRight == null ) return;
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
				function( p:GameplayProcess ):Boolean {
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
			
			F[ "forsaken1" ] = 
			F[ "forsaken2" ] = 
			F[ "forsaken3" ] = 
			F[ "forsaken4" ] = 
			function( c:Card ):void
			{
				var buff:Buff = c.statusC.addNewBuff( false );
				buff.powerOffset = c.primalData.getVarInt( 2 );
				buff.isActive = 
				function():Boolean {
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
			
			///
			
			F[ "summon2atk" ] = 
			function( c:Card ):void
			{
				c.propsT.effect.watchForActivation( GameplayProcess.SUMMON_COMPLETE );
				c.propsT.effect.funcActivateCondition =
				function( p:GameplayProcess ):Boolean {
					return c.indexedField.opposingCreature == p.getSourceCard();
				}
				c.propsT.effect.funcActivate =
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
				c.propsT.effect.watchForActivation( GameplayProcess.ATTACK );
				c.propsT.effect.funcActivateCondition =
				function( p:GameplayProcess ):Boolean {
					if ( c.indexedField.opposingCreature != p.getAttacker() ) return false;
					if ( c.indexedField.samesideCreature != null ) return false;
					return true;
				}
				c.propsT.effect.funcActivate =
				function( p:GameplayProcess ):void {
					TempDatabaseUtils.doDealDirectDamage( c.controller.opponent, c.primalData.getVarInt( 0 ), c );
				}
			}
			
			///
			
			// NOT WORKING, MUST FIX
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
			
			// DEV
			F[ "___kami___" ] = 
			function( c:Card ):void
			{
				c.cost = 0;
				
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
				}
				
				var ongoing:OngoingEffect;
				ongoing = c.propsC.addOngoing();
				ongoing.funcUpdate =
				function( p:GameplayProcess ):void {
					c.propsC.basePower = c.controller.mana.current * 5;
					c.statusC.actionsAttack = 0;
					c.statusC.actionsRelocate = 0;
					c.statusC.hasSummonExhaustion = false;
				}
			}
			
			/// /// /// // ///
			initialized = true;
			/// /// /// // ///
		}
		
		//
		
		static public function registerGlobalBuffWhileInPlay( c:Card, gb:GlobalBuff ):void 
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
				TempDatabaseUtils.setToTrap( c );
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
			
			//
			c.initialize();
			return c;
		}
		
		//
		private static function chance( value:Number ):Boolean { return Math.random() < value }
	}

}