package editor 
{
	import editor.SpaceObject;
	import flash.geom.Point;
	import other.EditorEvents;
	import starling.display.Quad;
	import starling.events.EnterFrameEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Card extends SpaceObject 
	{
		public var targetX:Number;
		public var targetY:Number;
		
		private var q1:Quad;
		private var q2:Quad;
		private var t:TextField;
		
		private var _focused:Boolean;
		private var _inDrag:Boolean;
		
		private static var helperPoint:Point = new Point();
		
		public function Card() 
		{
			super();
			
			q1 = new Quad( 1, 1, 0x0, true );
			q1.x = -1;
			q1.y = -1;
			q1.alpha = .3;
			addChild( q1 );
			
			q2 = new Quad( 1, 1, 0xB0B0B0, true );
			addChild( q2 );
			
			t = new TextField( 1, 1, Math.random().toFixed(10) );
			t.bold = true;
			t.touchable = false;
			addChild( t );
			
			width  = G.CARD_W;
			height = G.CARD_H;
			
			addEventListener( EnterFrameEvent.ENTER_FRAME, advanceTime );
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch( q2 );
			
			setFocused( t != null && t.phase != TouchPhase.ENDED );
			
			if ( t == null || t.phase == TouchPhase.ENDED )
			{
				if ( inDrag )
				{
					targetX = x;
					targetY = y;
					inDrag = false;
				}
				return;
			}
			
			if ( t.phase == TouchPhase.MOVED )
			{
				inDrag = true;
				t.getMovement( parent, helperPoint );
				x += helperPoint.x;
				y += helperPoint.y;
				space.dispatchEventWith( 
					EditorEvents.CARD_DRAG_UPDATE, false, this );
			}
		}
		
		private function advanceTime( e:EnterFrameEvent ):void 
		{
			if ( !inDrag )
			{
				x = lerp( x, targetX, G.DAMP2 );
				y = lerp( y, targetY, G.DAMP3 );
			}
			
			t.alpha = lerp( t.alpha, _focused ? 1.0 : .7, G.DAMP1 );
			q1.alpha = lerp( q1.alpha, _focused ? 1.0 : .3, G.DAMP1 );
		}
		
		private function setFocused( value:Boolean ):void 
		{
			if ( _focused == value )
				return;
			
			_focused = value;
		}
		
		//
		///
		//
		
		public function get color():uint
		{
			return q2.color;
		}
		
		public function set color( value:uint ):void
		{
			q2.color = value;
		}
		
		override public function get height():Number
		{
			return q2.height;
		}
		
		override public function set height( value:Number ):void
		{
			q1.height = value + 2;
			q2.height = value;
			t.height = value;
		}
		
		override public function get width():Number
		{
			return q2.width;
		}
		
		override public function set width( value:Number ):void
		{
			q1.width = value + 2;
			q2.width = value;
			t.width = value;
		}
		
		public function get inDrag():Boolean 
		{
			return _inDrag;
		}
		
		public function set inDrag( value:Boolean ):void 
		{
			if ( _inDrag == value )
				return;
			
			_inDrag = value;
			space.dispatchEventWith( 
					value ? EditorEvents.CARD_DRAG_START : 
					EditorEvents.CARD_DRAG_STOP, false, this );
			if ( value )
				parent.setChildIndex( this, parent.numChildren - 1 );
			
			touchable = !value;
			alpha = value ? .8 : 1.0;
		}
	}
}