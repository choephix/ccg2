package editor 
{
	import chimichanga.common.display.Sprite;
	import editor.SpaceObject;
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
		public static var FORMAT_TITLE:TextFormat = new TextFormat( "Verdana", 15, 0x330814, true );
		public static var FORMAT_DESCR:TextFormat = new TextFormat( "Arial", 12, 0x330814, false );
		public static var FORMAT_EXTRA:TextFormat = new TextFormat( "Arial", 32, 0x330814, true );
		public static const PADDING:Number = 6;
		
		public var targetX:Number;
		public var targetY:Number;
		public var currentGroup:CardGroup;
		
		private var thingParent:Sprite;
		private var border:Quad;
		private var pad:Quad;
		private var padTitle:Quad;
		private var tTitle:TextField;
		private var tDescr:TextField;
		private var tExtra:TextField;
		private var tSlug:TextField;
		private var iFaction:Quad;
		private var marker:Quad;
		
		public var data:CardData;
		
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
			
			//padTitle = new Quad( G.CARD_W, 22, 0xFfFfFf, true );
			padTitle = new Quad( G.CARD_W, G.CARD_H-22, 0xFfFfFf, true );
			padTitle.alpha = .09;
			padTitle.y = 22
			addChild( padTitle );
			
			tTitle = new TextField( 1, 1, "", FORMAT_TITLE.font, FORMAT_TITLE.size as Number, FORMAT_TITLE.color as uint, FORMAT_TITLE.bold  );
			//tTitle.border = true;
			tTitle.x = 0;
			tTitle.y = 0;
			tTitle.height = 22;
			tTitle.touchable = false;
			addChild( tTitle );
			
			tDescr = new TextField( 1, 1, "", FORMAT_DESCR.font, FORMAT_DESCR.size as Number, FORMAT_DESCR.color as uint, FORMAT_DESCR.bold  );
			tDescr.vAlign = "top";
			//tDescr.border = true;
			tDescr.x = PADDING;
			tDescr.y = tTitle.y + tTitle.height;
			tDescr.width = G.CARD_W - PADDING - PADDING;
			tDescr.height = G.CARD_H - PADDING - tDescr.y;
			tDescr.autoScale = true;
			tDescr.touchable = false;
			addChild( tDescr );
			
			tExtra = new TextField( 1, 1, "", FORMAT_EXTRA.font, FORMAT_EXTRA.size as Number, FORMAT_EXTRA.color as uint, FORMAT_EXTRA.bold  );
			tExtra.hAlign = "left";
			//tExtra.border = true;
			tExtra.width  = 100;
			tExtra.height = 50;
			tExtra.x = 0;
			tExtra.y = G.CARD_H - tExtra.height;
			tExtra.touchable = false;
			addChild( tExtra );
			
			tSlug = new TextField( 150, 1, "", FORMAT_TITLE.font, 9, 0x330814, false  );
			tSlug.hAlign = "right";
			tSlug.vAlign = "bottom";
			tSlug.x = 0;
			tSlug.y = 184;
			tSlug.height = 16;
			tSlug.autoScale = true;
			tSlug.touchable = false;
			tSlug.text = data.slug;
			addChild( tSlug );
			//CONFIG::sandbox { tSlug.removeFromParent() }
			
			iFaction = new Quad( 5, tTitle.height, 0x0, true );
			iFaction.x = G.CARD_W - iFaction.width;
			iFaction.y = 0;
			addChild( iFaction );
			
			marker = new Quad( pad.width, 10, 0x0 );
			marker.alignPivot();
			marker.x = .5 * pad.width;
			marker.y = .5 * pad.height;
			marker.rotation = -.33 * Math.PI;
			marker.alpha = .5;
			marker.visible = false;
			addChild( marker );
			
			addEventListener( EnterFrameEvent.ENTER_FRAME, advanceTime );
			addEventListener( TouchEvent.TOUCH, onTouch );
			
			onDataChange();
		}
		
		//
		
		public function onDataChange():void 
		{
			tTitle.width = 1000;
			tTitle.text = CONFIG::sandbox ? data.slug : data.name;
			tTitle.width = Math.max( tTitle.textBounds.width + PADDING + PADDING, G.CARD_W );
			tTitle.scaleX = Math.min( 1.0, G.CARD_W / tTitle.width );
			
			tDescr.text = data.prettyDescription;
			tDescr.height = G.CARD_H - tDescr.y - ( data.type == CardType.TRAP_NORMAL ? PADDING : 30);
			
			tSlug.text = CONFIG::sandbox ? data.name : data.slug;
			
			if ( CardType.isTrap( data.type ) )
				tExtra.visible = false;
			else 
				tExtra.text = data.power.toString();
			
			pad.color = CardType.toColor( data.type );
			
			iFaction.visible = data.faction != null;
			if ( iFaction.visible )
				iFaction.color = Faction.toColor( data.faction );
				
			tDescr.visible = _isOnTop && tDescr.text != "";
			tExtra.visible = _isOnTop && tExtra.text != "";
			tSlug.visible = _isOnTop && tSlug.text != "";
			
			marker.visible = data.mark > 0;
			if ( marker.visible )
				marker.color = data.mark;
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
					if ( currentGroup.isContracted )
						return;
					
					setSelected( true );
					context.cardThing.animateIn();
					
					t.getLocation( stage, helperPoint );
					context.cardThing.setFocus( helperPoint );
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
			
			helperPoint.setTo( 0, 0 );
			localToGlobal( helperPoint, helperPoint );
			visible = helperPoint.y < stage.stageHeight && helperPoint.y > -G.CARD_H;
		}
		
		private function setFocused( value:Boolean ):void 
		{
			if ( _focused == value )
				return;
			
			_focused = value;
			
			if ( value ) 
				context.focusedCard = this;
			else
			if ( context.focusedCard == this )
				context.focusedCard = null;
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
		
		public function get isOnTop():Boolean 
		{
			return _isOnTop;
		}
		
		public function set isOnTop(value:Boolean):void 
		{
			_isOnTop = value;
			tTitle.visible = value;
			tDescr.visible = value && tDescr.text != "";
			tExtra.visible = value && tExtra.text != "";
			tSlug.visible = value && tSlug.text != "";
		}
	}
}