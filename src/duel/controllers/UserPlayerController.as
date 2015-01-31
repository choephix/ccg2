package duel.controllers
{
	import duel.cards.Card;
	import duel.GameUpdatable;
	import duel.gui.GuiEvents;
	import duel.players.Player;
	import duel.processes.GameplayProcess;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.TrapField;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class UserPlayerController extends GameUpdatable
	{
		public var selection:SelectionManager;
		
		protected var faq:PlayerControllerFAQ;
		protected var player:Player;
		
		private static var a__:PlayerAction = new PlayerAction();
		
		public function UserPlayerController( player:Player ) 
		{
			this.player = player;
			this.faq = new PlayerControllerFAQ();
		}
		
		// // // // //
		// GENERALE //
		// // // // //
		
		override protected function initialize():void 
		{
			super.initialize();
			
			selection = new SelectionManager();
			selection.initialize( player, faq );
			selection.ctrl = this;
			
			game.guiEvents.addEventListener( GuiEvents.CARD_CLICK, onClickCard );
			game.guiEvents.addEventListener( GuiEvents.FIELD_CLICK, onClickField);
		}
		
		private function onClickCard( e:Event ):void
		{
			if ( !game.currentPlayer.controllable )
			{
				game.gui.pMsg( "It's the enemy's turn." );
				return;
			}
			
			var c:Card = e.data as Card;
			
			if ( c.isInHand )
			{
				if ( !selection.contextInHand.isSelectable( c ) )
					return;
				selection.contextInHand.onSelected( c );
				return;
			}
			
			// MAYBE FIELD?
			var f:Field = c.field;
			if ( f == null )
				return;
			if ( !selection.contextOnField.isSelectable( f ) )
				return;
			selection.contextOnField.onSelected( f );
		}
		
		private function onClickField( e:Event ):void
		{
			if ( !game.currentPlayer.controllable )
			{
				game.gui.pMsg( "It's the enemy's turn." );
				return;
			}
			
			var f:Field = e.data as Field;
			
			if ( !selection.contextOnField.isSelectable( f ) )
				return;
			selection.contextOnField.onSelected( f );
		}
		
		// POINTER HOVER UPDATE
		
		// OTHER
		
		public function get active():Boolean
		{ return game.currentPlayer == player }
		
		// // // // //
		// INCOMING //
		// // // // //
		
		override public function advanceTime( time:Number ):void
		{
			super.advanceTime( time );
			
			if ( !active ) return;
			
			selection.advanceTime( time );
			
			CONFIG::sandbox 
			{ game.gui.pMsg( selection.contextOnField.name + " " + selection.selectedCard, false ) }
		}
		
		override public function onProcessUpdateOrComplete( p:GameplayProcess ):void
		{
			super.onProcessUpdateOrComplete( p );
			
			if ( !active ) return;
			
			//selection.update();
		}
		
		// // // // //
		// OUTGOING //
		// // // // //
		
		public function performActionDraw():void 
		{ performAction( a__.setTo( PlayerActionType.DRAW ) ) }
		
		public function performActionSummon( c:Card, field:CreatureField ):void
		{ performAction( a__.setTo( PlayerActionType.SUMMON_CREATURE, c, field ) ) }
		
		public function performActionTrapSet( c:Card, field:TrapField ):void
		{ performAction( a__.setTo( PlayerActionType.SET_TRAP, c, field ) ) }
		
		public function performActionAttack( c:Card ):void
		{ performAction( a__.setTo( PlayerActionType.ATTACK, c ) ) }
		
		public function performActionRelocation( c:Card, field:CreatureField ):void
		{ performAction( a__.setTo( PlayerActionType.RELOCATE, c, field ) ) }
		
		public function performActionSafeFlip( c:Card ):void
		{ performAction( a__.setTo( PlayerActionType.SAFEFLIP, c ) ) }
		
		public function performActionTurnEnd():void
		{ performAction( a__.setTo( PlayerActionType.END_TURN ) ) }
		
		public function performActionSurrender():void
		{ performAction( a__.setTo( PlayerActionType.SURRENDER ) ) }
		
		public function performAction( a:PlayerAction ):void
		{ player.performAction( a ) }
		
		// // // // //
		// BULLSHIT //
		// // // // //
		
		private function log( ...rest ):void
		{ trace.apply( null, rest ) }
	}
}