package duel.controllers 
{
	import chimichanga.debug.logging.error;
	import duel.cards.Card;
	import duel.players.Player;
	import duel.table.CreatureField;
	import duel.table.TrapField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class RemotePlayerController extends PlayerController 
	{
		public static const COOLDOWN:Number = .100; // 1.0 .1
		
		private var actionQueue:Array = 
			[ 
				//"attack:0",
				//"summon:0:0",
				//"trapset:0:0",
				"turnend"
			];
		private var cooldown:Number = COOLDOWN;
		
		public function RemotePlayerController( p:Player ) { super( p ) }
		
		override public function initialize():void 
		{}
		
		override public function advanceTime( time:Number ):void
		{
			if ( !active ) return;
			if ( !jugglerStrict.isIdle ) return;
			if ( !game.processes.isIdle ) return;
			
			if ( cooldown > .0 )
			{
				cooldown -= time;
			}
			else
			{
				doNextAction();
				cooldown = COOLDOWN;
			}
		}
		
		private function doNextAction():void 
		{
			var action:Array = String( actionQueue.shift() ).split( ":" );
			var c:Card;
			
			trace( "Will do action " + action );
			
			switch( action[0] )
			{
				case "attack" :
					c = player.fieldsC.getAt( action[1] ).topCard;
					if ( c == null || ( faq.canCreatureAttack( c, true ) != null ) )
					{
						error( "Card " + c + " cannot attack" );
						return;
					}
					performActionAttack( c );
					break;
				case "summon" :
					if ( player.hand.findByUid( action[1] ) == null )
					{
						error( "Card#" + action[1] + " not in " + player + "'s hand - " + player.hand );
						return;
					}
					performActionSummon( player.hand.findByUid( action[1] ), player.fieldsC.getAt( action[2] ) );
					break;
				case "trapset" :
					if ( player.hand.findByUid( action[1] ) == null )
					{
						error( "Card#" + action[1] + " not in " + player + "'s hand - " + player.hand );
						return;
					}
					performActionTrapSet( player.hand.findByUid( action[1] ), player.fieldsT.getAt( action[2] ) );
					break;
				case "draw":
					performActionDraw();
					break;
				case "turnend":
					performActionTurnEnd();
					break;
			}
		}
		
		public function updateActionQueue():void
		{
			actionQueue.length = 0;
			
			var mana:int = player.mana.current;
			var i:int = 0;
			var j:int = 0;
			var c:Card;
			
			var blacklistC:Array = [];
			var blacklistT:Array = [];
			
			for ( i = 0; i < player.hand.cardsCount && mana > 0; i++ ) 
			{
				c = player.hand.getCardAt( i );
				
				if ( c.type.isCreature )
				{
					for ( j = 0; j < player.fieldsC.count; j++ ) 
						if ( faq.canSummonCreatureOn( c, player.fieldsC.getAt( j ), true ) == null )
						{
							if ( blacklistC.indexOf( j ) > -1 ) continue;
							actionQueue.push( "summon" + ":" + c.uid + ":" + j );
							blacklistC.push( j );
							mana -= c.cost;
							break;
						}
				}
				else
				if ( c.type.isTrap )
				{
					for ( j = 0; j < player.fieldsT.count; j++ ) 
						if ( faq.canSetTrapOn( c, player.fieldsT.getAt( j ), true ) == null )
						{
							if ( blacklistT.indexOf( j ) > -1 ) continue;
							actionQueue.push( "trapset" + ":" + c.uid + ":" + j );
							blacklistT.push( j );
							mana -= c.cost;
							break;
						}
				}
			}
			
			while ( mana > 0 )
			{
				actionQueue.push( "draw" );
				mana--;
			}
			
			for ( j = 0; j < player.fieldsC.count; j++ ) 
			{
				c = player.fieldsC.getAt( j ).topCard;
				if ( c == null ) continue;
				if ( faq.canCreatureAttack( c, true ) != null ) continue;
				actionQueue.push( "attack" + ":" + j );
			}
						
			actionQueue.push( "turnend" );
			
			trace ( "\n\nNEW ACTION QUEUE FOR " + player + "\n" + actionQueue.join("\n") );
		}
		
		override public function onTurnStart():void
		{ updateActionQueue() }
		
	}

}