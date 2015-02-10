package editor
{
	import chimichanga.common.display.Sprite;
	import chimichanga.debug.logging.error;
	import editor.SpaceObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import other.EditorEvents;
	import other.InputEvents;
	import starling.display.Quad;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import ui.OButton;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardGroup extends SpaceObject
	{
		private static const TITLE_H:Number = 20;
		private static const CARD_SPACING:Number = 10;
		
		public var tag:String = "";
		public var view:SpaceView;
		
		private var bg:Quad;
		private var titlePad:Quad;
		private var b1:OButton;
		private var b2:OButton;
		private var b3:OButton;
		private var b4:OButton;
		private var b5:OButton;
		private var titleLabel:TextField;
		private var titleContainer:Sprite;
		private var cardsContainer:Sprite;
		private var cardsParent:Sprite;
		
		private var _cardsScroll:Number = .0;
		private var _focused:Boolean;
		
		public var tformExpanded:CardGroupTransform;
		public var tformContracted:CardGroupTransform;
		public var tformMaximized:CardGroupTransform;
		public var tformCurrent:CardGroupTransform;
		
		private static var helperPoint:Point = new Point();
		
		public function initialize( tag:String ):void
		{
			this.tag = tag;
			
			bg = new Quad( 100, 100, 0x505A60, true );
			//bg.alpha = .0;
			addChild( bg );
			
			cardsContainer = new Sprite();
			cardsContainer.clipRect = new Rectangle();
			addChild( cardsContainer );
			
			cardsParent = new Sprite();
			cardsParent.x = CARD_SPACING;
			cardsParent.y = CARD_SPACING;
			cardsContainer.addChild( cardsParent );
			
			//
			
			titleContainer = new Sprite();
			titleContainer.x = 0;
			titleContainer.y = -TITLE_H;
			addChild( titleContainer );
			
			titlePad = new Quad( 100, TITLE_H, 0x589CD3 );
			titlePad.alpha = .25;
			titleContainer.addChild( titlePad );
			
			titleLabel = new TextField( titlePad.width, titlePad.height, tag?tag:"?", "Lucida Console", 16, 0xFFFFFF, true );
			titleLabel.x = titleContainer.x;
			titleLabel.y = titleContainer.y;
			titleLabel.touchable = false;
			addChild( titleLabel );
			
			b1 = new OButton( "-", onButtonToggleExpanded );
			b1.y = .5 * TITLE_H;
			titleContainer.addChild( b1 );
			
			b2 = new OButton( "^", onButtonToggleMaximized );
			b2.y = .5 * TITLE_H;
			titleContainer.addChild( b2 );
			
			b3 = new OButton( "<>", onButtonResize );
			titleContainer.addChild( b3 );
			
			b4 = new OButton( "+", onButtonAdd );
			b4.x = 20;
			b4.y = .5 * TITLE_H;
			titleContainer.addChild( b4 );
			
			b5 = new OButton( "o", onButtonSort );
			b5.x = 60;
			b5.y = .5 * TITLE_H;
			titleContainer.addChild( b5 );
			
			//
			
			addEventListener( EnterFrameEvent.ENTER_FRAME, advanceTime );
			addEventListener( TouchEvent.TOUCH, onTouch );
			App.input.addEventListener( InputEvents.MOUSE_WHEEL, onMouseWheel );
			space.addEventListener( EditorEvents.CARD_DRAG_START, onCardDragStart );
			space.addEventListener( EditorEvents.CARD_DRAG_STOP, onCardDragStop );
			
			tformContracted = new CardGroupTransform();
			tformContracted.width = G.CARD_W + CARD_SPACING + CARD_SPACING;
			tformContracted.height = G.CARD_H + CARD_SPACING + CARD_SPACING;
			tformExpanded = new CardGroupTransform();
			tformExpanded.width = 500;
			tformExpanded.height = 500;
			tformExpanded.x = .5 * ( App.STAGE_W - tformExpanded.width );
			tformExpanded.y = .5 * ( App.STAGE_H - tformExpanded.height );
			tformMaximized = new CardGroupTransform();
			tformMaximized.y = TITLE_H;
			tformCurrent = tformContracted;
			
			//
			setExpanded( false );
		}
		
		private function onCardDragStart( e:Event ):void 
		{
			if ( cardsParent.contains( e.data as Card ) )
				removeCard( e.data as Card )
		}
		
		private function onCardDragStop( e:Event ):void 
		{
			arrange();
			
			var c:Card = e.data as Card;
			if ( c.parent != space )
				return;
			if ( !bg.getBounds( space ).intersects( c.getBounds( space ) ) )
				return;
			
			cardsParent.globalToLocal( c.parent.localToGlobal( new Point( c.x, c.y ) ), helperPoint );
			helperPoint.x += .5 * c.width;
			helperPoint.y += .5 * c.height;
			var columns:int = Math.round( ( cardsParent.width - CARD_SPACING ) / ( G.CARD_W + CARD_SPACING ) );
			var index:int = 
				Math.floor( helperPoint.y / ( G.CARD_H + CARD_SPACING ) ) * columns + 
				Math.floor( helperPoint.x / ( G.CARD_W + CARD_SPACING ) );
			
			if ( index >= countCards )
			{
				error( "index much large" );
				index = countCards;
			}
			
			addCard( c, index );
			arrange();
		}
		
		private function advanceTime( e:EnterFrameEvent ):void 
		{
			tformMaximized.width = App.STAGE_W;
			tformMaximized.height = App.STAGE_H - tformMaximized.y;
			
			bg.alpha = lerp( bg.alpha, _focused ? .67 : .33, G.DAMP1 );
			titleContainer.alpha = lerp( titleContainer.alpha, _focused ? 1.0 : .0, G.DAMP2 );
			titleLabel.alpha = lerp( titleLabel.alpha, _focused ? 1.0 : .4, G.DAMP1 );
			
			b2.visible = tformCurrent != tformContracted;
			b3.visible = tformCurrent == tformExpanded;
			b4.visible = tformCurrent != tformContracted;
			b5.visible = tformCurrent != tformContracted;
			
			x = lerp( x, tformCurrent.x, G.DAMP3 );
			y = lerp( y, tformCurrent.y + view.y, G.DAMP2 );
			width  = lerp( width, tformCurrent.width, G.DAMP2 );
			height = lerp( height, tformCurrent.height, G.DAMP1 );
			
			cardsParent.y = lerp( cardsParent.y, CARD_SPACING - ( tformCurrent == tformContracted ? .0 : _cardsScroll ), G.DAMP1 );
			
			//titleContainer.y = lerp( titleContainer.y, tformCurrent == tformContracted ? height : -TITLE_H, G.DAMP3 );
			//titleLabel.y = titleContainer.y;
		}
		
		private function onMouseWheel( e:Event ):void 
		{
			if ( !_focused ) return;
			if ( tformCurrent == tformContracted ) return;
			
			setCardsScroll( _cardsScroll - Number( e.data ) * G.CARD_H / 6 );
		}
		
		private function onTouch( e:TouchEvent ):void 
		{
			setFocused( e.interactsWith( this ) );
			
			var t:Touch;
			
			if ( tformCurrent == tformExpanded )
			{
				t = e.getTouch( titlePad, TouchPhase.ENDED );
				
				if ( t != null && t.tapCount > 1 )
				{
					if ( tformExpanded.height == tformMaximized.height )
					{
						setExpanded( false );
					}
					else
					{
						tformExpanded.y = tformMaximized.y;
						tformExpanded.height = tformMaximized.height;
					}
					return;
				}
				
				t = e.getTouch( titlePad, TouchPhase.MOVED );
				
				if ( t == null )
					t = e.getTouch( bg, TouchPhase.MOVED );
					
				if ( t != null )
				{
					t.getMovement( parent, helperPoint );
					x += helperPoint.x;
					y += helperPoint.y;
					if ( x < 0 ) x = 0;
					if ( y < tformMaximized.y ) y = tformMaximized.y;
					if ( x > space.width - tformExpanded.width ) x = space.width - tformExpanded.width;
					if ( y > space.height - tformExpanded.height ) y = space.height - tformExpanded.height;
					tformExpanded.x = x;
					tformExpanded.y = y;
					return;
				}
				
				t = e.getTouch( b3, TouchPhase.MOVED );
				
				if ( t != null )
				{
					t.getMovement( parent, helperPoint );
					width  += helperPoint.x;
					height += helperPoint.y;
					if ( width > tformMaximized.x + tformMaximized.width - x ) width = tformMaximized.x + tformMaximized.width - x;
					if ( height > tformMaximized.y + tformMaximized.height - y ) height = tformMaximized.y + tformMaximized.height - y;
					tformExpanded.width = width;
					tformExpanded.height = height;
					arrange();
					return;
				}
			}
			
			if ( tformCurrent == tformMaximized )
			{
				t = e.getTouch( titlePad, TouchPhase.ENDED );
				
				if ( t != null && t.tapCount > 1 )
				{
					setExpanded( false );
					return;
				}
				
				t = e.getTouch( bg, TouchPhase.MOVED );
					
				if ( t != null )
				{
					t.getMovement( parent, helperPoint );
					setCardsScroll( _cardsScroll - 4 * helperPoint.y );
				}
				
			}
			
			if ( tformCurrent == tformContracted )
			{
				t = e.getTouch( titlePad, TouchPhase.ENDED );
				
				if ( t != null && t.tapCount > 1 )
				{
					setExpanded( true );
					return;
				}
				
				t = e.getTouch( titlePad, TouchPhase.MOVED );
				
				if ( t != null )
				{
					t.getMovement( parent, helperPoint );
					x += helperPoint.x;
					y += helperPoint.y;
					tformContracted.x = x;
					tformContracted.y = y;
					return;
				}
			}
		}
		
		private function onButtonToggleExpanded():void
		{
			setExpanded( tformCurrent == tformContracted );
		}
		
		private function onButtonToggleMaximized():void
		{
			setMaximized( tformCurrent != tformMaximized );
		}
		
		private function onButtonResize():void
		{
			arrange();
		}
		
		private function onButtonAdd():void
		{
			addCard( space.generateNewCard() );
		}
		
		private function onButtonSort():void 
		{
			cardsParent.sortChildren( SortFunctions.byType );
			arrange();
		}
		
		//
		
		public function addCard( c:Card, index:int=-1 ):Card
		{
			if ( index > -1 )
				cardsParent.addChildAt( c, countCards-index );
			else
				cardsParent.addChild( c );
			c.space = space;
			c.x -= x;
			c.y -= y;
			arrange();
			return c;
		}
		
		private function removeCard( c:Card ):void 
		{
			c.x += x;
			c.y += y;
			c.isOnTop = true;
			space.addChild( c );
		}
		
		private function arrange():void 
		{
			if ( countCards == 0 )
				return;
			
			var x:Number = .0;
			var y:Number = .0;
			var c:Card;
			for ( var i:int = countCards - 1; i >= 0; i-- ) 
			{
				c = cardsParent.getChildAt( i ) as Card;
				
				if ( tformCurrent == tformContracted )
				{
					y = 3 * ( countCards - i );
					c.targetX = x;
					c.targetY = y;
					
					c.isOnTop = i == countCards - 1;
				}
				else
				{
					if ( x + G.CARD_W > ccW )
					{
						x = .0;
						y += G.CARD_H + CARD_SPACING;
					}
					c.targetX = x;
					c.targetY = y;
					x += G.CARD_W + CARD_SPACING; 
					
					c.isOnTop = true;
				}
			}
			
			tformContracted.height = 3 * countCards + G.CARD_H + CARD_SPACING + CARD_SPACING;
		}
		
		public function get countCards():int
		{
			return cardsParent.numChildren;
		}
		
		//
		
		private function setFocused( value:Boolean ):void 
		{
			if ( _focused == value )
				return;
			
			_focused = value;
			
			if ( value )
				context.focusedGroup = this;
			else
			if ( context.focusedGroup == this )
				context.focusedGroup = null;
			
			if ( value )
				parent.setChildIndex( this, parent.numChildren - 1 );
		}
		
		private function setCardsScroll( value:Number ):void 
		{
			if ( value < 0 )
				value = 0;
			if ( value > cardsParent.height - G.CARD_H )
				value = cardsParent.height - G.CARD_H;
			_cardsScroll = value;
		}
		
		private function setExpanded( value:Boolean ):void 
		{
			setMaximized( false );
			tformCurrent = value ? tformExpanded : tformContracted;
			arrange();
		}
		
		private function setMaximized( value:Boolean ):void 
		{
			tformCurrent = value ? tformMaximized : tformExpanded;
			arrange();
		}
		
		//
		
		override public function get hasVisibleArea():Boolean
		{
			return bg.hasVisibleArea;
		}
		
		public function get color():uint
		{
			return bg.color;
		}
		
		public function set color( value:uint ):void
		{
			bg.color = value;
		}
		
		override public function get width():Number
		{
			return bg.width;
			return tformCurrent.width;
		}
		
		override public function set width( value:Number ):void
		{
			bg.width = value;
			titlePad.width = value;
			titleLabel.width = value;
			b1.x = value - 20;
			b2.x = b1.x - 40;
			b3.x = value;
			cardsContainer.clipRect.width = value;
		}
		
		override public function get height():Number
		{
			return bg.height;
			return tformCurrent.height;
		}
		
		override public function set height( value:Number ):void
		{
			bg.height = value;
			b3.y = value - 20;
			cardsContainer.clipRect.height = value;
		}
		
		public function get ccW():Number 
		{
			return tformCurrent.width - CARD_SPACING - CARD_SPACING;
		}
		
		public function get ccH():Number 
		{
			return tformCurrent.height - CARD_SPACING - CARD_SPACING;
		}
		
	}
	
}