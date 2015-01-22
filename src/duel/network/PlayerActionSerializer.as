package duel.network 
{
	import chimichanga.debug.logging.error;
	import duel.cards.Card;
	import duel.cards.status.CardStatus;
	import duel.controllers.PlayerAction;
	import duel.controllers.PlayerActionType;
	import duel.Game;
	import duel.players.Player;
	import duel.table.CreatureField;
	import duel.table.TrapField;
	/**
	 * ...
	 * @author choephix
	 */
	public class PlayerActionSerializer
	{
		private static var a:PlayerAction = new PlayerAction();
		
		public static function serialize( a:PlayerAction ):String
		{
			switch ( a.type )
			{
				case PlayerActionType.DRAW:
					return "draw";
				case PlayerActionType.SUMMON_CREATURE:
					return "summon:" + Card(a.args[0]).uid+ ":" + CreatureField(a.args[1]).index;
				case PlayerActionType.SET_TRAP:
					return "trapset:" + Card(a.args[0]).uid + ":" + TrapField(a.args[1]).index;
				case PlayerActionType.ATTACK:
					return "attack:" + Card(a.args[0]).uid;
				case PlayerActionType.RELOCATE:
					return "relocate:" + Card(a.args[0]).uid + ":" + CreatureField(a.args[1]).index;
				case PlayerActionType.SAFEFLIP:
					return "safeflip:" + Card(a.args[0]).uid;
				case PlayerActionType.END_TURN:
					return "turnend";
				case PlayerActionType.SURRENDER:
					return "surrender";
			}
			
			error( "could not serialize action " + a.type );
			return null;
		}
		
		public static function deserialize( s:String, player:Player ):PlayerAction
		{
			var action:Array = s.split( ":" );
			trace( "Will do action " + action );
			
			switch( action[0] )
			{
				case "summon" :
					return a.setTo(
							PlayerActionType.SUMMON_CREATURE, 
							getCard( action[1] ), 
							player.fieldsC.getAt( action[2] ) );
				case "trapset" :
					return a.setTo(
							PlayerActionType.SET_TRAP, 
							getCard( action[1] ), 
							player.fieldsT.getAt( action[2] ) );
				case "safeflip" :
					return a.setTo(
							PlayerActionType.SAFEFLIP, 
							getCard( action[1] ) );
				case "relocate" :
					return a.setTo(
							PlayerActionType.RELOCATE, 
							getCard( action[1] ), 
							player.fieldsC.getAt( action[2] ) );
				case "attack" :
					return a.setTo(
							PlayerActionType.ATTACK, 
							getCard( action[1] ) );
				case "draw":
					return a.setTo( PlayerActionType.DRAW );
				case "turnend":
					return a.setTo( PlayerActionType.END_TURN );
				case "surrender":
					return a.setTo( PlayerActionType.SURRENDER );
			}
			
			error( "could not deserialize action " + s );
			return null;
		}
		
		private static function getCard( uid:int ):Card
		{ return Game.current.findCardByUid( uid ) }
	}
}