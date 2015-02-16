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
			
			F[ "banana_a" ] = function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.HAND );
				special.watch( GameplayProcess.DRAW_CARD_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getDrawnCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var cc:Card = c.controller.deck.findBySlug( "banana_b" );
					if ( cc != null )
						TempDatabaseUtils.doPutInHand( cc, c.controller );
				}
			}
			
			F[ "banana_b" ] = function( c:Card ):void
			{
				var special:SpecialEffect;
				special = c.propsC.addTriggered();
				special.allowIn( CardLotType.HAND );
				special.watch( GameplayProcess.DRAW_CARD_COMPLETE );
				special.funcCondition =
				function( p:GameplayProcess ):Boolean {
					return c == p.getDrawnCard();
				}
				special.funcActivate =
				function( p:GameplayProcess ):void {
					var cc:Card = c.controller.deck.findBySlug( "banana_1" );
					if ( cc != null )
						TempDatabaseUtils.doPutInHand( cc, c.controller );
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
			
			c.initialize();
			return c;
		}
		
		//
		private static function chance( value:Number ):Boolean { return Math.random() < value }
	}

}