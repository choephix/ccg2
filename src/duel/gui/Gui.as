package duel.gui
{
	import duel.GameSprite;
	import duel.Player;
	import starling.display.Button;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Gui extends GameSprite
	{
		private var t1:AnimatedTextField;
		private var t2:AnimatedTextField;
		
		public var button1:Button;
		public var button2:Button;
		public var button3:Button;
		public var button4:Button;
		
		public function Gui()
		{
			const INSET:Number = 10;
			
			t1 = new AnimatedTextField( 0, 0, ( game.p1.name + ": " + AnimatedTextField.DEFAULT_MARKER ), "Impact", 50 );
			addChild( t1 );
			t1.x = INSET;
			t1.width = App.W - INSET * 2.0;
			t1.height = App.H;
			t1.color = 0xFFEE22;
			t1.hAlign = "right";
			t1.vAlign = "bottom";
			t1.touchable = false;
			
			
			t2 = new AnimatedTextField( 0, 0, ( game.p2.name + ": " + AnimatedTextField.DEFAULT_MARKER ), "Impact", 50 );
			addChild( t2 );
			t2.x = INSET;
			t2.width = App.W - INSET * 2.0;
			t2.height = App.H;
			t2.color = 0xFFEE22;
			t2.hAlign = "left";
			t2.vAlign = "top";
			t2.touchable = false;
			
			button1 = new Button( assets.getTexture( "btn" ), "END TURN" );
			button1.fontColor = 0x53449B;
			button1.fontBold = true;
			button1.x = App.W - button1.width - 10;
			button1.y = 10;
			button1.addEventListener( Event.TRIGGERED, game.endTurn );
			addChild( button1 );
			
			button2 = new Button( assets.getTexture( "btn" ), "RESTART" );
			button2.fontColor = 0x53449B;
			button2.fontBold = true;
			button2.x = App.W - button1.width - 10;
			button2.y = button1.bounds.bottom + 10;
			button2.addEventListener( Event.TRIGGERED, game.endGame );
			addChild( button2 );
			
			button3 = new Button( assets.getTexture( "btn" ), "ATTACK" );
			button3.fontColor = 0xFFFF00;
			button3.fontBold = true;
			button3.x = App.W - button1.width - 10;
			button3.y = button2.bounds.bottom + 10;
			button3.addEventListener( Event.TRIGGERED, btn3f );
			function btn3f():void
			{
				game.performCardAttack( game.selectedCard );
				game.selectCard( null );
			}
			addChild( button3 );
			
			button4 = new Button( assets.getTexture( "btn" ), "FLIP" );
			button4.fontColor = 0xFFFF00;
			button4.fontBold = true;
			button4.x = App.W - button1.width - 10;
			button4.y = button3.bounds.bottom + 10;
			button4.addEventListener( Event.TRIGGERED, btn4f );
			function btn4f():void
			{
				game.performSafeFlip( game.selectedCard );
			}
			addChild( button4 );
		}
		
		public function advanceTime( time:Number ):void
		{
			updateTf( t1, game.p1, time );
			updateTf( t2, game.p2, time );
			
			button3.visible = 
				game.interactable && 
				game.selectedCard != null && 
				game.selectedCard.type.isCreature && 
				game.selectedCard.canAttack;
			
			button4.visible = 
				game.interactable && 
				game.selectedCard != null && 
				game.selectedCard.type.isCreature && 
				game.selectedCard.faceDown &&
				game.selectedCard.exhausted == false;
		}
		
		private function updateTf( t:AnimatedTextField, p:Player, time:Number ):void
		{
			t.targetValue = p.lp;
			t.color = p == game.currentPlayer ? 0xFFEE22 : 0xF37618;
			t.advanceTime( time );
		}
		
		//
	}
}