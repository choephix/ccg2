package chimichanga.debug.graphs
{
	import chimichanga.common.display.LinearGradientQuad;
	import flash.geom.Point;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	
	public class Graph extends DisplayObjectContainer
	{
		
		private var _sizeX:int;
		private var _sizeY:int;
		private var _width:Number;
		private var _height:Number;
		private var _barWidth:Number;
		private var _barColor:uint;
		private var _bars:Vector.<Quad>;
		private var _barsData:Vector.<String>;
		private var _markers:Vector.<Quad>;
		private var _background:Quad;
		private var _backtainer:Sprite;
		private var _container:Sprite;
		private var _overtainer:Sprite;
		private var _backgroundLabel:TextField;
		
		private var _helperPoint:Point;
		private var _selector:Quad;
		private var _bubble:GraphTextBubble;
		
		public function Graph( sizeX:int, sizeY:int, width:Number = 640, height:Number = 320 )
		{
			
			_sizeX = sizeX;
			_sizeY = sizeY;
			
			_height = height;
			_width = width;
			
			//
			
			_barWidth = 0.5;
			_barColor = 0xEE7711; /// 0x224488
			
			_bars = new Vector.<Quad>( sizeX );
			_barsData = new Vector.<String>();
			_markers = new Vector.<Quad>();
			
			_background = new LinearGradientQuad( 0x000011, 0x000A19 );
			addChild( _background );
			
			_backgroundLabel = new TextField( _width, _height, "", "Arial Black", 32, 0x0077FF, true );
			_backgroundLabel.alpha = 0.10;
			_backgroundLabel.hAlign = HAlign.RIGHT;
			_backgroundLabel.vAlign = VAlign.TOP;
			addChild( _backgroundLabel );
			
			_backtainer = new Sprite();
			addChild( _backtainer );
			_container = new Sprite();
			addChild( _container );
			_overtainer = new Sprite();
			addChild( _overtainer );
			
			onSizeUpdate();
			
			_helperPoint = new Point();
			addEventListener( TouchEvent.TOUCH, onTouch );
		
		}
		
		private function onSizeUpdate():void
		{
			
			_background.width = _width;
			_background.height = _height;
			
			_backgroundLabel.width = _width;
			_backgroundLabel.height = _height;
			
			_container.y = _height;
			_container.scaleX = _width / _sizeX;
			_container.scaleY = _height / _sizeY;
			
			_backtainer.y = _container.y;
			_backtainer.scaleX = _container.scaleX;
			_backtainer.scaleY = _container.scaleY;
			
			_overtainer.y = _container.y;
			_overtainer.scaleX = _container.scaleX;
			_overtainer.scaleY = _container.scaleY;
		
		}
		
		public function reset():void
		{
			
			clearMarkers();
			resetValuesOnly();
		
		}
		
		//{ VALUES
		
		public function getValue( aX:int, aY:int ):Number
		{
			
			if ( _bars.length <= aX || _bars[ aX ] == null )
			{
				return 0.0;
			}
			return _bars[ aX ].height;
		
		}
		
		public function setValue( aX:int, aY:int, clr:int = -1, alpha:Number = 1.0 ):void
		{
			
			if ( aX > _sizeX )
			{
				_sizeX = aX;
				onSizeUpdate();
			}
			
			if ( aY > _sizeY )
			{
				_sizeY = aY;
				onSizeUpdate();
			}
			
			if ( _bars.length <= aX )
			{
				_bars.length = aX + 1;
			}
			var bar:Quad;
			if ( _bars[ aX ] == null )
			{
				bar = new Quad( 1, 1, _barColor );
				bar.alignPivot( "left", "bottom" );
				bar.width = _barWidth;
				bar.x = aX + 0.5 * ( 1.0 - _barWidth );
				_container.addChild( bar );
				_bars[ aX ] = bar;
			}
			else
			{
				bar = _bars[ aX ];
			}
			bar.height = aY;
			bar.color = clr >= 0 ? clr : _barColor;
			bar.alpha = alpha;
		
		}
		
		public function resetValuesOnly():void
		{
			
			clearMarkers();
			
			for ( var i:int = 0; i <= _sizeX; i++ )
			{
				setValue( i, 0.0, _barColor, 1.0 );
			}
		
		}
		
		//}
		
		//{ MARKERS
		
		public function mark( aX:Number, clr:int = 0xCC0033, width:Number = 0.05, alpha:Number = 0.5 ):void
		{
			//var marker:Quad = new Quad( width, _sizeY, clr );
			var marker:LinearGradientQuad = new LinearGradientQuad( clr, clr, alpha, 0.0, LinearGradientQuad.DIRECTION_LEFT );
			marker.alignPivot( "left", "bottom" );
			marker.width = 1.0;
			marker.height = _sizeY;
			marker.x = aX;
			marker.alpha = alpha;
			_backtainer.addChild( marker );
			_markers.push( marker );
		}
		
		public function clearMarkers():void
		{
			while ( _markers.length > 0 )
			{
				_markers.pop().removeFromParent( true );
			}
		}
		
		//}
		
		//{ DATA
		
		public function setData( aX:int, data:Object ):void
		{
			
			if ( aX >= _barsData.length )
			{
				_barsData.length = aX + 1;
			}
			
			_barsData[ aX ] = data == null ? null : String( data );
		
		}
		
		private function onTouch( e:TouchEvent ):void
		{
			
			var t:Touch = e.getTouch( this );
			
			hideBubble();
			hideSelector()
			
			//if ( t == null || _barsData.length == 0 ) {
			if ( t == null )
			{
				return;
			}
			
			var aX:int = Math.floor( t.getLocation( _container, _helperPoint ).x );
			
			if ( aX < 0 )
			{
				return;
			}
			
			if ( _selector == null )
			{
				_selector = new Quad( 1, _sizeY, 0xFfFfFf );
				_selector.alpha = 0.25;
				_selector.alignPivot( HAlign.LEFT, VAlign.BOTTOM );
				_overtainer.addChild( _selector );
			}
			else
			{
				_selector.visible = true;
				_selector.height = _sizeY;
			}
			_selector.x = aX;
			
			if ( _barsData.length <= aX || _barsData[ aX ] == null )
			{
				return;
			}
			
			if ( _bubble == null )
			{
				_bubble = new GraphTextBubble( 400, 200 );
				addChild( _bubble );
			}
			_bubble.visible = true;
			_bubble.x = Math.floor( aX * _width / _sizeX );
			_bubble.pivotX = _bubble.width * aX / _sizeX;
			_bubble.text = _barsData[ aX ];
			
			function hideBubble():void
			{
				if ( _bubble != null )
				{
					_bubble.visible = false;
				}
			}
			
			function hideSelector():void
			{
				if ( _selector != null )
				{
					_selector.visible = false;
				}
			}
		
		}
		
		//}
		
		//{ PUBLIC GETTERS & SETTERS
		
		override public function get name():String
		{
			return _backgroundLabel.text;
		}
		
		override public function set name( value:String ):void
		{
			_backgroundLabel.text = value;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set width( value:Number ):void
		{
			_width = value;
			onSizeUpdate();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		override public function set height( value:Number ):void
		{
			_height = value;
			onSizeUpdate();
		}
		
		public function get barWidth():Number
		{
			return _barWidth;
		}
		
		public function set barWidth( value:Number ):void
		{
			_barWidth = value;
		}
	
		//}
	
	}

}