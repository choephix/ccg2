package editor 
{
	import chimichanga.common.display.Sprite;
	import editor.SpaceObject;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	import flash.geom.Point;
	import flash.text.TextFormat;
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
		public static var txtfTitle:TextFormat = new TextFormat( "Verdana", 15, 0x330814, true );
		public static var txtfDescr:TextFormat = new TextFormat( "Arial", 12, 0x330814, false );
		public static var txtfExtra:TextFormat = new TextFormat( "Arial", 32, 0x330814, true );
		public static const PADDING:Number = 6;
		
		public var targetX:Number;
		public var targetY:Number;
		
		private var thingParent:Sprite;
		private var border:Quad;
		private var pad:Quad;
		private var tTitle:TextField;
		private var tDescr:TextField;
		private var tExtra:TextField;
		private var iFaction:Quad;
		
		public var data:CardData;
		
		private var _type:int;
		
		private var _focused:Boolean;
		private var _selected:Boolean;
		private var _inDrag:Boolean;
		private var _isOnTop:Boolean;
		
		private static var helperPoint:Point = new Point();
		
		public function initialize( data:CardData ):void
		{
			this.data = data == null ? new CardData() : data;
			
			thingParent = new Sprite();
			thingParent.x = .5 * G.CARD_W;
			thingParent.y = .5 * G.CARD_H;
			addChild( thingParent );
			
			border = new Quad( G.CARD_W + 2, G.CARD_H + 2, 0x0, true );
			border.x = -1;
			border.y = -1;
			border.alpha = .3;
			border.touchable = false;
			addChild( border );
			
			pad = new Quad( G.CARD_W, G.CARD_H, 0xB0B0B0, true );
			pad.alpha = .99;
			addChild( pad );
			
			tTitle = new TextField( 1, 1, "", txtfTitle.font, txtfTitle.size as Number, txtfTitle.color as uint, txtfTitle.bold  );
			tTitle.scaleX = .80;
			//tTitle.border = true;
			tTitle.x = PADDING;
			tTitle.y = 0;
			tTitle.width = ( G.CARD_W - PADDING - PADDING ) / tTitle.scaleX;
			tTitle.height = 22;
			tTitle.touchable = false;
			addChild( tTitle );
			
			tDescr = new TextField( 1, 1, "", txtfDescr.font, txtfDescr.size as Number, txtfDescr.color as uint, txtfDescr.bold  );
			tDescr.vAlign = "top";
			//tDescr.border = true;
			tDescr.x = PADDING;
			tDescr.y = tTitle.y + tTitle.height;
			tDescr.width = G.CARD_W - PADDING - PADDING;
			tDescr.height = G.CARD_H - PADDING - tDescr.y;
			tDescr.touchable = false;
			addChild( tDescr );
			
			tExtra = new TextField( 1, 1, "", txtfExtra.font, txtfExtra.size as Number, txtfExtra.color as uint, txtfExtra.bold  );
			tExtra.hAlign = "left";
			//tExtra.border = true;
			tExtra.width  = 100;
			tExtra.height = 50;
			tExtra.x = 0;
			tExtra.y = G.CARD_H - tExtra.height;
			tExtra.touchable = false;
			addChild( tExtra );
			
			iFaction = new Quad( 15, tTitle.height, 0x0, true );
			iFaction.x = G.CARD_W - iFaction.width;
			iFaction.y = 0;
			addChild( iFaction );
			
			addEventListener( EnterFrameEvent.ENTER_FRAME, advanceTime );
			addEventListener( TouchEvent.TOUCH, onTouch );
			
			onDataChange();
		}
		
		//
		
		public function onDataChange():void 
		{
			tTitle.text = data.name;
			tDescr.text = data.description;
			
			if ( data.type == CardType.TRAP )
			{
				tExtra.text = "";
				tExtra.visible = false;
			}
			else 
			{
				tExtra.visible = true;
				tExtra.text = data.power.toString();
			}
			
			type = data.type;
			
			iFaction.color = Faction.toColor( data.faction );
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var t:Touch;
			t = e.getTouch( this );
			
			setFocused( t != null && t.phase != TouchPhase.ENDED );
			
			if ( t == null || t.phase == TouchPhase.ENDED )
			{
				if ( inDrag )
				{
					targetX = x;
					targetY = y;
					inDrag = false;
				}
				else
				if ( _isOnTop && !_selected && t != null && t.phase == TouchPhase.ENDED )
				{
					setSelected( true );
				}
				return;
			}
			
			if ( t.phase == TouchPhase.MOVED && !_selected )
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
			
			border.alpha = lerp( border.alpha, _focused ? .99 : .3, G.DAMP1 );
		}
		
		private function setFocused( value:Boolean ):void 
		{
			if ( _focused == value )
				return;
			
			_focused = value;
		}
		
		public function setSelected( value:Boolean ):void 
		{
			if ( _selected == value )
				return;
			
			_selected = value;
			
			if ( value )
			{
				if ( context.selectedCard )
				{
					context.cardThing.saveDataTo( context.selectedCard );
					context.selectedCard.setSelected( false );
				}
				
				context.selectedCard = this;
				
				helperPoint.setTo( .5 * G.CARD_W, .5 * G.CARD_H );
				localToGlobal( helperPoint, helperPoint );
				context.cardThing.x = helperPoint.x;
				context.cardThing.y = helperPoint.y;
				context.cardThing.visible = true;
				context.cardThing.loadDataFrom( this );
			}
			else
			if ( context.selectedCard == this )
			{
				context.selectedCard = null;
				context.cardThing.visible = false;
			}
		}
		
		public function hasTag( tag:String ):Boolean
		{
			return data.tags.indexOf( tag ) > -1;
		}
		
		//
		///
		//
		
		override public function set height( value:Number ):void
		{
			throw new Error( "Hey!" );
		}
		
		override public function set width( value:Number ):void
		{
			throw new Error( "Hey!" );
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
		
		//
		
		public function get type():int 
		{
			return _type;
		}
		
		public function set type(value:int):void 
		{
			var i:int;
			_type = value;
			pad.color = CardType.toColor( _type );
		}
		
		public function get isOnTop():Boolean 
		{
			return _isOnTop;
		}
		
		public function set isOnTop(value:Boolean):void 
		{
			_isOnTop = value;
			tTitle.visible = value;
			tDescr.visible = value;
			tExtra.visible = value && tExtra.text != "";
		}
	}
}