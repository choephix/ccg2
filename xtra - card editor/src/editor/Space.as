package editor 

{
	import adobe.utils.CustomActions;
	import chimichanga.common.display.Sprite;
	import other.EditorEvents;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Space extends Sprite 
	{
		public const events:EditorEvents = new EditorEvents();
		
		public const cards:Vector.<Card> = new Vector.<Card>();
		public const views:Vector.<SpaceView> = new Vector.<SpaceView>( 9 );
		
		public var context:SpaceContext = new SpaceContext();
		
		private var viewLabel:TextField;
		
		public function Space() 
		{
			super();
			
			context.cardThing.space = this;
			
			viewLabel = new TextField( 200, 200, "0", "Consolas", 100, 0x909090, true );
			viewLabel.alignPivot();
			viewLabel.x = .5 * width;
			viewLabel.y = .5 * height;
			addChild( viewLabel );
			
			//
			var i:int;
			
			for ( i = 0; i < views.length; i++ )
				views[ i ] = generateNewSpaceView( i );
			
			views[ 0 ].addGroup( generateNewGroup( "type0" ) );
			views[ 0 ].addGroup( generateNewGroup( "type1" ) );
			views[ 0 ].addGroup( generateNewGroup( "type2" ) );
			views[ 0 ].addGroup( generateNewGroup( "type3" ) );
			
			addChild( context.cardThing );
			context.cardThing.visible = false;
			
			for ( i = 0; i < 88; i++ )
				generateNewCard();
			
			setView( 0 );
		}
		
		private function generateNewSpaceView( index:int ):SpaceView 
		{
			var v:SpaceView = new SpaceView( this, generateNewGroup( null ) );
			
			addChild( v );
			
			v.active = false;
			
			return v;
		}
		
		private function generateNewGroup( tag:String = null ):CardGroup 
		{
			var g:CardGroup;
			g = new CardGroup();
			g.space = this;
			addChild( g );
			g.initialize( tag );
			return g;
		}
		
		public function generateNewCard():Card
		{
			var d:CardData = new CardData();
			
			d.name = int( Math.random() * int.MAX_VALUE ).toString( 36 );
			d.type = Math.random() * 4;
			var i:int = Math.random() * 5;
			switch( i )
			{
				case 0: d.faction = Faction.SCIENCE; break;
				case 1: d.faction = Faction.NATURE; break;
				case 2: d.faction = Faction.MAGIC; break;
				default: d.faction = null;
			}
			d.power = Math.random() * 10.0;
			
			var c:Card = new Card();
			c.initialize( d );
			c.x = width * ( 0.25 + 0.50 * Math.random() );
			c.y = height * ( 0.25 + 0.50 * Math.random() );
			addChild( c );
			cards.push( c );
			return c;
		}
		
		public function setView( index:uint ):void 
		{
			if ( context.currentView == views[ index ] )
				return;
			
			viewLabel.text = String( index + 1 );
			
			if ( context.currentView != null )
				context.currentView.active = false;
			
			context.currentView = views[ index ];
			
			if ( context.currentView != null )
				context.currentView.active = true;
		}
		
		//
		
		override public function get width():Number 
		{
			return App.STAGE_W;
		}
		
		override public function set width(value:Number):void 
		{
			throw new Error( "Don't do that!" );
		}
		
		override public function get height():Number 
		{
			return App.STAGE_H;
		}
		
		override public function set height(value:Number):void 
		{
			throw new Error( "Don't do that!" );
		}
	}
}