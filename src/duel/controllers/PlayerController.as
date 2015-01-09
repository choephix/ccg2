package duel.controllers 
{
	import duel.cards.Card;
	import duel.GameEntity;
	import duel.players.Player;
	import duel.processes.Process;
	import duel.table.CreatureField;
	import duel.table.TrapField;
	import starling.errors.AbstractMethodError;
	/**
	 * ...
	 * @author choephix
	 */
	public class PlayerController extends GameEntity
	{
		private var _active:Boolean;
		
		protected var player:Player;
		
		public function PlayerController( player:Player ) 
		{ this.player = player }
		
		// // // // //
		// GENERALE //
		// // // // //
		
		public function initialize():void
		{ throw new AbstractMethodError() }
		
		// // // // //
		// INCOMING //
		// // // // //
		
		public function advanceTime( time:Number ):void
		{}
		
		public function onProcessUpdate():void
		{}
		
		// // // // //
		// OUTGOING //
		// // // // //
		
		public function performActionSummon( c:Card, field:CreatureField ):void
		{ game.performActionSummon( c, field ) }
		
		public function performActionTrapSet( c:Card, field:TrapField ):void
		{ game.performActionTrapSet( c, field ) }
		
		public function performActionAttack( c:Card ):void
		{ game.performActionAttack( c ) }
		
		public function performActionRelocation( c:Card, field:CreatureField ):void
		{ game.performActionRelocation( c, field ) }
		
		public function performActionSafeFlip( c:Card ):void
		{ game.performActionSafeFlip( c ) }
		
		public function performActionTurnEnd():void
		{ game.performActionTurnEnd() }
		
		public function performActionSurrender():void
		{ game.performActionSurrender() }
		
		public function performActionDraw():void 
		{ game.performActionDraw() }
		
		// // // // //
		// GENERAL2 //
		// // // // //
		
		public function get active():Boolean 
		{ return _active }
		
		public function set active(value:Boolean):void 
		{ _active = value }
	}
}