package chimichanga.common.misc
{
	
	
	public class Color
	{
		
		public var r:Number;
		public var g:Number;
		public var b:Number;
		
		public function Color(){}
		
		public function setTo( r:Number, g:Number, b:Number ):Color
		{
			this.r = clip( r );
			this.g = clip( g );
			this.b = clip( b );
			return this;
		}
		
		public function getHex():uint
		{
			return uint( 0xFF * r ) * 0x10000 + uint( 0xFF * g ) * 0x100 + uint( 0xFF * b );
		}
		
		public function setHex( value:uint ):Color
		{
			this.r = clip(( value >> 16 & 0xFF ) / 0xFF );
			this.g = clip(( value >> 8 & 0xFF ) / 0xFF );
			this.b = clip(( value & 0xFF ) / 0xFF );
			return this;
		}
		
		public function add( c:Color ):Color
		{
			this.r = clip( r + c.r );
			this.g = clip( g + c.g );
			this.b = clip( b + c.b );
			return this;
		}
		
		public function getBrightness():Number
		{
			return Math.sqrt(( r * r * 0.241 ) + ( g * g * 0.691 ) + ( b * b * 0.068 ) );
		}
		
		private static function clip( n:Number ):Number
		{
			if ( n > 1.0 )
				return 1.0;
			if ( n < 0.0 )
				return 0.0;
			return n;
		}
	
	}

}