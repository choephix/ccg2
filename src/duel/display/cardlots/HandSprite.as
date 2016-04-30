package duel.display.cardlots
{
	import adobe.utils.CustomActions;
	import chimichanga.global.utils.MathF;
	import dev.Debug;
	import duel.cards.Card;
	import duel.display.cards.CardSprite;
	import duel.G;
	import duel.gui.GuiEvents;
	import duel.table.Hand;
	import flash.geom.Point;
	import global.StaticVariables;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.utils.MeshSubset;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class HandSprite extends CardsContainer
	{
		public static const W_MAX:Number = 500;
		public static const PADDING_X:Number = 50;
		public static const H_ACTIVE:Number = 30;
		public static const H_INACTIVE:Number = 200;
		public static const H_FOCUSED:Number = 120;
		public static const MAX_CARD_SPACING:Number = G.CARD_W * 0.9;
		
		public var yLimOpen:Number = App.H * .1;
		public var yLimClose:Number = App.H * .4;
		public var xLimOpen:Number = 600;
		public var xLimClose:Number = App.W - 500;
		
		private var _animationDirty:Number = 0.0;
		
		private var _sideSign:Number = 1.0;
		
		private var _cardSpacing:Number = .0;
		private var _cardsOffsetX:Number = .0;
		
		private var _isOpen:Boolean = false;
		
		// -- == -- == -- == -- == -- == -- == -- == -- == -- == -- == -- == -- //
		
		public var maxWidth:Number = 1200;
		
		private var _hand:Hand;
		private var _active:Boolean = false;
		private var _focusedCard:Card = null;
		
		public function HandSprite(hand:Hand)
		{
			this._hand = hand;
			setTargetList(hand);
			
			game.guiEvents.addEventListener(GuiEvents.CARD_CLICK, onCardClick);
			game.guiEvents.addEventListener(GuiEvents.CARD_FOCUS, onCardFocus);
			game.guiEvents.addEventListener(GuiEvents.CARD_UNFOCUS, onCardUnfocus);
			game.stage.addEventListener(TouchEvent.TOUCH, onGameTouch);
		}
		
		public function destroy():void
		{
			game.guiEvents.removeEventListener(GuiEvents.CARD_CLICK, onCardClick);
			game.guiEvents.removeEventListener(GuiEvents.CARD_FOCUS, onCardFocus);
			game.guiEvents.removeEventListener(GuiEvents.CARD_UNFOCUS, onCardUnfocus);
			game.stage.removeEventListener(TouchEvent.TOUCH, onGameTouch);
		}
		
		override public function advanceTime(time:Number):void
		{
			if (_animationDirty > 0.0)
			{
				_animationDirty -= time;
				arrange();
			}
		}
		
		// EVENT HANDLERS
		
		private function onGameTouch(e:TouchEvent):void
		{
			var t:Touch = e.getTouch(game.stage);
			
			if (t == null)
				return;
			
			t.getLocation(game, _pointerXY);
			
			_pointerXY.x -= this.x + game.table.x;
			_pointerXY.y -= this.y + game.table.y;
			_pointerXY.x *= -1.0;
			_pointerXY.y *= -_sideSign;
			
			// OPEN / CLOSE
			
			if (_isOpen)
				if (_pointerXY.y > yLimClose || _pointerXY.x > xLimClose)
					setOpen(false);
			
			if (!_isOpen)
				if (_pointerXY.y < yLimOpen && _pointerXY.x < xLimOpen)
					setOpen(true);
			
			// UPDATE FOCUS
			
			var fail:Boolean = false;
			
			fail ||= list.cardsCount < 1;
			fail ||= _pointerXY.y > yLimClose;
			fail ||= _pointerXY.x < PADDING_X;
			fail ||= _pointerXY.x > PADDING_X + maxWidth;
			fail ||= _pointerXY.x > PADDING_X + list.cardsCount * _cardSpacing + G.CARD_W;
			
			if (fail)
			{
				setFocusedCard(null);
			}
			else
			{
				//setFocusedCard( list.getCardAt( int(_cardPointerX) ) );
			}
			
			raiseAnimationDirtyFlag();
		
			//Debug.markDOContainer( cardsParent,  0.0,  0.0, this._hand.owner.color, .100 );
			//Debug.markDOContainer( cardsParent,  120,  120, this._hand.owner.color, .100 );
			//Debug.markDOContainer( cardsParent, -120, -120, this._hand.owner.color, .100 );
		}
		
		private function setOpen(value:Boolean):void
		{
			if (_isOpen == value) return;
			
			_isOpen = value;
			_focusedCard = null;
			
			raiseAnimationDirtyFlag();
		}
		
		private function setFocusedCard(c:Card):void
		{
			if (_focusedCard == c)
				return;
			
			_focusedCard = c;
			raiseAnimationDirtyFlag();
		}
		
		private function onCardClick(e:Event):void
		{
			raiseAnimationDirtyFlag();
		}
		
		private function onCardFocus(e:Event):void
		{
			raiseAnimationDirtyFlag();
		}
		
		private function onCardUnfocus(e:Event):void
		{
			raiseAnimationDirtyFlag();
		}
		
		override protected function onCardAdded(e:Event):void
		{
			super.onCardAdded(e);
			cardsParent.addChild( Card(e.data).sprite );
			raiseAnimationDirtyFlag();
		}
		
		override protected function onCardRemoved(e:Event):void
		{
			super.onCardRemoved(e);
			raiseAnimationDirtyFlag();
		}
		
		private const MARGIN_RIGHT_OPEN:Number   = 200;
		private const MARGIN_RIGHT_CLOSED:Number = 250;
		private var _maxAreaWidth:Number = 1000;
		private var _pointerXY:Point = new Point();
		
		private var __numCards:int = 0;
		private var __pProxY:Number = 0.0;
		private var __fracCards:Number = 0.0;
		private var __targetProps:TargetProps = new TargetProps();
		
		public function arrange():void
		{
			if ( cardsParent == null )
				return;
				
			__numCards = list.cardsCount;
			
			if ( __numCards < 1 )
				return;
				
			__fracCards = __numCards == 1 ? 0.0 : 1.0 / ( __numCards - 1 );
			__pProxY = Math.pow( Math.min( 1.0, Math.max( 0.0, ( _pointerXY.y - .025 * G.CARD_H ) / ( App.H * 0.5 - .025 * G.CARD_H ) ) ), 0.4 );
			
			( _isOpen ? arrange_Open : arrange_Closed )();
		}
		
		public function arrange_Open():void
		{
			var i:int = __numCards;
			var fracPointer:Number = 0.0;
			var fracIndex:Number = 0.0;
			var upness:Number = 0.0;
			
			var areaWidth:Number = Math.min( _maxAreaWidth, G.CARD_W * ( 0.25 + __numCards * 0.75 ) );
			var areaRight:Number = MARGIN_RIGHT_OPEN;
			var areaLeft:Number  = areaRight + areaWidth;
			
			var pWidth:Number = Math.max( areaWidth - G.CARD_W, 1.0 );
			var pRight:Number = areaRight + G.CARD_W * 0.5;
			var pLeft:Number  = areaLeft  - G.CARD_W * 0.5;
			
			fracPointer = ( _pointerXY.x - pRight ) / pWidth;
			fracPointer =
					Math.min( 1.0 + __fracCards, Math.max( -__fracCards, fracPointer ) );
			
			var luft:Number = - 0.75 * G.CARD_W * Math.pow( areaWidth / _maxAreaWidth, 2.5 );
			//var luft:Number = 0.0;
			var spanWidth:Number = Math.max( areaWidth - G.CARD_W - luft, 1.0 );
			var spanRight:Number = areaRight + G.CARD_W * 0.5 + luft * fracPointer;
			var spanLeft:Number  = spanRight + spanWidth;
			
			Debug.markArea( cardsParent, x - areaLeft, _sideSign * 40.0, x - areaRight + 1.0, _sideSign * 47.0, _hand.owner.color, 0.3, 0.0 );
			Debug.markArea( cardsParent, x - pLeft,    _sideSign * 41.0, x - pRight + 1.0,    _sideSign * 42.0, _hand.owner.color, 1.0, 0.0 );
			Debug.markArea( cardsParent, x - spanLeft, _sideSign * 44.0, x - spanRight + 1.0, _sideSign * 46.0, _hand.owner.color, 1.0, 0.0 );
			Debug.markArea( cardsParent, x - spanLeft - 0.5 * G.CARD_W, _sideSign * 44.0, x - spanRight + 0.5 * G.CARD_W, _sideSign * 46.0, _hand.owner.color, 0.3, 0.0 );
			
			__targetProps.x = spanLeft;
			
			while ( --i >= 0 )
			{
				fracIndex = i * __fracCards;
				
				if ( i < __numCards-1 ) 
					__targetProps.x -= MathF.lerp(
										spanWidth * __fracCards,
										G.CARD_W + 4.0, upness );
									
				upness = Math.abs( i - fracPointer * ( __numCards - 1 ) );
				upness = 1.0 - Math.min( 1.0, upness );
				upness = frac_LinearToSine( upness, 7.0 );
				
				__targetProps.rotation = ( 1.0 - 0.75 * __pProxY ) * Math.asin( Math.min( 1.0, Math.max( -1.0, fracPointer - fracIndex ) ) ) * 0.20;
				//__targetProps.rotation = MathF.lerp( 0.025, 0.200, __pProxY ) * ( fracPointer - fracIndex - 0.10 );
				
				list.getCardAt( i ).sprite.setTitle( __targetProps.rotation.toFixed(3) );
				
				__targetProps.y = _sideSign * ( 
									  App.H * 0.5
									- MathF.lerp( 0.0, G.CARD_H * 0.5, upness )
									+ Math.abs( __targetProps.rotation ) * MathF.lerp( 120, 160, __pProxY )
									);
									
				//list.getCardAt( i ).sprite.setTitle( "" );
				//list.getCardAt( i ).sprite.alpha = 0.5;
				list.getCardAt( i ).sprite.tween.to( x - __targetProps.x, __targetProps.y, __targetProps.rotation, __targetProps.scale );
			}
			
			if ( this._hand.owner == game.currentPlayer )
			{
				Debug.publicArray[0] = _pointerXY;
				Debug.publicArray[1] = fracPointer.toFixed(2);
			}
		}
		
		public function arrange_Closed():void
		{
			var i:int = __numCards;
			var fracIndex:Number = 0.0;
			
			var areaWidth:Number = Math.min( 1500.0, G.CARD_W * Math.pow( __numCards, MathF.lerp( 0.175, 0.125, __pProxY ) ) );
			var areaRight:Number = MARGIN_RIGHT_CLOSED;
			var areaLeft:Number  = areaRight + areaWidth;
			
			var spanWidth:Number = Math.max( areaWidth - G.CARD_W, 1.0 );
			var spanRight:Number = areaRight + G.CARD_W * 0.5;
			var spanLeft:Number  = spanRight + spanWidth;
			
			Debug.markArea( cardsParent, x - areaLeft, _sideSign * 40.0, x - areaRight + 1.0, _sideSign * 47.0, _hand.owner.color, 0.3, 0.0 );
			Debug.markArea( cardsParent, x - spanLeft, _sideSign * 44.0, x - spanRight + 1.0, _sideSign * 46.0, _hand.owner.color, 1.0, 0.0 );
			Debug.markArea( cardsParent, x - spanLeft - 0.5 * G.CARD_W, _sideSign * 44.0, 
										 x - spanRight + 0.5 * G.CARD_W, _sideSign * 46.0, _hand.owner.color, 0.3, 0.0 );
			
			__targetProps.x = spanLeft;
			
			while ( --i >= 0 )
			{
				fracIndex = i * __fracCards;
				
				//__targetProps.rotation = MathF.lerp( 0.010, 0.20, ( 1.0 - __pProxY ) * ( 0.5 - fracIndex ) );
				__targetProps.rotation = ( 1.0 - 0.75 * __pProxY ) * Math.asin( 0.5 - fracIndex ) * 0.20;
				
				list.getCardAt( i ).sprite.setTitle( __targetProps.rotation.toFixed(3) );
				
				__targetProps.x = spanRight + fracIndex * spanWidth;
				__targetProps.y = _sideSign * ( 
									  App.H * 0.5
									+ MathF.lerp( G.CARD_H * 0.20, G.CARD_H * 0.478, __pProxY )
									+ Math.abs( __targetProps.rotation ) * 20
									);
				
				//list.getCardAt( i ).sprite.setTitle( "" );
				//list.getCardAt( i ).sprite.alpha = 0.5;
				list.getCardAt( i ).sprite.tween.to( x - __targetProps.x, __targetProps.y, __targetProps.rotation, __targetProps.scale );
			}
			
			if ( this._hand.owner == game.currentPlayer )
			{
				Debug.publicArray[0] = _pointerXY;
			}
		}
		
		private static function frac_LinearToSine( frac:Number, pow:Number ):Number
		{
			if ( frac <= 0.0 ) return 0.0;
			if ( frac >= 1.0 ) return 1.0;
			var n:Number = Math.sin( Math.PI * (1.5 + frac) );
			return 0.5 + 0.5 * ( n > 0 ? Math.pow( n, 1/pow ) : -Math.pow( -n, 1/pow ) );
		}
		
		public function raiseAnimationDirtyFlag():void
		{
			_animationDirty = 1.0;
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function set active(value:Boolean):void
		{
			if (_active == value) return;
			_active = value;
			raiseAnimationDirtyFlag();
		}
		
		public function get selectedCard():Card
		{
			return StaticVariables.selectedCard;
		}
		
		public function set selectedCard(value:Card):void
		{
			//if ( _selectedCard == value ) return;
			//_selectedCard = value;
			raiseAnimationDirtyFlag();
		}
		
		public function get topSide():Boolean
		{
			return _sideSign < .0;
		}
		
		public function set topSide(value:Boolean):void
		{
			_sideSign = value ? -1.0 : 1.0;
		}
	
	}

}

import duel.G;
import duel.GameSprite;
import starling.animation.IAnimatable;
import starling.display.Quad;
import starling.text.TextField;

class TipBox extends GameSprite
{
	private var q:Quad;
	private var t:TextField;
	
	private var _visible:Boolean;
	
	public function TipBox()
	{
		super();
		
		q = new Quad(G.CARD_W, 32, 0x0);
		q.alignPivot();
		q.alpha = .0;
		addChild(q);
		
		t = new TextField(G.CARD_W, 32, "?");
		t.format.font = "Calibri";
		t.format.size = 24;
		t.format.color = 0xFFFFFF;
		t.format.bold = true;
		t.alignPivot();
		t.autoScale = true;
		addChild(t);
		
		touchable = false;
	}
	
	public function fadeIn():void
	{
		y = -.5 * G.CARD_H;
		alpha = .0;
		juggler.xtween(this, .150, {y: -.6 * G.CARD_H, alpha: 1.0});
	}
	
	public function get color():uint
	{
		return q.color;
	}
	
	public function set color(value:uint):void
	{
		q.color = value;
	}
	
	public function get textColor():uint
	{
		return t.format.color;
	}
	
	public function set textColor(value:uint):void
	{
		t.format.color = value;
	}
	
	public function get text():String
	{
		return t.text;
	}
	
	public function set text(value:String):void
	{
		t.text = value;
	}
}

class TargetProps
{
	public var x:Number = 0;
	public var y:Number = 0;
	public var rotation:Number = 0;
	public var scale:Number = 1;
}