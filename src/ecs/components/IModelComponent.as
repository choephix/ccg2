package ecs.components 
{
	import chimichanga.common.display.Sprite;
	
	/**
	 * ...
	 * @author choephix
	 */
	public interface IModelComponent 
	{
		function get x():Number 
		function set x(value:Number):void 
		function get y():Number 
		function set y(value:Number):void 
		function get scaleX():Number 
		function set scaleX(value:Number):void 
		function get scaleY():Number 
		function set scaleY(value:Number):void 
		function get rotation():Number 
		function set rotation(value:Number):void 
		function get visible():Boolean 
		function set visible(value:Boolean):void 
	}
	
}