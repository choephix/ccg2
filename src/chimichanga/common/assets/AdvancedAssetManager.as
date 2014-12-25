package chimichanga.common.assets 
{
	import chimichanga.common.display.MultiStateDisplayObject;
	import chimichanga.common.display.MultiStateImage;
	import flash.system.Capabilities;
	import starling.animation.Juggler;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class AdvancedAssetManager extends AssetManager 
	{
		private var mAssetsReady:Boolean = false;
		
        /** Helper objects. */
        private static var sHelperVectorTextures:Vector.<Texture> = new Vector.<Texture>();
		
		public function AdvancedAssetManager( scaleFactor:Number=1, useMipmaps:Boolean=false ) 
		{
			
			super(scaleFactor, useMipmaps);
			verbose = Capabilities.isDebugger;
			
		}
		
		public function initialize( onProgressCallback:Function = null, onCompleteCallback:Function = null, ... assetsToEnqueue ):void 
		{
			
			if ( assetsReady )
			{
				error( "Assets were already loaded, wtf?" );
				onCompleteCallback();
				return;
			}
			
			enqueue.apply( null, assetsToEnqueue );
			loadQueue( onProgress );
			
			function onProgress( ratio:Number ):void 
			{
				if ( onProgressCallback != null )
				{
					onProgressCallback( ratio );
				}
				if ( ratio == 1 ) 
				{
					onAssetsReady();
					if ( onCompleteCallback != null ) 
					{
						onCompleteCallback();
					}
				}
			}
		}
		
		public function queueEmpty():Boolean 
		{
			
			return numQueuedAssets <= 0;
			
		}
		
		private function onAssetsReady():void 
		{
			mAssetsReady = true;
		}
		
		//{ GENERATORS 
		
		public function generateImageFromTexture( texture:Texture, touchable:Boolean = false, centerPivots:Boolean = false, name:String = null ):Image 
		{
			var image:Image;
			image = new Image( texture );
			image.name = name ? name : image.name;
			image.touchable = touchable;
			image.useHandCursor = touchable;
			if ( centerPivots )
				image.alignPivot();
			return image;
		}
		
		public function generateImage( name:String, touchable:Boolean = false, centerPivots:Boolean = false, atlas:String = null ):Image
		{
			var image:Image;
			image = generateImageFromTexture( atlas == null ? getTexture( name ) : getTextureAtlas( atlas ).getTexture( name ), touchable, centerPivots, name );
			return image;
		}
		
		public function generateMultiStateImage( states:*, touchable:Boolean = false, centerPivots:Boolean = false, juggler:Juggler = null, atlas:String = null ):Image
		{
			var image:MultiStateImage;
			
			if ( states is Vector.<Texture> ) 
				image = new MultiStateImage( states as Vector.<Texture> );
			else if ( states is Array ) 
			{
				for each ( var s:* in states as Array )
				{
					if ( s is Texture )
						sHelperVectorTextures.push( s as Texture );
					else if ( s is String )
						sHelperVectorTextures.push( atlas == null ? getTexture( s as String ) : getTextureAtlas( atlas ).getTexture( s as String ) );
				}
				image = new MultiStateImage( sHelperVectorTextures );
				sHelperVectorTextures.length = 0;
			}
			if ( juggler != null )
			{
				image.juggler = juggler;
			}
			image.touchable = touchable;
			image.useHandCursor = touchable;
			if ( centerPivots )
				image.alignPivot();
			return image;
		}
		
		public function generateMovieClipFromTextures( textures:Vector.<Texture> = null, touchable:Boolean = false, centerPivots:Boolean = false, framerate:Number = 30, juggler:Juggler = null, play:Boolean = false, name:String=null ):MovieClip 
		{
			var clip:MovieClip;
			clip = new MovieClip( textures, framerate );
			if ( juggler ) 
			{
				juggler.add( clip );
				if ( play )
					clip.play();
				else
					clip.stop();
			}
			clip.name = name ? name : clip.name;
			clip.touchable = touchable;
			clip.useHandCursor = touchable;
			if ( centerPivots )
				clip.alignPivot();
			return clip;
		}
		
		public function generateMovieClip( prefix:String, touchable:Boolean = false, centerPivots:Boolean = false, framerate:Number = 30, juggler:Juggler = null, play:Boolean = false, atlas:String = null ):MovieClip 
		{
			var clip:MovieClip;
			if ( atlas == null )
				getTextures( prefix, sHelperVectorTextures );
			else
				getTextureAtlas( atlas ).getTextures( prefix, sHelperVectorTextures );
			clip = generateMovieClipFromTextures( sHelperVectorTextures, touchable, centerPivots, framerate, juggler, play, prefix );
			sHelperVectorTextures.length = 0;
			return clip;
		}
		
		public function generateMultiStateMovieClip( states:*, touchable:Boolean = false, centerPivots:Boolean = false, framerate:Number = 30, juggler:Juggler = null, autorewind:Boolean=true, atlas:String = null ):MultiStateDisplayObject 
		{
			var clip:MultiStateDisplayObject;
			clip = new MultiStateDisplayObject( juggler );
			if ( states is Array || states is Vector.<*> ) 
			{
				for each ( var s:* in states )
				{
					if ( s is DisplayObject ) 
						clip.addState( s as DisplayObject );
					else if ( s is String )
						clip.addState( generateMovieClip( s as String, touchable, centerPivots, framerate, null, false, atlas ) );
				}
			}
			clip.autoplay = true;
			clip.autorewind = autorewind;
			clip.touchable = touchable;
			clip.useHandCursor = touchable;
			if ( centerPivots )
				clip.alignPivot();
			return clip;
		}
		
		//}
		
		public function hasTexture( name:String ):Boolean 
		{
			return getTexture( name ) != null;
		}
		
		public function hasTextureAtlas( name:String ):Boolean 
		{
			return getTextureAtlas( name ) != null;
		}
		
		//
		
		public function get assetsReady():Boolean 
		{
			return mAssetsReady;
		}
		
		private function error( msg:* ):void 
		{
			trace( "3: " + msg );
		}
		
	}

}