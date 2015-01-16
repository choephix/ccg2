package duel.controllers 
{
	import chimichanga.debug.logging.error;
	import duel.cards.Card;
	import duel.players.Player;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class RemotePlayerController extends PlayerController 
	{
		private static const COOLDOWN:Number =  .100; // 1.0 .1
		private static const PINGTIME:Number = 1.500; // 1.0 .1
		
		private var isBusy:Boolean;
		
		private var actionQueue:Array = [];
		private var cooldown:Number = COOLDOWN;
		private var pingTimeout:Number = PINGTIME;
		
		public function RemotePlayerController( p:Player ) { super( p ) }
		
		override public function initialize():void 
		{
		}
		
		override public function advanceTime( time:Number ):void
		{
			if ( !active ) return;
			if ( !jugglerStrict.isIdle ) return;
			if ( !game.processes.isIdle ) return;
			if ( isBusy ) return;
			if ( actionQueue.length == 0 ) return;
			
			if ( cooldown > .0 )
				cooldown -= time;
			else
			{
				doNextAction();
				cooldown = COOLDOWN;
			}
		}
		
		public function onMessage( msg:String ):void 
		{
			actionQueue.push.apply( null, msg.split("|") );
			trace( actionQueue );
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
		
		override public function onTurnStart():void
		{ }
		
	}

}