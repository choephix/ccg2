package temp {
	
	/**
	 * ...
	 * @author choephix
	 */
	public class RoughTrigonometryLUT {
		
		private var steps:uint;
		private var table:Vector.<Number>;
		
		/**
		 * Lookup table for trigonomtric function results. Pass a math function expecting one argument - an angle in radians, and optionally number of steps. A full circle of 360 deggrees will be split into this number of steps , and a value from mathFunctionCallback for the angle at each of those steps will be saved in the table. E.g if you pass Math.sin and 360, you will have an accurate sinus value for every 1 whole degree.
		 * @param	mathFunctionCallback	must accept an angle value in radians, like Math.sin() or Math.cos(). Return values for angles from 0 to PI*2 from that function will be stored in the table.
		 * @param	steps					More means more accurate but a longer lookup-table. Default 360.
		 */
		public function RoughTrigonometryLUT( mathFunctionCallback:Function, steps:uint = 360 ) {
			
			this.steps = steps;
			
			table = new Vector.<Number>( steps );
			
			populate( mathFunctionCallback );
		
		}
		
		private function populate( mathFunctionCallback:Function ):void {
			
			var step:Number = Math.PI * 2 / steps;
			
			for ( var i:int = 0; i < steps; i++ ) {
				
				table[ i ] = mathFunctionCallback( step * i );
				
			}
		
		}
		
		public function getValue( degree:int ):Number {
			
			return table[ degree % steps ];
			
		}
	
	}

}