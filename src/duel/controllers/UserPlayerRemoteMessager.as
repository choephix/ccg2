package duel.controllers 
{
	import duel.cards.Card;
	import duel.network.RemoteConnectionController;
	import duel.table.CreatureField;
	import duel.table.IndexedField;
	import duel.table.TrapField;
	/**
	 * ...
	 * @author choephix
	 */
	public class UserPlayerRemoteMessager 
	{
		private var remote:RemoteConnectionController;
		
		public function UserPlayerRemoteMessager( remote:RemoteConnectionController )
		{ this.remote = remote }
		
		public function sendMessage( msg:String ):void
		{
			remote.sendMyUserObject( msg );
		}
		
		/// /// /// /// /// /// /// /// /// /// /// /// /// /// /// 
		/// /// /// /// /// /// /// /// /// /// /// /// /// /// /// 
		/// /// /// /// /// /// /// /// /// /// /// /// /// /// /// 
		
		public function performActionSummon( c:Card, field:CreatureField ):void
		{
			sendMessage( "summon:" + serialize(c) + ":" + serialize(field) )
		}
		
		public function performActionTrapSet( c:Card, field:TrapField ):void
		{
			sendMessage( "trapset:" + serialize(c) + ":" + serialize(field) )
		}
		
		public function performActionAttack( c:Card ):void
		{
			sendMessage( "attack:" + serialize(c.indexedField) )
		}
		
		public function performActionRelocation( c:Card, field:CreatureField ):void
		{
			sendMessage( "relocate:" + serialize(c) + ":" + serialize(field) )
		}
		
		public function performActionSafeFlip( c:Card ):void
		{
			sendMessage( "safeflip:" + serialize(c) )
		}
		
		public function performActionTurnEnd():void
		{
			sendMessage( "turnend" )
		}
		
		public function performActionSurrender():void
		{
			sendMessage( "surrender" )
		}
		
		public function performActionDraw():void 
		{
			sendMessage( "draw" )
		}
		
		/// /// /// /// /// /// /// /// /// /// /// /// /// /// /// 
		
		public function serialize( o:* ):String
		{
			if ( o is Card )
				return o.uid.toString()
			if ( o is IndexedField )
				return o.index.toString()
			return "?"
		}
	}
}