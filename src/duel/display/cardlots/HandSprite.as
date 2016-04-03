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
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class HandSprite extends CardsContainer
	{
		public static const W_MAX:Number 		= 500;
		public static const PADDING_X:Number 	= 50;
		public static const H_ACTIVE:Number 	= 30;
		public static const H_INACTIVE:Number 	= 200;
		public static const H_FOCUSED:Number 	= 120;
		public static const MAX_CARD_SPACING:Number = G.CARD_W + 10.0;
		
		public var yLimOpen:Number = App.H * .1;
		public var yLimClose:Number = App.H * .6;
		public var xLimOpen:Number = 1000;
		public var xLimClose:Number = App.W - 500;
		
		private var _animationDirty:Number = 0.0;
		
		private var _pointerXY:Point = new Point();
		private var _cardPointerX:Number = NaN;
		private var _cardPointerUpness:Number = NaN;
		
		private var _sideSign:Number = 1.0;
		
		private var _cardSpacing:Number = .0;
		
		private var _isOpen:Boolean = false;
		
		// -- == -- == -- == -- == -- == -- == -- == -- == -- == -- == -- == -- //
		
		public var maxWidth:Number = 1200;
		
		private var _hand:Hand;
		private var _active:Boolean = false;
		private var _focusedCard:Card = null;
		
		public function HandSprite( hand:Hand )
		{
			this._hand = hand;
			setTargetList( hand );
			
			game.guiEvents.addEventListener( GuiEvents.CARD_CLICK, onCardClick );
			game.guiEvents.addEventListener( GuiEvents.CARD_FOCUS, onCardFocus );
			game.guiEvents.addEventListener( GuiEvents.CARD_UNFOCUS, onCardUnfocus );
			game.stage.addEventListener( TouchEvent.TOUCH, onGameTouch );
		}
		
		public function destroy():void
		{
			game.guiEvents.removeEventListener( GuiEvents.CARD_CLICK, onCardClick );
			game.guiEvents.removeEventListener( GuiEvents.CARD_FOCUS, onCardFocus );
			game.guiEvents.removeEventListener( GuiEvents.CARD_UNFOCUS, onCardUnfocus );
			game.stage.removeEventListener( TouchEvent.TOUCH, onGameTouch );
		}
		
		override public function advanceTime( time:Number ):void
		{
			if ( _animationDirty > 0.0 )
			{
				_animationDirty -= time;
				arrange();
			}
		}
		
		// EVENT HANDLERS
		
		private function onGameTouch( e:TouchEvent ):void 
		{
			var t:Touch = e.getTouch( game.stage );
			
			if ( t == null ) 
				return;
			
			t.getLocation( game, _pointerXY );
			
			_pointerXY.x -= this.x + game.table.x;
			_pointerXY.y -= this.y + game.table.y;
			_pointerXY.x *= -1.0;
			_pointerXY.y *= -_sideSign;
			
			_cardPointerX = NaN;
			
			// OPEN / CLOSE
			
			if (  _isOpen )
				if ( _pointerXY.y > yLimClose || _pointerXY.x > xLimClose )
					setOpen( false );
			
			if ( !_isOpen )
				if ( _pointerXY.y < yLimOpen && _pointerXY.x < xLimOpen )
					setOpen( true );
			
			// UPDATE FOCUS
			
			var fail:Boolean = false;
			
			fail ||= list.cardsCount < 1;
			fail ||= _pointerXY.y > yLimClose;
			fail ||= _pointerXY.x < PADDING_X;
			fail ||= _pointerXY.x > PADDING_X + maxWidth;
			fail ||= _pointerXY.x > PADDING_X + list.cardsCount * _cardSpacing + G.CARD_W;
			
			if ( fail )
			{
				setFocusedCard( null );
			}
			else	
			{
				_cardPointerX = ( _pointerXY.x - PADDING_X ) / maxWidth;
				_cardPointerX = _cardPointerX * ( list.cardsCount + 1 ) - 1.5;
				
				if ( _cardPointerX < 0.0 ) _cardPointerX = 0.0;
				if ( _cardPointerX >= list.cardsCount ) _cardPointerX = list.cardsCount - 1.0;
				
				_cardPointerUpness = _cardPointerX - int(_cardPointerX+.5);
				//_cardPointerUpness = 2.0 * Math.abs( _cardPointerUpness );
				_cardPointerUpness = 2.0 * _cardPointerUpness;
				
				Debug.debugString = "cpX: " + _cardPointerX.toFixed(3);
				Debug.debugString += " up: " + _cardPointerUpness.toFixed(3);
				
				setFocusedCard( list.getCardAt( int(_cardPointerX) ) );
			}
			
			raiseAnimationDirtyFlag();
		}
		
		private function setOpen( value:Boolean ):void 
		{
			if ( _isOpen == value ) return;
			
			_isOpen = value;
			_focusedCard = null;
			
			raiseAnimationDirtyFlag();
		}
		
		private function setFocusedCard( c:Card ):void 
		{
			if ( _focusedCard == c )
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
		
		override protected function onCardAdded( e:Event ):void
		{
			super.onCardAdded( e );
			raiseAnimationDirtyFlag();
		}
		
		override protected function onCardRemoved( e:Event ):void
		{
			super.onCardRemoved( e );
			raiseAnimationDirtyFlag();
		}
		
		public function arrange():void
		{
			if ( cardsParent == null )
				return;
			
			var targetProps:TargetProps = new TargetProps();
			
			const X:Number = this.x - PADDING_X - G.CARD_W * .5;
			//const Y:Number = this.y - _sideSign * G.CARD_H * .5;
			const Y:Number = this.y;
			const NUM_CARDS:int = list.cardsCount;
			
			var o:CardSprite;
			var i:int = NUM_CARDS;
			
			if ( _isOpen )
				_cardSpacing = ( maxWidth - G.CARD_W ) / ( NUM_CARDS - 1 );
			else
				_cardSpacing = 40.0;
			
			if ( _cardSpacing > MAX_CARD_SPACING )
				_cardSpacing = MAX_CARD_SPACING;
				
			const FOCUSED_CARD_INDEX:int = list.indexOfCard( _focusedCard );
			const POW:Number = .125;
			
			while ( --i >= 0 )
			{
				o = list.getCardAt( i ).sprite;
				
				var upness:Number;
				
				upness = 0.0;
				if ( FOCUSED_CARD_INDEX >= 0 )
				{
					upness = _cardPointerX - i;
					upness = 1.0 - Math.abs( upness ) / 2.0;
					upness = ( upness - 0.50 ) / .50;
					upness = Number.max( 0.0, upness );
					upness = curveNormal( upness, 5.0 );
					//o.setTitle( upness.toFixed( 3 ) );
				}
				
				/// Rotation
				
				if ( _isOpen )
				{
					targetProps.rotation = ( NUM_CARDS * .5 - i - .5 ) * ( .05 + NUM_CARDS * .0125 / NUM_CARDS );
				}
				else
				{
					targetProps.rotation = ( NUM_CARDS * .5 - i - .5 ) * ( .02 + NUM_CARDS * .0025 / NUM_CARDS );
				}
				targetProps.rotation = MathF.lerp( targetProps.rotation, 0.0, upness );
				
				/// X
				
				if ( _focusedCard == null  )
				{
					targetProps.x = X - i * _cardSpacing;
				}
				else
				{
					const xLeftOrFocused:Number = ( X - i * _cardSpacing ) - ( G.CARD_W * .5 * ( 1.0 - i / NUM_CARDS ) );
					const xRight:Number = ( X - i * _cardSpacing ) + ( G.CARD_W * .5 * ( i / NUM_CARDS ) );
					const ratio:Number = ( FOCUSED_CARD_INDEX < i ) ? 1.0 : upness;
					
					targetProps.x = MathF.lerp( xRight, xLeftOrFocused, ratio );
				}
				
				/// Y
				
				if ( _isOpen )
				{
					targetProps.y = Y;
					targetProps.y = MathF.lerp( calcY_Unfocused(), calcY_Focused(), upness );
					//targetProps.rotation = MathF.lerp( targetProps.rotation, 0.0, upness );
					
					function calcY_Focused():Number { return targetProps.y - _sideSign * G.CARD_H * .55; }
					function calcY_Unfocused():Number { return targetProps.y + _sideSign * Math.abs( targetProps.rotation ) * 2000 / NUM_CARDS; }
				}
				else
				{
					targetProps.y = this.y 
						+ _sideSign * G.CARD_H * .4
						+ _sideSign * Math.abs( targetProps.rotation ) * 400 / NUM_CARDS;
				}
				
				///
				if ( !cardsParent.contains( o ) )
					cardsParent.addChild( o );
				
				///
				o.tween.to( targetProps.x, targetProps.y, targetProps.rotation, targetProps.scale );
				
				function curveNormal( frac:Number, pow:Number ):Number 
				{ return frac < 0.5 ? ( 0.5 * Math.pow( 2.0 * frac, pow ) ) : ( 1.0 + 0.5 * Math.pow( 2.0 * frac - 2.0, pow ) ) }
			}
		}
		
		public function arrange_SIMPLE():void
		{
			if ( cardsParent == null )
				return;
			
			var targetProps:TargetProps = new TargetProps();
			
			const X:Number = this.x - PADDING_X - G.CARD_W * .5;
			//const Y:Number = this.y - _sideSign * G.CARD_H * .5;
			const Y:Number = this.y;
			const NUM_CARDS:int = list.cardsCount;
			
			var o:CardSprite;
			var i:int = NUM_CARDS;
			
			if ( _isOpen )
				_cardSpacing = ( maxWidth - G.CARD_W ) / ( NUM_CARDS - 1 );
			else
				_cardSpacing = 40.0;
			
			if ( _cardSpacing > MAX_CARD_SPACING )
				_cardSpacing = MAX_CARD_SPACING;
			
			while ( --i >= 0 )
			{
				o = list.getCardAt( i ).sprite;
				
				/// Rotation
				
				if ( _isOpen )
				{
					targetProps.rotation = ( NUM_CARDS * .5 - i - .5 ) * ( .05 + NUM_CARDS * .0125 / NUM_CARDS );
				}
				else
				{
					targetProps.rotation = ( NUM_CARDS * .5 - i - .5 ) * ( .02 + NUM_CARDS * .0025 / NUM_CARDS );
				}
				//targetProps.rotation = 0;
				
				/// X
				
				if ( _focusedCard == null  )
				{
					targetProps.x = X - i * _cardSpacing;
				}
				else
				{
					var iFocused:int = list.indexOfCard( _focusedCard );
					targetProps.x = 
						( iFocused <= i ) ? 
						( X - i * _cardSpacing ) - ( G.CARD_W * .5 * ( 1.0 - i / NUM_CARDS ) ) : 
						( X - i * _cardSpacing ) + ( G.CARD_W * .5 * ( i / NUM_CARDS ) ) ;
				}
				
				/// Y
				
				if ( _isOpen )
				{
					targetProps.y = Y;
					if ( _focusedCard != null && o == _focusedCard.sprite )
					{
						targetProps.y -= _sideSign * G.CARD_H * .50;
						targetProps.rotation = .0;
					}
					targetProps.y += _sideSign * Math.abs( targetProps.rotation ) * 2000 / NUM_CARDS;
				}
				else
				{
					targetProps.y = this.y 
						+ _sideSign * G.CARD_H * .4
						+ _sideSign * Math.abs( targetProps.rotation ) * 400 / NUM_CARDS;
				}
				
				///
				cardsParent.addChild( o );
				
				///
				o.tween.to( targetProps.x, targetProps.y, targetProps.rotation, targetProps.scale );
			}
		}
		
		public function raiseAnimationDirtyFlag():void
		{
			_animationDirty = 1.0;
		}
		
		
		
		
		
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function set active( value:Boolean ):void
		{
			if ( _active == value ) return;
			_active = value;
			raiseAnimationDirtyFlag();
		}
		
		public function get selectedCard():Card 
		{
			//return _selectedCard;
			return null;
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
		
		/** * /
		
		// -- == -- == -- == -- == -- == -- == -- == -- == -- == -- == -- == -- //
		
		// -- == -- == -- == -- == -- == -- == -- == -- == -- == -- == -- == -- //
		
		// -- == -- == -- == -- == -- == -- == -- == -- == -- == -- == -- == -- //
		
		
		static public const SEL_SPACE:Number = 100;
		
		private var _selectedCard:Card = null;
		private var _tipSprite:TipBox;
		
		override protected function arrangeAll():void
		{
			arrange();
		}
		
		override protected function tweenToPlace( cs:CardSprite ):void
		{
			arrange();
		}
		
		public function arrange():void
		{
			if ( cardsParent == null )
				return;
			
			var targetProps:TargetProps = new TargetProps();
			
			const W:Number = maxWidth - G.CARD_W;
			
			var x:Number = G.CARD_W * .5;
			var y:Number = 0.0;
			
			var o:CardSprite;
			var i:int = list.cardsCount;
			var jj:int = 0;
			var sideDir:Number = topSide ? -1.0 : 1.0;
			while ( --i >= 0 )
			{
				o = list.getCardAt( i ).sprite;
				
				/// X
				x = x + theD( W );
				targetProps.x = this.x + x;
				
				/// Y
				if ( _active )
					if ( selectedCard == null )
						if ( o.isFocused )
							//y = sideDir * G.CARD_H * -.5;
							y = sideDir * G.CARD_H * -.3;
						else
						if ( o.isSelectable )
							//y = sideDir * G.CARD_H * -.03;
							y = sideDir * G.CARD_H * .2;
						else
							y = sideDir * G.CARD_H * .3;
					else
						if ( o == selectedCard.sprite )
							y = sideDir * G.CARD_H * -.88;
						else
							y = sideDir * G.CARD_H * .4;
				else
					y = sideDir * G.CARD_H * .4;
					
				targetProps.y = this.y + y;
				
				if ( o.isSelected )
				{
					targetProps.x = .0;
					targetProps.y = -.2 * App.H;
				}
				
				/// Z
				targetProps.scale = z;
				
				/// ROTATION
				targetProps.rotation = topSide ? Math.PI : .0;
				
				/// Index
				if ( topSide )
					o.parent.setChildIndex( o, 0 );
				else
					o.parent.setChildIndex( o, o.parent.numChildren - 1 );
				
				cardsParent.addChild( o );
				
				///
				o.tween.to( targetProps.x, targetProps.y, targetProps.rotation, targetProps.scale );
				
				jj++;
			}
		}
		
		private function lerp( a:Number, b:Number, r:Number ):Number
		{ return a + r * ( b - a ) }
		
		// EVENT HANDLERS
		
		private function onCardFocus(e:Event):void 
		{
			arrange();
			
			var c:Card = e.data as Card;
			
			if ( !c.sprite.isSelectable && !c.sprite.isSelected )
				return;
			
			if ( !_hand.containsCard( c ) )
				return;
				
			c.sprite.addChild( _tipSprite );
			
			if ( c.sprite.isSelected )
				_tipSprite.text = "Cancel?";
			else
			if ( c.isTrap )
				_tipSprite.text = "Set Me?";
			else
			if ( c.isCreature )
				if ( c.propsC.isFlippable )
					_tipSprite.text = "Summon Me Face-Down?";
				else
				if ( c.statusC.needTribute )
					_tipSprite.text = "Tribute-Summon Me?";
				else
					_tipSprite.text = "Summon Me?";
					
			_tipSprite.fadeIn();
		}
		
		private function onCardUnfocus(e:Event):void 
		{
			arrange();
			
			if ( Card( e.data ).sprite.contains( _tipSprite ) )
				_tipSprite.removeFromParent( false );
		}
		
		override protected function onCardAdded( e:Event ):void
		{
			super.onCardAdded( e );
			arrange();
		}
		
		override protected function onCardRemoved( e:Event ):void
		{
			super.onCardRemoved( e );
			arrange();
			
			var c:Card = e.data as Card;
			jugglerGui.removeTweens( c.sprite );
			
			if ( selectedCard == c )
				selectedCard = null;
		}
		
		//
		
		/* * * */
	
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
		
		q = new Quad( G.CARD_W, 32, 0x0 );
		q.alignPivot();
		q.alpha = .0;
		addChild( q );
		
		t = new TextField( G.CARD_W, 32, "?" );
		t.format.font = "Calibri";
		t.format.size = 24;
		t.format.color = 0xFFFFFF;
		t.format.bold = true;
		t.alignPivot();
		t.autoScale = true;
		addChild( t );
		
		touchable = false;
	}
	
	public function fadeIn():void
	{
		y = -.5 * G.CARD_H;
		alpha = .0;
		juggler.xtween( this, .150, 
			{ 
				y : -.6 * G.CARD_H,
				alpha : 1.0 
			} );
	}
	
	public function get color():uint
	{
		return q.color;
	}
	
	public function set color( value:uint ):void
	{
		q.color = value;
	}
	
	public function get textColor():uint
	{
		return t.format.color;
	}
	
	public function set textColor( value:uint ):void
	{
		t.format.color = value;
	}
	
	public function get text():String
	{
		return t.text;
	}
	
	public function set text( value:String ):void
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