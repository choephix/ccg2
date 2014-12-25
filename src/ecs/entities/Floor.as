package ecs.entities 
{
	import ecs.components.BoxBounds;
	import ecs.components.QuadModel;
	import ecs.components.Transform;
	import ecs.core.Entity;
	import ecs.core.World;
	/**
	 * ...
	 * @author choephix
	 */
	public class Floor extends Entity
	{
		
		override public function onAddedToWorld(world:World):void 
		{
			super.onAddedToWorld(world);
			addComponent( new Transform() );
			addComponent( new QuadModel( 1000, -500, 0x223366 ) );
			addComponent( new BoxBounds( -500, 500, 0, 500 ) );
		}
		
	}

}