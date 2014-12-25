package ecs.components 
{
	import chimichanga.common.display.Sprite;
	import ecs.core.Entity;
	import ecs.core.IComponent;
	import ecs.core.Entity;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class SpriteModel extends Sprite implements IComponent, IModelComponent
	{
		private var _entity:Entity;
		private var _enabled:Boolean;
		
		public function SpriteModel() 
		{
			super();
		}
		
		public function onAddedToEntity(entity:Entity):void 
		{
			_entity = entity;
			entity.world.graphics.addChild( this );
		}
		
		public function onRemovedFromEntity():void 
		{
			_entity = null;
			removeFromParent( true );
		}
		
		public function advanceTime( timeDelta:Number ):void 
		{
			
		}
		
		public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
		}
		
		public function get entity():Entity 
		{
			return _entity;
		}
		
	}

}