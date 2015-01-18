package duel.controllers 
{
	import chimichanga.debug.logging.error;
	import duel.cards.Card;
	import duel.Game;
	import duel.players.Player;
	import duel.table.IndexedField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class RemotePlayerController extends PlayerController 
	{
		private static const COOLDOWN:Number =  .200; // 1.0 .1
		private static const PINGTIME:Number = 1.500; // 1.0 .1
		
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
			if ( !jugglerGui.isIdle ) return;
			if ( !jugglerStrict.isIdle ) return;
			if ( !game.processes.isIdle ) return;
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
				case "summon" :
					c = player.hand.findByUid( action[1] );
					performActionSummon( c, player.fieldsC.getAt( action[2] ) );
					break;
				case "trapset" :
					c = player.hand.findByUid( action[1] );
					performActionTrapSet( c, player.fieldsT.getAt( action[2] ) );
					break;
				case "safeflip" :
					c = player.fieldsC.getAt( action[1] ).topCard;
					performActionSafeFlip( c );
					break;
				case "relocate" :
					c = player.fieldsC.getAt( action[1] ).topCard;
					performActionRelocation( c, player.fieldsC.getAt( action[2] ) );
					break;
				case "attack" :
					c = player.fieldsC.getAt( action[1] ).topCard;
					performActionAttack( c );
					break;
				case "draw":
					performActionDraw();
					break;
				case "turnend":
					performActionTurnEnd();
					break;
				case "surrender":
					performActionSurrender();
					break;
				default:
					err( "could not recognize action " + action );
			}
		}
		
		private function err( msg:String ):void
		{
			error( msg );
			Game.log( "ERROR: "+msg );
		}
		
		override public function onTurnStart():void
		{ }
		
	}

}