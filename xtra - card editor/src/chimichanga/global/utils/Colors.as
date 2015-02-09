package chimichanga.global.utils
{
	import chimichanga.common.misc.Color;
	import starling.errors.AbstractClassError;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Colors
	{
		
		private static var sHelperColor:Color = new Color();
		
        /** @private */
        public function Colors() { throw new AbstractClassError(); }
		
		/**
		 * Directly convert from Red, Green, and Blue values to Hex.
		 * @param r the Red value (0-1)
		 * @param g the Green value (0-1)
		 * @param b the Blue value (0-1)
		 * @return the Hex value of the specified RGB color
		 */
		public static function fromRGB( r:Number, g:Number, b:Number ):uint
		{
			return sHelperColor.setTo( r, g, b ).getHex();
		}
		
		/**
		 * Returns a value between 0.0 and 1.0 representing the brightness of the
		 * color as typically percieved by the human eye.
		 */
		public static function determineBrightness( color:uint ):Number {
			return sHelperColor.setHex( color ).getBrightness();
		}
		
		/**
		 * Returns a hexedemical representation of a gray color
		 * @param	brightness - a number from 0 to 1 denoting the brightness 
		 * 			of the returned gray color (from black to white respectively)
		 * @return	returns a hexedemical representation of a gray color
		 */
		public static function getGrayColor( brightness:Number ):uint
		{
			return sHelperColor.setTo( brightness, brightness, brightness ).getHex();
		}
		
		/**
		 * Returns the negative version of a given color value
		 */
		public static function getNegativeOf( color:uint ):uint
		{
			return 0xFFFFFF ^ color;
		}
		
	}

}


