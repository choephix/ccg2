package duel.controllers
{
	import duel.cards.Card;
	import duel.GameUpdatable;
	import duel.players.Player;
	import duel.processes.GameplayProcess;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.TrapField;
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
		public var hoveredCard:Card;
		
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
			game.addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch( e:TouchEvent ):void {
			
			if ( !active )
				hoverCard( null );
			
			var t:Touch = e.getTouch( game );
			
			/// HOVER
			
			onTouchCheck_Hover( t );
			
			if ( t == null )
				return;
			
			/// BEGIN
			
			/// TAP
			
			onTouchCheck_Tap( t );
			
		}
		
		private function onTouchCheck_Tap( t:Touch ):void {
			
			if ( t == null )
				return;
			
			if ( t.phase != TouchPhase.ENDED )
				return;
			
			if ( !game.currentPlayer.controllable )
			{
				game.gui.pMsg( "It's the enemy's turn." );
				return;
			}
				
			var interrupt:Boolean;
			
			player.hand.forEachCard( checkHandCard );			if ( interrupt ) return;
			player.fieldsC.forEachField( checkField );			if ( interrupt ) return;
			player.fieldsT.forEachField( checkField );			if ( interrupt ) return;
			checkField( player.deck );							if ( interrupt ) return;
			checkField( player.grave);							if ( interrupt ) return;
			
			player.opponent.hand.forEachCard( checkHandCard );	if ( interrupt ) return;
			player.opponent.fieldsC.forEachField( checkField );	if ( interrupt ) return;
			player.opponent.fieldsT.forEachField( checkField );	if ( interrupt ) return;
			checkField( player.opponent.deck );					if ( interrupt ) return;
			checkField( player.opponent.grave);					if ( interrupt ) return;
			
			selection.selectCard( null );
			
			function checkHandCard( c:Card ):void
			{
				if ( !t.isTouching( c.sprite ) ) return;
				if ( !selection.contextInHand.isSelectable( c ) ) return;
				interrupt = true;
				selection.contextInHand.onSelected( c );
			}
			
			function checkField( f:Field ):void
			{
				if ( !t.isTouching( f.sprite ) ) return;
				if ( !selection.contextOnField.isSelectable( f ) ) return;
				interrupt = true;
				selection.contextOnField.onSelected( f );
			}
		}
		
		// POINTER HOVER UPDATE
		
		private function onTouchCheck_Hover( t:Touch ):void {
			
			if ( t == null )
			{
				hoverCard( null );
				return;
			}
			
			if ( hoveredCard != null && !t.isTouching( hoveredCard.sprite ) )
				hoverCard( null );
			
			var interrupt:Boolean;
			
			player.hand.forEachCard( hoverCheckHandCard );	if ( interrupt ) return;
			player.fieldsC.forEachField( hoverCheckField );	if ( interrupt ) return;
			player.fieldsT.forEachField( hoverCheckField );	if ( interrupt ) return;
			hoverCheckField( player.deck );					if ( interrupt ) return;
			hoverCheckField( player.grave);					if ( interrupt ) return;
			
			function hoverCheckHandCard( c:Card ):void
			{
				if ( !t.isTouching( c.sprite ) ) return;
				if ( !c.faceDown ) return;
				interrupt = true;
				hoverCard( c );
			}
			function hoverCheckField( f:Field ):void
			{
				if ( !t.isTouching( f.sprite ) ) return;
				
				var c:Card = f.topCard;
				if ( c == null ) return;
				if ( !c.faceDown ) return;
				interrupt = true;
				hoverCard( c );
			}
			
			hoverCard( null );
		}
		
		private function hoverCard( card:Card ):void
		{
			if ( hoveredCard == card )
				return;
			
			/// OLD HOVER
			if ( hoveredCard != null )
				hoveredCard.sprite.peekThrough = false;
			
			/// /// /// /// ///
			hoveredCard = card
			/// /// /// /// ///
			
			/// NEW HOVER
			if ( hoveredCard != null )
				hoveredCard.sprite.peekThrough = true;
		}
		
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
			
			selection.onProcessUpdate();
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