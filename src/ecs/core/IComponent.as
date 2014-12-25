package ecs.core 
{
	
	/**
	 * ...
	 * @author choephix
	 */
	public interface IComponent 
	{
		function advanceTime( timeDelta:Number ):void
		function onAddedToEntity( entity:Entity ):void
		function onRemovedFromEntity():void
		function get entity():Entity
		function get enabled():Boolean
		function set enabled( value:Boolean ):void
	}
	
}