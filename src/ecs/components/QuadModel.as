package ecs.components 
{
	import starling.display.Quad;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class QuadModel extends SpriteModel 
	{
		public var quad:Quad;
		
		public function QuadModel( width:Number, height:Number, color:uint=16777215 ) 
		{
			quad = new Quad( width, height, color );
			quad.alignPivot( HAlign.CENTER, VAlign.BOTTOM );
			addChild( quad );
		}
		
	}

}