package duel.controllers
{
	import duel.cards.Card;
	import duel.cards.CommonCardQuestions;
	import duel.Game;
	import duel.players.Player;
	import duel.processes.Process;
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
	public class UserPlayerController extends PlayerController
	{
		private var selection:SelectionManager;
		
		public var hoveredCard:Card;
		
		public function UserPlayerController( p:Player ) { super( p ) }
		
		// // // // //
		// GENERALE //
		// // // // //
		
		override public function initialize():void 
		{
			selection = new SelectionManager();
			selection.initialize( this, player );
			
			game.addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch( e:TouchEvent ):void {
			
			if ( !active )
			{
				hoverCard( null );
				return;
			}
			
			var t:Touch = e.getTouch( game );
			
			/// HOVER
			
			onTouchCheck_Hover( t );
			
			/// TAP
			
			if ( t == null )
				return;
			
			var interrupt:Boolean;
			
			if ( t.phase == TouchPhase.ENDED )
			{
				player.hand.forEachCard( checkHandCard );	if ( interrupt ) return;
				player.fieldsC.forEachField( checkField );	if ( interrupt ) return;
				player.fieldsT.forEachField( checkField );	if ( interrupt ) return;
				checkField( player.deck );					if ( interrupt ) return;
				checkField( player.grave);					if ( interrupt ) return;
				
				player.opponent.hand.forEachCard( checkHandCard );	if ( interrupt ) return;
				player.opponent.fieldsC.forEachField( checkField );	if ( interrupt ) return;
				player.opponent.fieldsT.forEachField( checkField );	if ( interrupt ) return;
				checkField( player.opponent.deck );					if ( interrupt ) return;
				checkField( player.opponent.grave);					if ( interrupt ) return;
				
				selection.selectCard( null );
			}
			
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
		
		override public function set active(value:Boolean):void 
		{
			super.active = value;
			if ( !value ) {
				hoverCard( null );
				selection.selectCard( null );
			}
		}
		
		// POINTER HOVER UPDATE
		
		private function onTouchCheck_Hover( t:Touch ):void {
			
			if ( t == null )
			{
				hoverCard( null );
				return;
			}
			
			if ( t.phase != TouchPhase.HOVER && t.phase != TouchPhase.MOVED )
			{
				hoverCard( null );
				return;
			}
			
			var interrupt:Boolean;
			
			/// HOVER
			
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
		
		// SELECTION
		
		public function updateSelectables():void
		{
		}
		
		// // // // //
		// INCOMING //
		// // // // //
		
		override public function advanceTime( time:Number ):void
		{
			if ( !active ) return;
			
			if ( game.gui.tDebug.text != selection.contextOnField.name )
				game.gui.tDebug.text = selection.contextOnField.name;
		}
		
		override public function update():void
		{
			if ( !active ) return;
			
			selection.onUpdate();
		}
		
		// // // // //
		// OUTGOING //
		// // // // //
		
		// // // // //
		// BULLSHIT //
		// // // // //
		
		private function log( ...rest ):void
		{ trace.apply( null, rest ) }
	}
}