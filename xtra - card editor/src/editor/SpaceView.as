package editor
{
	import chimichanga.common.display.Sprite;
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class SpaceView extends Sprite
	{
		public const groups:Vector.<CardGroup> = new Vector.<CardGroup>();
		private var _space:Space;
		private var _active:Boolean;
		
		public function SpaceView( space:Space, defaultGroup:CardGroup )
		{
			this._space = space;
			
			defaultGroup.locked = true;
			defaultGroup.name = "--";
			addGroup( defaultGroup );
		}
		
		public function addGroup( g:CardGroup ):void
		{
			g.view = this;
			g.tformContracted.y = .5 * ( _space.height - 300 );
			g.tformContracted.x = 90 + groups.length * 180;
			addChild( g );
			groups.push( g );
		}
		
		public function removeGroup( g:CardGroup ):void
		{
			g.view = null;
			removeChild( g );
			groups.splice( groups.indexOf( g ), 1 );
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function set active( value:Boolean ):void
		{
			_active = value;
			
			Starling.juggler.removeTweens( this );
			Starling.juggler.tween( this, .200, { y : value ? .0 : _space.height } );
			Starling.juggler.tween( this, .200, { alpha : value ? 1 : 0 } );
			
			//for ( gi = 0; gi < groups.length; gi++ )
				//groups[ gi ].visible = value;
			var gi:int;
			var ci:int;
				
			var c:Card;
			var g:CardGroup;
			for ( ci = 0; ci < _space.cards.length; ci++ )
			{
				c = _space.cards[ ci ];
				g = groups[ 0 ];
				for ( gi = 1; gi < groups.length; gi++ )
					if ( c.hasTag( groups[ gi ].tag ) )
						g = groups[ gi ];
				g.addCard( c );
			}
			
		}
		
	}

}