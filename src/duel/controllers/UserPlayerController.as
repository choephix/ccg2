package duel.controllers
{
	import duel.cards.Card;
	import duel.cards.CommonCardQuestions;
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
				return;
			
			var t:Touch = e.getTouch( game );
			
			if ( t == null )
				return;
			
			var i:int;
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
		
		override public function onProcessAdvance( p:Process ):void
		{}
		
		// // // // //
		// OUTGOING //
		// // // // //
		
		override public function performActionSummon( c:Card, field:CreatureField ):void
		{
			selection.selectCard( null );
			super.performActionSummon( c, field );
		}
		
		override public function performActionTrapSet( c:Card, field:TrapField ):void
		{
			selection.selectCard( null );
			super.performActionTrapSet( c, field );
		}
		
		override public function performActionAttack( c:Card ):void
		{
			selection.selectCard( null );
			super.performActionAttack( c );
		}
		
		override public function performActionRelocation( c:Card, field:CreatureField ):void
		{
			selection.selectCard( null );
			super.performActionRelocation( c, field );
		}
		
		override public function performActionSafeFlip( c:Card ):void
		{
			selection.selectCard( null );
			super.performActionSafeFlip( c );
		}
		
		override public function performActionDraw():void
		{
			selection.selectCard( null );
			super.performActionDraw();
		}
		
		override public function performActionTurnEnd():void
		{
			selection.selectCard( null );
			super.performActionTurnEnd();
		}
		
		override public function performActionSurrender():void
		{
			selection.selectCard( null );
			super.performActionSurrender();
		}
		
		// // // // //
		// BULLSHIT //
		// // // // //
		
		private function log( ...rest ):void
		{ trace.apply( null, rest ) }
	}
}