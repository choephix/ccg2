package duel.network 
{
	import duel.GameUpdatable;
	import duel.players.Player;
	/**
	 * ...
	 * @author choephix
	 */
	public class RemotePlayerActionReceiver extends GameUpdatable
	{
		private static const COOLDOWN:Number =  .200; // 1.0 .1
		private var cooldown:Number = COOLDOWN;
		private var actionQueue:Array = [];
		private var player:Player;
		
		public function RemotePlayerActionReceiver( player:Player ) { this.player = player }
		
		override public function advanceTime( time:Number ):void
		{
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
			trace( "+=\n" + actionQueue );
		}
		
		private function doNextAction():void 
		{
			player.performAction( PlayerActionSerializer.deserialize(
				String( actionQueue.shift() ), player ) );
		}
	}
}