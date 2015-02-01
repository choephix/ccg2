package duel.gui
{
	import chimichanga.common.display.Sprite;
	import duel.cards.Card;
	import duel.controllers.PlayerAction;
	import duel.controllers.PlayerActionType;
	import duel.controllers.UserPlayerController;
	import duel.GameSprite;
	import duel.players.ManaPool;
	import duel.players.Player;
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
		
		CONFIG::development
		private var logBox:LogBox;
		
		public var buttonsContainer:Sprite;
		
		public var cardTip:TipBox;
		
		public var button1:Button;
		public var button2:Button;
		
		private var _focusedCard:Card;
		
		public function Gui()
		{
			const INSET:Number = 70;
			
			t1 = new AnimatedTextField( 0, 0, "", "Impact", 55 );
			addChild( t1 );
			t1.x = INSET;
			t1.width = App.W - INSET * 2.0;
			t1.height = App.H;
			t1.color = 0xFFEE22;
			t1.hAlign = "right";
			t1.vAlign = "bottom";
			t1.touchable = false;
			
			t2 = new AnimatedTextField( 0, 0, "", "Impact", 55 );
			addChild( t2 );
			t2.x = 20;
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
			
			CONFIG::development
			{
			logBox = new LogBox();
			addChild( logBox );
			logBox.x = 20;
			logBox.y = 380;
			logBox.width = 260;
			logBox.height = 380;
			}
			
			cardTip = new TipBox();
			addChild( cardTip );
			cardTip.visible = false;
			
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
				CONFIG::mobile {
					btn.scaleX = 2.0;
					btn.scaleY = 2.0;
				}
				return btn;
			}
			
			button1 = addButton( "SURRENDER", 0x53449B, btn1f );
			button2 = addButton( "END TURN", 0x2EACE9, btn2f );
			
			function btn1f():void
			{
				game.currentPlayer.performAction(
					new PlayerAction().setTo( PlayerActionType.SURRENDER ) );
			}
			
			function btn2f():void
			{
				game.currentPlayer.performAction(
					new PlayerAction().setTo( PlayerActionType.END_TURN ) );
			}
			
			buttonsContainer.alignPivot( "right", "top" );
			buttonsContainer.x = App.W;
			buttonsContainer.y = 0;
			
			//
			
			game.guiEvents.addEventListener( GuiEvents.CARD_FOCUS, onCardFocus );
			game.guiEvents.addEventListener( GuiEvents.CARD_UNFOCUS, onCardUnfocus );
		}
		
		private function onCardFocus(e:Event):void 
		{
			_focusedCard = e.data as Card;
			
			if ( !game.p1.knowsCard( _focusedCard ) )
				return;
			
			cardTip.visible = true;
			cardTip.text = _focusedCard.name + "\n\n" + _focusedCard.descr;
			cardTip.x = .5 * App.W;
			cardTip.y = _focusedCard.sprite.y > .0 ? .25 * App.H : .75 * App.H;
		}
		
		private function onCardUnfocus(e:Event):void 
		{
			if ( _focusedCard != e.data as Card )
				return;
			
			cardTip.visible = false;
		}
		
		public function advanceTime( time:Number ):void
		{
			t1.advanceTime( time );
			t2.advanceTime( time );
			
			cardTip.advanceTime( time );
			
			buttonsContainer.visible =
				game.state.isOngoing &&
				( !game.meta.isMultiplayer || game.currentPlayer == game.p1 );
		}
		
		public function updateData():void
		{
			buttonsContainer.alpha = game.interactable ? 1.0 : 0.6;
			updateTf( t1, game.p1 );
			updateTf( t2, game.p2 );
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
			t.text = " " + p.name
						+ "\n" + manaText( p.mana )
						+ "   LP: " + AnimatedTextField.DEFAULT_MARKER 
			t.targetValue = p.lifePoints;
			t.color = p.color;
			t.alpha = p == game.currentPlayer ? 1.0 : 0.3;
		}
		
		private function manaText( mana:ManaPool ):String
		{
			return "AP: " + mana.current + "/" + mana.currentCap + "";
			//var r:String = "";
			//while ( val-- > 0 )
				//r += "M";
			//return r ;
		}
		
		public function log( s:String ):void
		{
			CONFIG::development
			{ logBox.log( s ) }
		}
		
		public function pMsg( msg:String, fadeOut:Boolean = true ):void
		{
			tcenter.text = msg;
			
			tcenter.alpha = 1.0;
			juggler.removeTweens( tcenter );
			
			if ( fadeOut )
				juggler.tween( tcenter, 1.500, { alpha : .0, delay : 1.500 } );
		}
		
		//public function log( o:* ):void
		//{ tLog.text = String( o ) + "\n" + tLog.text }
		
	}
}