package ecs.core
{
	
	/**
	 * ...
	 * @author choephix
	 */
	public class ComponentBase implements IComponent
	{
		private var _entity:Entity;
		private var _enabled:Boolean;
		
		public function advanceTime(timeDelta:Number):void {}
		
		public function onAddedToEntity( entity:Entity ):void{ _entity = entity; }
		public function onRemovedFromEntity():void { _entity = null;  }
		public function get entity():Entity {return _entity;}
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void { _enabled = value; }
	}

}