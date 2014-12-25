package spatula
{
	import chimichanga.common.misc.Color;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class AdvancedColors
	{
		
		private static var sHelperColor:Color = new Color();
		
		public static function hexToXYZArray( color:uint ):Object
		{
			var c:Color = sHelperColor.setHex( color );
			
			// adjusting values
			if ( c.r > 0.04045 )
			{
				c.r = ( c.r + 0.055 ) / 1.055;
				c.r = Math.pow( c.r, 2.4 );
			}
			else
			{
				c.r = c.r / 12.92;
			}
			if ( c.g > 0.04045 )
			{
				c.g = ( c.g + 0.055 ) / 1.055;
				c.g = Math.pow( c.g, 2.4 );
			}
			else
			{
				c.g = c.g / 12.92;
			}
			if ( c.b > 0.04045 )
			{
				c.b = ( c.b + 0.055 ) / 1.055;
				c.b = Math.pow( c.b, 2.4 );
			}
			else
			{
				c.b = c.b / 12.92;
			}
			
			c.r *= 100;
			c.g *= 100;
			c.b *= 100;
			
			// applying the matrix
			var r:Object = {};
			r.x = c.r * 0.4124 + c.g * 0.3576 + c.b * 0.1805;
			r.y = c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722;
			r.z = c.r * 0.0193 + c.g * 0.1192 + c.b * 0.9505;
			return r;
		}
		
		public static function hexToLabArray( color:uint ):Object
		{
			var o:Object = hexToXYZArray( color );
			
			o.x = o.x / 95.047;
			o.y = o.y / 100;
			o.z = o.z / 108.883;
			
			// adjusting the values
			if ( o.x > 0.008856 )
			{
				o.x = Math.pow( o.x, 1 / 3 );
			}
			else
			{
				o.x = 7.787 * o.x + 16 / 116;
			}
			if ( o.y > 0.008856 )
			{
				o.y = Math.pow( o.y, 1 / 3 );
			}
			else
			{
				o.y = ( 7.787 * o.y ) + ( 16 / 116 );
			}
			if ( o.z > 0.008856 )
			{
				o.z = Math.pow( o.z, 1 / 3 );
			}
			else
			{
				o.z = 7.787 * o.z + 16 / 116;
			}
			
			var r:Object = {};
			r.l = 116 * o.y - 16;
			r.a = 500 * ( o.x - o.y );
			r.b = 200 * ( o.y - o.z );
			return r;
		}
		
		/**
		 * Supposedly should return the difference between color 1 and 2 in dE (CIE's unit for
		 * difference between colors). Ported from Emanuele Feronato's blog, I have none of
		 * the competence needed to determine if it works well. Use at your own risk.
		 */
		public static function labDiff( color1:uint, color2:uint ):Number
		{
			var lab1:Object = hexToLabArray( color1 );
			var lab2:Object = hexToLabArray( color2 );
			
			var c1:Number = Math.sqrt( lab1.a * lab1.a + lab1.b * lab1.b );
			var c2:Number = Math.sqrt( lab2.a * lab2.a + lab2.b * lab2.b );
			var dc:Number = c1 - c2;
			var dl:Number = lab1.l - lab2.l;
			var da:Number = lab1.a - lab2.a;
			var db:Number = lab1.b - lab2.b;
			//var dh:Number = Math.sqrt(( da * da ) + ( db * db ) - ( dc * dc ) );
			var dh:Number = (da * da) + (db * db) - (dc * dc);
				if (dh < 0) { dh = 0; } else { dh = Math.sqrt(dh); }
			var first:Number = dl;
			var second:Number = dc / ( 1 + 0.045 * c1 );
			var third:Number = dh / ( 1 + 0.015 * c1 );
			
			return ( Math.sqrt( first * first + second * second + third * third ) );
		}
	
	}

}