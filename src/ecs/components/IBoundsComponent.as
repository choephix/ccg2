package ecs.components 
{
	
	/**
	 * ...
	 * @author choephix
	 */
	public interface IBoundsComponent 
	{
		function get xLeft():Number 
		function get xRight():Number 
		function get yTop():Number 
		function get yBottom():Number 
		
		function get xLeftLocal():Number 
		function get xRightLocal():Number 
		function get yTopLocal():Number 
		function get yBottomLocal():Number 
	}
	
}