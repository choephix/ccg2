package duel.gui
{
	import chimichanga.common.display.Sprite;
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
		
		public var buttonsContainer:Sprite;
		
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
			
			// BUTTONS
			
			buttonsContainer = new Sprite();
			addChild( buttonsContainer );
			
			function addButton( name:String, color:uint, func:Function ):Button
			{
				var btn:Button = new Button( assets.getTexture( "btn" ), name );
				btn.fontColor = color;
				btn.fontBold = true;
				btn.x = 0;
				btn.y = buttonsContainer.height + 10;
				btn.addEventListener( Event.TRIGGERED, func );
				buttonsContainer.addChild( btn );
				return btn;
			}
			
			button1 = addButton( "RESTART", 0x53449B, game.endGame );
			button2 = addButton( "END TURN", 0x2EACE9, game.endTurn );
			button3 = addButton( "ATTACK", 0xFF2000, btn3f );
			button4 = addButton( "FLIP", 0xFFCC33, btn4f );
			
			function btn3f():void
			{
				game.performCardAttack( game.selectedCard );
				game.selectCard( null );
			}
			
			function btn4f():void
			{
				game.performSafeFlip( game.selectedCard );
			}
			
			buttonsContainer.alignPivot( "right", "top" );
			buttonsContainer.x = App.W;
			buttonsContainer.y = 0;
		}
		
		public function advanceTime( time:Number ):void
		{
			buttonsContainer.alpha = game.interactable ? 1.0 : 0.6;
			
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
			t.targetValue = p.lifePoints;
			t.color = p == game.currentPlayer ? 0xFFEE22 : 0xF37618;
			t.advanceTime( time );
		}
		
		//
	}
}