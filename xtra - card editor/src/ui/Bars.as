package ui 
{
	import chimichanga.common.display.Sprite;
	import starling.display.Quad;
	/**
	 * ...
	 * @author choephix
	 */
	public class Bars extends Sprite
	{
		private var barW:Number;
		private var barH:Number;
		private var bars:Vector.<Quad> = new Vector.<Quad>();
		
		public function Bars( barW:Number, barH:Number, count:int, color:uint )
		{
			this.barH = barH;
			this.barW = barW;
			
			var bar:Quad;
			for ( var i:int = 0; i < count; i++ ) 
			{
				bar = new Quad( barW, barH, color );
				bar.x = 0;
				bar.y = i * ( barH + 2 );
				bars.push( bar );
				addChild( bar );
			}
		}
		
		public function setValue( value:int ):void
		{
			for ( var i:int = 0; i < bars.length; i++ ) 
				bars[ i ].visible = i < value;
		}
	}
}