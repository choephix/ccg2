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
			g.tformContracted.y = 100;
			g.tformContracted.x = 40 + groups.length * 160;
			addChild( g );
			groups.push( g );
		}
		
		public function removeGroup( g:CardGroup ):void
		{
			g.view = null;
			removeChild( g );
			groups.splice( groups.indexOf( g ), 1 );
		}
		
		public function arrangeGroups():void 
		{
			var g:CardGroup;
			var x:Number = 40;
			var y:Number = 40;
			for ( var i:int = 0; i < groups.length; i++ ) 
			{
				g = groups[ i ];
				
				if ( x > _space.width - 200 )
				{
					x = 40;
					y += 300;
				}
				g.tformContracted.x = x;
				g.tformContracted.y = y;
				
				x += 160;
			}
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
			
			var gi:int;
			var ci:int;
			var c:Card;
			var g:CardGroup;
			for ( ci = 0; ci < _space.cards.length; ci++ )
			{
				c = _space.cards[ ci ];
				g = groups[ 0 ];
				for ( gi = 1; gi < groups.length; gi++ )
					if ( groups[ gi ].registeredCards.indexOf( c.data.id ) > -1 )
						g = groups[ gi ];
				g.addCard( c );
			}
			for ( gi = 1; gi < groups.length; gi++ )
				groups[ gi ].sortCards( sortF );
			
			function sortF( a:Card, b:Card ):int
			{ return groups[ gi ].registeredCards.indexOf( a.data.id ) - groups[ gi ].registeredCards.indexOf( b.data.id ) }
		}
		
	}

}