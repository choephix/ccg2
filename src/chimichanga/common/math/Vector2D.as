package chimichanga.common.math
{
	
	
	public class Vector2D
	{
		public static const ZERO:Vector2D	= new Vector2D( 0.0, 0.0, true );
		
		private var mX:Number;
		private var mY:Number;
		private var mLocked:Boolean;
		public function Vector2D( x:Number=0.0, y:Number=0.0, locked:Boolean=false )
		{
			setTo( x, y );
			mLocked = locked;
		}
		
		public function setTo( x:Number = 0.0, y:Number = 0.0 ):void
		{
			mX = x;
			mY = y;
		}
		
		public function get x():Number { return mX; }
		public function set x(value:Number):void { if ( mLocked ) throw new Error( "You cannot modify a locked instance of Vector2D" ); mX = value; }
		public function get y():Number { return mY; }
		public function set y(value:Number):void { if ( mLocked ) throw new Error( "You cannot modify a locked instance of Vector2D" ); mY = value; }
		public function get locked():Boolean { return mLocked; }
	}

}