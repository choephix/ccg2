package ecs.core {
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class World implements IAnimatable
	{
		public var graphics:Sprite;
		public var camera:Camera;
		
		public var entitiesHead:Entity;
		public var entitiesTail:Entity;
		
		public function World()
		{
			graphics = new Sprite();
			Starling.current.stage.addChild( graphics );
			
			camera = new Camera( graphics, graphics.stage.stageWidth, graphics.stage.stageHeight );
			
			graphics.addChild( new Quad( 5000, -5000, 0x111111 ) );
			graphics.addChild( new Quad( -5000, 5000, 0x111111 ) );
		}
		
		public function destroy():void
		{
			var o:Entity = entitiesHead;
			while ( o != null ) {
				o.destroy();
			}
		}
		
		//{ OBJECTS MANAGEMENT
		
		public function addObject( o:Entity ):void 
		{
			if ( o.world == this )
				return;
			if ( o.world != null ) 
				o.world.removeObject( o );
			
			if ( entitiesHead == null )
				entitiesHead = o;
			else
				entitiesTail.next = o;
			o.prev = entitiesTail;
			entitiesTail = o;
			
			o.onAddedToWorld( this );
			o.addEventListener( EntityEvents.DESTROYED, onObjectDestroyed );
		}
		
		public function removeObject( o:Entity ):void
		{
			if ( o.prev )
				o.prev.next = o.next;
			if ( o.next )
				o.next.prev = o.prev;
			o.onRemovedFromWorld();
		}
		
		private function onObjectDestroyed(e:Event):void
		{
			removeObject( e.currentTarget as Entity );
		}
		
		//}
		
		//{
		
		public function advanceTime(time:Number):void 
		{
			var o:Entity = entitiesHead;
			while ( o != null ) {
				o.advanceTime( time );
				// UPDATE GRAPHICS (if any)
				if ( o.model == null ) continue;
				if ( o.transform == null ) continue;
				if ( !o.transform.dirty ) continue;
				o.model.x =  o.transform.x;
				o.model.y = -o.transform.y;
				o.model.scaleX = o.transform.scaleX;
				o.model.scaleY = o.transform.scaleY;
				o.model.rotation = o.transform.rotation;
				o = o.next;
			}
		}
		
		//}
		
	}

}