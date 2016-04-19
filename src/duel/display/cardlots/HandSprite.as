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
		
		private var _paddingRight:Number = 500;
		private var _maxAreaWidth:Number = 1000;
		private var _pointerXY:Point = new Point();
		
		private var __targetProps:TargetProps = new TargetProps();
		
		public function arrange():void
		{
			if (cardsParent == null)
				return;
				
			if ( !_isOpen )
			{
				arrange_Closed();
				return;
			}
			
			const NUM_CARDS:int = list.cardsCount;
			
			if ( NUM_CARDS < 1 )
				return;
				
			const FRAC_CARDS:Number = NUM_CARDS == 1 ? 0.0 : 1.0 / ( NUM_CARDS - 1 );
			
			const POINT_Y:Number = Math.pow( Math.min( 1.0, Math.max( 0.0, ( _pointerXY.y - .025 * G.CARD_H ) / ( App.H * 0.5 - .025 * G.CARD_H ) ) ), 0.4 );
			
			var o:CardSprite;
			var i:int = NUM_CARDS;
			var fracPointer:Number = 0.0;
			var fracIndex:Number = 0.0;
			var upness:Number = 0.0;
			
			var areaWidth:Number = Math.min( _maxAreaWidth, G.CARD_W * ( 0.25 + NUM_CARDS * 0.75 ) );
			var areaRight:Number = _paddingRight;
			var areaLeft:Number  = areaRight + areaWidth;
			
			var pWidth:Number = Math.max( areaWidth - G.CARD_W, 1.0 );
			var pRight:Number = areaRight + G.CARD_W * 0.5;
			var pLeft:Number  = areaLeft  - G.CARD_W * 0.5;
			
			fracPointer = ( _pointerXY.x - pRight ) / pWidth;
			fracPointer =
					Math.min( 1.0 + FRAC_CARDS, Math.max( -FRAC_CARDS, fracPointer ) );
			
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
				fracIndex = i * FRAC_CARDS;
				
				if ( _isOpen )
				{
					if ( i < NUM_CARDS-1 ) 
						__targetProps.x -= MathF.lerp(
											spanWidth * FRAC_CARDS,
											G.CARD_W + 4.0, upness );
										
					upness = Math.abs( i - fracPointer * ( NUM_CARDS - 1 ) );
					upness = 1.0 - Math.min( 1.0, upness );
					upness = frac_LinearToSine( upness, 7.0 );
					
					__targetProps.rotation = MathF.lerp( 0.025, 0.100, POINT_Y ) * ( fracPointer - fracIndex - 0.10 );
					
					__targetProps.y = _sideSign * ( 
										  App.H * 0.5
										- MathF.lerp( 0.0, G.CARD_H * 0.5, upness )
										+ Math.abs( __targetProps.rotation ) * MathF.lerp( 480, 960, POINT_Y )
										);
				}
				else
				{
					__targetProps.rotation = MathF.lerp( 0.067, 0.125, POINT_Y ) * ( 0.5 - fracIndex );
					__targetProps.x = spanRight + fracIndex * spanWidth;
					__targetProps.y = _sideSign * ( 
										  App.H * 0.5
										+ G.CARD_H * 0.33
										+ Math.abs( __targetProps.rotation ) * 640
										);
				}
				
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
			const NUM_CARDS:int = list.cardsCount;
			
			if ( NUM_CARDS < 1 )
				return;
				
			const FRAC_CARDS:Number = NUM_CARDS == 1 ? 0.0 : 1.0 / ( NUM_CARDS - 1 );
			const POINT_Y:Number = Math.pow( Math.min( 1.0, Math.max( 0.0, ( _pointerXY.y - .025 * G.CARD_H ) / ( App.H * 0.5 - .025 * G.CARD_H ) ) ), 0.4 );
			
			var o:CardSprite;
			var i:int = NUM_CARDS;
			var fracIndex:Number = 0.0;
			
			var areaWidth:Number = Math.min( 1500.0, G.CARD_W * Math.pow( NUM_CARDS, 0.35 ) );
			var areaRight:Number = 100.0;
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
				fracIndex = i * FRAC_CARDS;
				
				__targetProps.rotation = MathF.lerp( 0.05, 0.20, Math.pow( 1.0 - POINT_Y, 0.125 ) ) * ( 0.5 - fracIndex );
				__targetProps.x = spanRight + fracIndex * spanWidth;
				__targetProps.y = _sideSign * ( 
									  App.H * 0.5
									+ MathF.lerp( G.CARD_H * 0.25, G.CARD_H * 0.45, POINT_Y )
									+ Math.abs( __targetProps.rotation ) * 320
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
		
		public function arrangeeeee():void
		{
			if (cardsParent == null)
				return;
			
			const X:Number = this.x - PADDING_X - G.CARD_W * .5;
			const Y:Number = this.y;
			const NUM_CARDS:int = list.cardsCount;
			const FOCUSED_CARD_INDEX:int = list.indexOfCard(_focusedCard);
			
			const TIMIDNESS:Number = Math.min(1.0, Math.max(0.0, _sideSign * Math.pow(_pointerXY.y / yLimClose, 2.0)));
			const UNFOLDED:Boolean = _isOpen && selectedCard == null;
			
			var o:CardSprite;
			var i:int = NUM_CARDS;
			
			_cardsOffsetX = 0.0;
			_cardSpacing = 30.0;
			
			if (active || CONFIG::development)
				//if ( active )
			{
				if (UNFOLDED)
				{
					_cardSpacing = MathF.lerp(1.0, 0.8, TIMIDNESS) * (maxWidth - G.CARD_W) / (NUM_CARDS - 1);
					//_cardsOffsetX = -Number.max( 0.0, _cardPointerX ) * MathF.lerp( 0.0, 0.2, TIMIDNESS ) * ( maxWidth - G.CARD_W ) / ( NUM_CARDS - 1 ) -120;
					if (isNaN(_cardsOffsetX))
						_cardsOffsetX = 0.0;
				}
				else
				{
					_cardSpacing = MathF.lerp(35.0, 45.0, Math.pow(1.0 - _pointerXY.y / App.H, 2.5));
				}
				
				if (_cardSpacing > MAX_CARD_SPACING)
					_cardSpacing = MAX_CARD_SPACING;
			}
			
			var upness:Number;
			var upnezz:Number;
			
			while (--i >= 0)
			{
				o = list.getCardAt(i).sprite;
				
				if (o.isSelected)
				{
					__targetProps.x = -App.W * .33;
					__targetProps.y = 0.0;
					__targetProps.rotation = 0.0;
					__targetProps.scale = 1.25;
				}
				else
				{
					__targetProps.scale = 1.00;
					
					upness = 0.0;
					upnezz = 0.0;
					
					if (FOCUSED_CARD_INDEX >= 0)
					{
						//upness = _cardPointerX - i;
						upness = 1.0 - Math.abs(upness) / 2.0;
						upness = (upness - 0.50) / 0.50;
						upness = Number.max(0.0, upness);
						upnezz = curveNormal(upness, 9.0);
						upness = curveNormal(upness, 5.0);
							//o.setTitle( upness.toFixed( 3 ) );
					}
					
					/// Rotation
					
					if (UNFOLDED)
					{
						__targetProps.rotation = (NUM_CARDS * .5 - i - .5) * (.05 + NUM_CARDS * .0125 / NUM_CARDS);
						__targetProps.rotation = MathF.lerp(__targetProps.rotation, 0.0, upness);
					}
					else
					{
						__targetProps.rotation = _sideSign * (NUM_CARDS * .5 - i - .5) * (.02 + NUM_CARDS * .0025 / NUM_CARDS);
					}
					
					/// X
					
					if (_focusedCard == null || !UNFOLDED)
					{
						__targetProps.x = _cardsOffsetX + X - (i * _cardSpacing);
					}
					else
					{
						const xLeftOrFocused:Number = (X - i * _cardSpacing) - (G.CARD_W * .5 * (1.0 - i / NUM_CARDS));
						const xRight:Number = (X - i * _cardSpacing) + (G.CARD_W * .5 * (i / NUM_CARDS));
						const ratio:Number = (FOCUSED_CARD_INDEX < i) ? 1.0 : upnezz;
						__targetProps.x = MathF.lerp(xRight, xLeftOrFocused, ratio) + _cardsOffsetX;
					}
					
					/// Y
					
					if (UNFOLDED)
					{
						__targetProps.y = MathF.lerp(calcY_Unfocused(), calcY_Focused(), upness);
						function calcY_Focused():Number
						{
							return Y - _sideSign * G.CARD_H * .55
						}
						function calcY_Unfocused():Number
						{
							return Y + _sideSign * Math.abs(__targetProps.rotation) * 2000 / NUM_CARDS + TIMIDNESS * 80
						}
					}
					else
					{
						const TINY_OFFSET:Number = -(active && selectedCard == null ? (_sideSign * Math.pow(1.0 - _pointerXY.y / App.H, 2.5) * 40) : 0.0)
						__targetProps.y = this.y + _sideSign * G.CARD_H * .4 + _sideSign * Math.abs(__targetProps.rotation) * 400 / NUM_CARDS + TINY_OFFSET;
					}
					
					///
					if (!cardsParent.contains(o))
						cardsParent.addChild(o);
				}
				
				///
				o.tween.to(__targetProps.x, __targetProps.y, __targetProps.rotation, __targetProps.scale);
				
				function curveNormal(frac:Number, pow:Number):Number
				{
					return frac < 0.5 ? (0.5 * Math.pow(2.0 * frac, pow)) : (1.0 + 0.5 * Math.pow(2.0 * frac - 2.0, pow))
				}
			}
		}
		
		public function arrange_SIMPLE():void
		{
			if (cardsParent == null)
				return;
			
			var targetProps:TargetProps = new TargetProps();
			
			const X:Number = this.x - PADDING_X - G.CARD_W * .5;
			//const Y:Number = this.y - _sideSign * G.CARD_H * .5;
			const Y:Number = this.y;
			const NUM_CARDS:int = list.cardsCount;
			
			var o:CardSprite;
			var i:int = NUM_CARDS;
			
			if (_isOpen)
				_cardSpacing = (maxWidth - G.CARD_W) / (NUM_CARDS - 1);
			else
				_cardSpacing = 40.0;
			
			if (_cardSpacing > MAX_CARD_SPACING)
				_cardSpacing = MAX_CARD_SPACING;
			
			while (--i >= 0)
			{
				o = list.getCardAt(i).sprite;
				
				/// Rotation
				
				if (_isOpen)
				{
					targetProps.rotation = (NUM_CARDS * .5 - i - .5) * (.05 + NUM_CARDS * .0125 / NUM_CARDS);
				}
				else
				{
					targetProps.rotation = (NUM_CARDS * .5 - i - .5) * (.02 + NUM_CARDS * .0025 / NUM_CARDS);
				}
				//targetProps.rotation = 0;
				
				/// X
				
				if (_focusedCard == null)
				{
					targetProps.x = X - i * _cardSpacing;
				}
				else
				{
					var iFocused:int = list.indexOfCard(_focusedCard);
					targetProps.x = (iFocused <= i) ? (X - i * _cardSpacing) - (G.CARD_W * .5 * (1.0 - i / NUM_CARDS)) : (X - i * _cardSpacing) + (G.CARD_W * .5 * (i / NUM_CARDS));
				}
				
				/// Y
				
				if (_isOpen)
				{
					targetProps.y = Y;
					if (_focusedCard != null && o == _focusedCard.sprite)
					{
						targetProps.y -= _sideSign * G.CARD_H * .50;
						targetProps.rotation = .0;
					}
					targetProps.y += _sideSign * Math.abs(targetProps.rotation) * 2000 / NUM_CARDS;
				}
				else
				{
					targetProps.y = this.y + _sideSign * G.CARD_H * .4 + _sideSign * Math.abs(targetProps.rotation) * 400 / NUM_CARDS;
				}
				
				///
				cardsParent.addChild(o);
				
				///
				o.tween.to(targetProps.x, targetProps.y, targetProps.rotation, targetProps.scale);
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