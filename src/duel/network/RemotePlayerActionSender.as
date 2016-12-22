package duel.network 
{
	import chimichanga.debug.logging.error;
	import duel.controllers.PlayerAction;
	import duel.GameUpdatable;
	import duel.players.Player;
	import duel.players.PlayerEvent;
	
	public class RemotePlayerActionSender extends GameUpdatable
	{
		private var player:Player;
		public function RemotePlayerActionSender( player:Player ) {
			this.player = player;
			this.player.addEventListener( PlayerEvent.ACTION, onPlayerAction );
		}
		
		private function onPlayerAction( e:PlayerEvent ):void 
		{
			if ( player != e.currentTarget )
			{ error ( "dafuq" ); return; }
			
			sendMessage( PlayerActionSerializer.serialize( e.data as PlayerAction ) );
		}
		
		public function sendMessage( msg:String ):void
		{ game.remote.sendMyUserObject( msg ) }
	}
}