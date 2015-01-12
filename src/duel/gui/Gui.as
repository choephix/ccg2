package duel.gui
{
	import chimichanga.common.display.Sprite;
	import duel.controllers.UserPlayerController;
	import duel.GameSprite;
	import duel.players.Player;
	import duel.players.ManaPool;
	import starling.display.Button;
	import starling.events.Event;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Gui extends GameSprite
	{
		private var tcenter:TextField;
		private var t1:AnimatedTextField;
		private var t2:AnimatedTextField;
		
		private var logBox:LogBox;
		
		public var buttonsContainer:Sprite;
		
		public var button1:Button;
		public var button2:Button;
		public var button3:Button;
		public var button4:Button;
		
		public function Gui()
		{
			const INSET:Number = 10;
			
			t1 = new AnimatedTextField( 0, 0, "", "Impact", 50 );
			addChild( t1 );
			t1.x = INSET;
			t1.width = App.W - INSET * 2.0;
			t1.height = App.H;
			t1.color = 0xFFEE22;
			t1.hAlign = "right";
			t1.vAlign = "bottom";
			t1.touchable = false;
			
			t2 = new AnimatedTextField( 0, 0, "", "Impact", 50 );
			addChild( t2 );
			t2.x = INSET;
			t2.width = App.W - INSET * 2.0;
			t2.height = App.H;
			t2.color = 0xFFEE22;
			t2.hAlign = "left";
			t2.vAlign = "top";
			t2.touchable = false;
			
			tcenter = new TextField( App.W, App.H, "", "Calibri", 20, 0x2277EE, true );
			addChild( tcenter );
			tcenter.hAlign = "center";
			tcenter.vAlign = "center";
			tcenter.touchable = false;
			
			logBox = new LogBox();
			addChild( logBox );
			logBox.x = 20;
			logBox.y = 380;
			logBox.width = 260;
			logBox.height = 380;
			
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
			
			button1 = addButton( "SURRENDER", 0x53449B, game.performActionSurrender );
			button2 = addButton( "END TURN", 0x2EACE9, game.performActionTurnEnd );
			button3 = addButton( "ATTACK", 0xFF2000, btn3f );
			button4 = addButton( "FLIP", 0xFFCC33, btn4f );
			
			function btn3f():void
			{
				game.currentPlayer.ctrl.performActionAttack( 
					UserPlayerController( game.currentPlayer.ctrl ).selection.selectedCard )
			}
			
			function btn4f():void
			{ 
				game.currentPlayer.ctrl.performActionSafeFlip( 
					UserPlayerController( game.currentPlayer.ctrl ).selection.selectedCard )
			}
			
			buttonsContainer.alignPivot( "right", "top" );
			buttonsContainer.x = App.W;
			buttonsContainer.y = 0;
		}
		
		public function advanceTime( time:Number ):void
		{
			t1.advanceTime( time );
			t2.advanceTime( time );
		}
		
		public function updateData():void
		{
			buttonsContainer.alpha = game.interactable ? 1.0 : 0.6;
			updateTf( t1, game.p1 );
			updateTf( t2, game.p2 );
			button3.visible = game.interactable && canDoAttack( game.currentPlayer.ctrl as UserPlayerController );
			button4.visible = game.interactable && canDoSafeFlip( game.currentPlayer.ctrl as UserPlayerController );
		}
		
		private function canDoAttack( ctrl:UserPlayerController ):Boolean
		{
			return ctrl != null &&
				ctrl.selection.selectedCard != null && 
				ctrl.selection.selectedCard.type.isCreature && 
				ctrl.selection.selectedCard.canAttack;
		}
		
		private function canDoSafeFlip( ctrl:UserPlayerController ):Boolean
		{
			return ctrl != null &&
				ctrl.selection.selectedCard != null && 
				ctrl.selection.selectedCard.type.isCreature && 
				ctrl.selection.selectedCard.faceDown &&
				ctrl.selection.selectedCard.exhausted == false;
		}
		
		private function updateTf( t:AnimatedTextField, p:Player ):void
		{
			t.text = " " + game.p2.name + ": " 
						+ AnimatedTextField.DEFAULT_MARKER 
						+ "\n" + manaText( p.mana );
			t.targetValue = p.lifePoints;
			t.color = p == game.currentPlayer ? 0xFFEE22 : 0xF37618;
		}
		
		private function manaText( mana:ManaPool ):String
		{
			return "Mana: " + mana.current + "/" + mana.currentCap + "";
			//var r:String = "";
			//while ( val-- > 0 )
				//r += "M";
			//return r ;
		}
		
		public function log( s:String ):void
		{
			logBox.log( s );
		}
		
		public function pMsg( msg:String ):void
		{
			tcenter.text = msg;
			
			CONFIG::sandbox
			{ return }
			
			tcenter.alpha = 1.0;
			juggler.removeTweens( tcenter );
			juggler.tween( tcenter, 1.500, { alpha : .0, delay : 1.500 } );
		}
		
		//public function log( o:* ):void
		//{ tLog.text = String( o ) + "\n" + tLog.text }
		
	}
}