package chimichanga.global.utils 
{
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.errors.AbstractClassError;
	
	public class DisplayObjects 
	{
		
        /** Helper object. */
		private static var sHelperRect:Rectangle = new Rectangle();
		
        /** @private */
        public function DisplayObjects() { throw new AbstractClassError(); }
		
		/** Calls the alignPivot() method of the target DisplayObject, 
		 * then compensates by repositioning it so that it appears in
		 * the same place as before. */
		public static function alignPivotButKeepInPlace( target:DisplayObject, hAlign:String = "center", vAlign:String = "center" ):void
		{
			sHelperRect.copyFrom( target.bounds );
			target.alignPivot( hAlign, vAlign );
			target.x = sHelperRect.x - target.bounds.x;
			target.y = sHelperRect.y - target.bounds.y;
		}
		
		/** Modifies the texture-coordinates of an image so that it tiles 
		 * a specified number of times horisontally as well as vertically. 
		 * 
		 *  It's ok to use non-integers, e.g. to tile an image * 1.5 times. */
		public static function setImageTextureTiling( image:Image, tileX:Number = 1.0, tileY:Number = 1.0 ):Image
		{
			image.texture.repeat = true;
			image.setTexCoordsTo( 0, 0.0,	0.0		);
			image.setTexCoordsTo( 1, tileX,	0.0		);
			image.setTexCoordsTo( 2, 0.0,	tileY	);
			image.setTexCoordsTo( 3, tileX,	tileY	);
			return image;
		}
		
		/** Offsets the texture in an image. You can use it to scroll
		 * a texture horisontally or vertically.
		 * ! WARNING: Does not stack with setImageTextureTiling() ! */
		public static function setImageTextureOffset( image:Image, offsetX:Number = 0.0, offsetY:Number = 0.0 ):Image
		{
			image.texture.repeat = true;
			image.setTexCoordsTo( 0, offsetX,		offsetY			);
			image.setTexCoordsTo( 1, offsetX + 1.0,	offsetY			);
			image.setTexCoordsTo( 2, offsetX,		offsetY + 1.0	);
			image.setTexCoordsTo( 3, offsetX + 1.0,	offsetY + 1.0	);
			return image;
		}
		
	}

}