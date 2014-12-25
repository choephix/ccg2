package ecs.core {
	import ecs.components.IBoundsComponent;
	import ecs.components.IModelComponent;
	import ecs.components.Transform;
	import ecs.core.Entity;
	import ecs.core.IComponent;
	import starling.events.EventDispatcher;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Entity extends EventDispatcher
	{
		public var next:Entity;
		public var prev:Entity;
		
		protected var components:Vector.<IComponent>;
		protected var componentsCount:int;
		
		protected var initialized:Boolean;
		
		public function Entity()
		{
			components = new Vector.<IComponent>();
		}
		
		//{ 
		
		public function initialize():void
		{
			initialized = true;
		}
		
		public function destroy():void
		{
			var c:IComponent;
			while ( componentsCount > 0 )
			{
				c = components[0];
				removeComponent( c );
			}
			
			dispatchEventWith( EntityEvents.DESTROYED );
		}
		
		public function advanceTime( time:Number ):void 
		{
			for (var i:int = 0; i < componentsCount; i++) 
			{
				components[i].advanceTime( time );
			}
		}
		
		//}
		
		//{ COMPONENTS
		
		public function addComponent( component:IComponent ):IComponent
		{
			if ( component.entity == this ) 
				return component;
			if ( component.entity != null ) 
				component.entity.removeComponent( component );
			
			componentsCount = components.push( component );
			component.onAddedToEntity( this );
			
			if ( component is IModelComponent ) _model = component as IModelComponent;
			if ( component is IBoundsComponent ) _bounds = component as IBoundsComponent;
			if ( component is Transform ) _transform = component as Transform;
			
			return component;
		}
		
		public function removeComponent( component:IComponent ):void
		{
			if ( component == _model ) _model = null;
			if ( component == _model ) _model = null;
			if ( component == _transform ) _transform = null;
			
			components.splice( components.indexOf( component ), 1 );
			componentsCount--;
			component.onRemovedFromEntity();
		}
		
		public function getComponent( type:Class ):IComponent
		{
			var i:int;
			for ( i = 0; i < componentsCount; i++ )
				if ( components[ i ] is type )
					return components[ i ];
			return null;
		}
		
		//}
		
		private var _world:World;
		private var _model:IModelComponent;
		private var _bounds:IBoundsComponent;
		private var _transform:Transform;
		
		public function onAddedToWorld(world:World):void
		{ 
			_world = world;
			initialize();
		}
		public function onRemovedFromWorld():void
		{ 
			_world = null; 
		}
		
		// SETTERS & GETTERS
		public function get world():World { return _world; }
		public function get model():IModelComponent { return _model; }
		public function get bounds():IBoundsComponent { return _bounds; }
		public function get transform():Transform { return _transform; }
		
		/* DELEGATE ecs.components.TransformComponent */
		
		public function get rotation():Number { return _transform.rotation; }
		public function set rotation(value:Number):void { _transform.rotation = value; }
		public function get x():Number { return _transform.x; }
		public function set x(value:Number):void { _transform.x = value; }
		public function get y():Number { return _transform.y; }
		public function set y(value:Number):void { _transform.y = value; }
		
	}

}