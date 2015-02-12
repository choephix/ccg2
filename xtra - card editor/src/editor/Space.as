package editor 

{
	import chimichanga.common.display.Sprite;
	import flash.ui.Keyboard;
	import other.EditorEvents;
	import other.InputEvents;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	import ui.StringInput;
	
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
		
		public function initialize( jsonData:String ):void 
		{
			var i:int;
			var j:int;
			
			// PREP
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			App.input.addEventListener( InputEvents.MIDDLE_CLICK, onMiddleClick );
			
			viewLabel = new TextField( 100, 100, "..", "Impact", 80, 0x909090, true );
			addChild( viewLabel );
			
			for ( i = 0; i < views.length; i++ )
				views[ i ] = generateNewSpaceView( i );
			
			context.cardThing.space = this;
			context.cardThing.visible = false;
			addChild( context.cardThing );
			
			// PARSE DATA
			
			var data:Object = JSON.parse( jsonData );
			
			var o:Object;
			
			var c:Card;
			var cd:CardData;
			for ( i = 0; i < data.cards.length; i++ ) 
			{
				o = data.cards[ i ];
				cd = new CardData();
				cd.id			= o.id;
				cd.name			= o.name;
				cd.slug			= o.slug;
				cd.description	= o.desc;
				cd.type			= CardType.fromInt( o.type );
				cd.faction		= Faction.fromInt( o.fctn );
				cd.power		= o.pwr;
				cd.tags			= o.tags;
				c = generateNewCard( cd );
			}
			
			var g:CardGroup;
			for ( j = 0; j < data.views.length; j++ ) 
			{
				for ( i = 0; i < data.views[ j ].groups.length; i++ ) 
				{
					o = data.views[ j ].groups[ i ];
					g = generateNewGroup( name );
					views[ j ].addGroup( g );
					
					g.registeredCards = o.cards;
					g.tformContracted.x = o.xc;
					g.tformContracted.y = o.yc;
					g.tformExpanded.x = o.xe;
					g.tformExpanded.y = o.ye;
					g.tformExpanded.width = o.we;
					g.tformExpanded.height = o.he;
				}
			}
			
			///
			onResize();
			setView( 0 );
		}
		
		public function onResize():void 
		{
			viewLabel.x = width - viewLabel.width;
			viewLabel.y = 0;
		}
		
		// VIEWS
		
		private function generateNewSpaceView( index:int ):SpaceView 
		{
			var v:SpaceView = new SpaceView( this, generateNewGroup( "" ) );
			addChild( v );
			v.active = false;
			return v;
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
		
		// CARD GROUPS
		
		public function generateNewGroup( name:String = null ):CardGroup 
		{
			var g:CardGroup;
			g = new CardGroup();
			g.space = this;
			addChild( g );
			g.initialize( name );
			return g;
		}
		
		public function deleteGroup( g:CardGroup ):void 
		{
			g.purgeCards();
			g.view.removeGroup( g );
			g.space = null;
			g.removeFromParent( true );
		}
		
		public function handleReleasedCard( c:Card ):void 
		{
			context.currentView.groups[ 0 ].addCard( c );
		}
		
		// CARDS
		
		public function generateNewCard( d:CardData = null ):Card
		{
			if ( d == null )
			{
				d = new CardData();
				d.id = cards.length;
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
			}
			
			var c:Card = new Card();
			c.initialize( d );
			c.x = width * ( 0.25 + 0.50 * Math.random() );
			c.y = height * ( 0.25 + 0.50 * Math.random() );
			addChild( c );
			cards.push( c );
			return c;
		}
		
		// INPUT HANDLERS
		
		private function onMiddleClick( e:Event ):void 
		{
			if ( context.focusedGroup )
				context.focusedGroup.setExpanded( context.focusedGroup.isContracted );
				
				//if ( context.focusedGroup.isContracted )
					//context.focusedGroup.setMaximized( true );
				//else
					//context.focusedGroup.setExpanded( false );
		}
		
		public function onKeyDown( e:KeyboardEvent ):void 
		{
			if ( e.ctrlKey )
			{
				var g:CardGroup = context.focusedGroup;
				
				// CHANGE VIEW
				if ( e.keyCode >= Keyboard.NUMBER_1 && e.keyCode <= Keyboard.NUMBER_9 )
					setView( e.keyCode - Keyboard.NUMBER_1 );
				else
				// ARRANGE VIEW
				if ( e.keyCode == Keyboard.SPACE )
				{
					context.currentView.arrangeGroups();
				}
				else
				if ( e.keyCode == Keyboard.X )
				{
					if ( g && !g.locked )
						g.purgeCards();
				}
				else
				if ( e.keyCode == Keyboard.R )
				{
					if ( g && !g.locked )
						StringInput.generate( stage, g.setName );
				}
				else
				if ( e.keyCode == Keyboard.F )
				{
					if ( g && !g.locked )
						StringInput.generate( stage, fFindByText );
					
					function fFindByText( txt:String ):void
					{
						for ( var i:int = 0; i < cards.length; i++ ) 
							if ( cards[ i ].data.hasText( txt.toLowerCase() ) )
								g.addCard( cards[ i ], 0 );
					}
				}
				else
				if ( e.keyCode == Keyboard.T )
				{
					if ( g && !g.locked )
						StringInput.generate( stage, fFindByText );
					
					function fFindByTag( tag:String ):void
					{
						for ( var i:int = 0; i < cards.length; i++ ) 
							if ( cards[ i ].data.hasTag( tag ) )
								g.addCard( cards[ i ], 0 );
					}
				}
				else
				// NEW CARD
				if ( e.keyCode == Keyboard.A )
				{
					var c:Card = generateNewCard();
					if ( g )
						g.addCard( c, -1, true );
				}
				else
				// NEW GROUP
				if ( e.keyCode == Keyboard.G )
				{
					context.currentView.addGroup( generateNewGroup() );
				}
				else
				// SORTING
				if ( e.keyCode == Keyboard.Q )
				{
					if ( g )
						g.sortCards( SortFunctions.byFaction );
				}
				else
				if ( e.keyCode == Keyboard.W )
				{
					if ( g )
						g.sortCards( SortFunctions.byType );
				}
				else
				if ( e.keyCode == Keyboard.E )
				{
					if ( g )
						g.sortCards( SortFunctions.byPower );
				}
				else
				// // // SAVE CHANGES // // //
				if ( e.keyCode == Keyboard.S )
				{
					App.remote.save( this );
				}
			}
		}
		
		//
		
		public function toJson():String
		{
			var i:int;
			var j:int;
			var o:Object;
			var r:Object = { };
			
			r.cards = new Array();
			
			var c:Card;
			for ( i = 0; i < cards.length; i++ ) 
			{
				c = cards[ i ];
				o = { };
				o.id   = c.data.id;
				o.name = c.data.name;
				o.slug = c.data.slug;
				o.desc = c.data.description;
				o.type = CardType.toInt( c.data.type );
				o.fctn = Faction.toInt( c.data.faction );
				o.pwr  = c.data.power;
				o.tags = c.data.tags;
				r.cards.push( o );
			}
			
			r.views = new Array();
			
			var g:CardGroup;
			for ( i = 0; i < views.length; i++ ) 
			{
				r.views.push( { } );
				r.views[ i ].groups = new Array();
				
				if ( views[ i ].groups.length <= 1 )
					continue;
				
				for ( j = 1; j < views[ i ].groups.length; j++ ) 
				{
					g = views[ i ].groups[ j ];
					o = { };
					o.name = g.name;
					o.xc = g.tformContracted.x;
					o.yc = g.tformContracted.y;
					o.xe = g.tformExpanded.x;
					o.ye = g.tformExpanded.y;
					o.we = g.tformExpanded.width;
					o.he = g.tformExpanded.height;
					o.cards = g.registeredCards;
					r.views[ i ].groups.push( o );
				}
			}
			
			return JSON.stringify( r );
		}
		
		//
		
		override public function get width():Number 
		{ return App.STAGE_W }
		
		override public function set width(value:Number):void 
		{ throw new Error( "Don't do that!" ) }
		
		override public function get height():Number 
		{ return App.STAGE_H }
		
		override public function set height(value:Number):void 
		{ throw new Error( "Don't do that!" ) }
	}
}