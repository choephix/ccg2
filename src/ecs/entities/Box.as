package ecs.entities 
{
	import chimichanga.global.utils.MathF;
	import ecs.components.BoxBounds;
	import ecs.components.QuadModel;
	import ecs.components.Transform;
	import ecs.core.Entity;
	import ecs.core.World;
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Box extends Entity 
	{
		private var quad:Quad;
		private var asleep:Boolean;
		
		override public function onAddedToWorld(world:World):void 
		{
			const SIZE:Number = 30;
			
			super.onAddedToWorld(world);
			addComponent( new Transform() );
			//addComponent( new PointBounds() );
			addComponent( new BoxBounds( -SIZE/2, SIZE/2, SIZE, 0 ) );
			quad = QuadModel( addComponent( new QuadModel( SIZE, SIZE, 0xFF0040 ) ) ).quad;
			
			x = MathF.random( 300, -300 );
			y = MathF.random( 600,  500 );
		}
		
		override public function advanceTime(time:Number):void 
		{
			super.advanceTime(time);
			
			if ( asleep )
				return;
			
			y -= time * 400;
			
			//if ( bounds.yBottom <= 0.0 ) {
				//y = 0.0;
				////destroy();
				//return;
			//}
			
			quad.color = 0x99FF00;
			
			for ( var o:Entity = world.entitiesHead; o != null; o = o.next ) 
			{
				if ( o == this ) continue;
				if ( bounds.xLeft >= o.bounds.xRight ) continue;
				if ( bounds.xRight <= o.bounds.xLeft ) continue;
				if ( bounds.yBottom > o.bounds.yTop ) continue;
				if ( bounds.yTop < o.bounds.yTop ) continue;
				y = o.bounds.yTop + bounds.yBottomLocal;
				quad.color = 0x990022;
				asleep = true;
			}
			
		}
		
	}

}