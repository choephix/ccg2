package duel 
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import chimichanga.common.display.Sprite;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	
	public class Background extends Sprite implements IAnimatable
	{
		public var onClickedCallback:Function;
		
		private var a1:Image;
		private var a2:Image;
		private var b1:Image;
		private var b2:Image;
		
		private var age:Number = 0.0;
		private var assets:AdvancedAssetManager;
		
		public function Background( assets:AdvancedAssetManager ) 
		{
			this.assets = assets;
			
			var img:Image;
			img = assets.generateImage( "bg", true );
			img.width = App.W;
			img.height = App.H;
			addChild( img );
			
			//a1 = generateThing( 1 );
			//a2 = generateThing( 1 );
			//b1 = generateThing( 2 );
			//b1.blendMode = BlendMode.ADD;
			//b2 = generateThing( 2 );
			//b2.blendMode = BlendMode.ADD;
			
			Starling.juggler.add( this );
			
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		public function generateThing( variation:int ):Image
		{
			var o:Image;
			o = assets.generateImage( "perlin" + variation, true );
			o.width = App.W;
			o.height = App.H;
			addChild( o );
			return o;
		}
		
		public function advanceTime( time:Number ):void 
		{
			age += time * 100;
			
			//const T1:Number = .03;
			//const T2:Number = .52;
			//a1.x = ( T1 * age  ) % App.W;
			//a2.x = ( T1 * age  ) % App.W - App.W;
			//b1.x = ( T2 * age  ) % App.W;
			//b2.x = ( T2 * age  ) % App.W - App.W;
		}
		
		private function onTouch( e:TouchEvent ):void 
		{
			var t:Touch = e.getTouch( this );
			
			if ( t == null ) return;
			
			if ( t.phase == TouchPhase.ENDED )
				if ( onClickedCallback != null )
					onClickedCallback();
		}
		
		override public function get width():Number { return App.W }
		override public function get height():Number { return App.H }
	}
}