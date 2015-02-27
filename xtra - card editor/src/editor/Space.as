package editor 

{
	import chimichanga.common.display.Sprite;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.ui.Keyboard;
	import other.EditorEvents;
	import other.InputEvents;
	import other.Temp;
	import starling.animation.DelayedCall;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	import ui.MenuInput;
	import ui.StringInput;
	import ui.StringOutput;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Space extends Sprite 
	{
		public static var me:Space;
		
		public var nextCardID:int = 1;
		
		public const events:EditorEvents = new EditorEvents();
		
		public const cards:Vector.<Card> = new Vector.<Card>();
		public const views:Vector.<SpaceView> = new Vector.<SpaceView>( 9 );
		
		public var context:SpaceContext = new SpaceContext();
		
		private var viewLabel:TextField;
		private var viewNameLabel:TextField;
		private var statLabel:TextField;
		
		public function initialize( jsonData:String ):void 
		{
			me = this;
			
			// PREP
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			App.input.addEventListener( InputEvents.MIDDLE_CLICK, onMiddleClick );
			
			viewLabel = new TextField( 100, 100, "..", "Impact", 80, 0x909090, true );
			addChild( viewLabel );
			
			viewNameLabel = new TextField( 320, 50, "", "Impact", 24, 0x909090, false );
			addChild( viewNameLabel );
			
			statLabel = new TextField( 500, 200, "Waiting for stats update...", "Consolas", 14, 0x909090, false );
			statLabel.hAlign = "right";
			statLabel.vAlign = "bottom";
			addChild( statLabel );
			
			var dcall:DelayedCall = new DelayedCall( updateStats, 1.000 );
			dcall.repeatCount = 0;
			Starling.juggler.add( dcall );
			
			var i:int;
			var len:int;
			for ( i = 0, len = views.length; i < len; i++ )
				views[ i ] = generateNewSpaceView( i );
			
			context.cardThing.space = this;
			context.cardThing.visible = false;
			addChild( context.cardThing );
			
			// PARSE DATA
			
			initFromJson( JSON.parse( jsonData ) );
			
			for ( i = 0, len = cards.length; i < len; i++ )
			{
				cards[ i ].data.updatePrettyDescription();
				cards[ i ].onDataChange();
			}
			
			///
			onResize();
			setView( 0 );
		}
		
		public function onResize():void 
		{
			viewLabel.x = width - viewLabel.width;
			viewLabel.y = 0;
			viewNameLabel.x = .5 * ( width - viewNameLabel.width );
			viewNameLabel.y = height - viewNameLabel.height;
			statLabel.x = width - statLabel.width - 10;
			statLabel.y = height - statLabel.height - 10;
		}
		
		public function updateStats():void
		{
			statLabel.text = "Cards: " + cards.length;
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
			
			if ( context.currentView != null )
				context.currentView.active = false;
			
			context.currentView = views[ index ];
			viewLabel.text = String( index + 1 );
			viewNameLabel.text = context.currentView.name;
			
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
				d.id = nextCardID++;
				d.type = CardType.CREATURE_NORMAL;
			}
			
			var c:Card = new Card();
			c.initialize( d );
			c.x = width * ( 0.25 + 0.50 * Math.random() );
			c.y = height * ( 0.25 + 0.50 * Math.random() );
			addChild( c );
			cards.push( c );
			return c;
		}
		
		public function generateCardCopy( c:Card ):Card 
		{
			var d:CardData = c.data.clone( nextCardID++ );
			
			var c:Card = new Card();
			c.initialize( d );
			addChild( c );
			cards.push( c );
			return c;
		}
		
		public function randomizeCardData( d:CardData = null ):CardData
		{
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
			return d;
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
			if ( e.ctrlKey || e.altKey )
			{
				var i:int;
				var c:Card = context.focusedCard;
				var v:SpaceView = context.currentView;
				var g:CardGroup = context.focusedGroup;
				
				// COPY & PASTE
				if ( e.keyCode == Keyboard.C && e.shiftKey )
				{
					if ( g == null ) return;
					Temp.clipboard = g.registeredCards;
				}
				else
				if ( e.keyCode == Keyboard.V && e.shiftKey )
				{
					if ( g == null ) return;
					if ( Temp.clipboard as Array == null ) return;
					g.purgeCards();
					var a:Array = Temp.clipboard as Array;
					for ( i = 0; i < cards.length; i++ )
					{
						c = cards[ i ];
						if ( a.indexOf( c.data.id ) < 0 )
							continue;
						g.addCard( c );
					}
					g.updateRegisteredCards();
				}
				else
				// OUTPUT LIST
				if ( e.keyCode == Keyboard.P )
				{
					if ( g == null ) return;
					var s:String = "";
					for ( i = g.countCards - 1; i >= 0; i-- )
						s += "\"" + g.getCardAt( i ).data.slug + "\",\n";
					StringOutput.generate( stage, s );
					Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, s );
				}
				else
				// SORTING
				if ( e.keyCode == Keyboard.Q )
				{
					if ( g == null ) return;
					var o:Object =
					{
						byID 		: SortFunctions.byID 		,
						bySlug 		: SortFunctions.bySlug 		,
						byName		: SortFunctions.byName		,
						byType 		: SortFunctions.byType 		,
						byFaction	: SortFunctions.byFaction	,
						byPower 	: SortFunctions.byPower 	,
						byStars 	: SortFunctions.byStars 	,
						byPriority 	: SortFunctions.byPriority 	,
						random 		: SortFunctions.byRandom 	
					}
					MenuInput.generate( stage, o, g.sortCards );
				}
				else
				// STARS & PRIORITY
				if ( e.keyCode == Keyboard.UP )
				{
					if ( c == null ) return;
					c.data.priority = ( c.data.priority + 1 ) % 4;
					c.onDataChange();
				}
				else
				if ( e.keyCode == Keyboard.DOWN )
				{
					if ( c == null ) return;
					c.data.priority = ( c.data.priority - 1 ) % 4;
					if ( c.data.priority < 0 ) c.data.priority = 0;
					c.onDataChange();
				}
				else
				if ( e.keyCode == Keyboard.LEFT )
				{
					if ( c == null ) return;
					c.data.stars = ( c.data.stars - 1 ) % 4;
					if ( c.data.stars < 0 ) c.data.stars = 0;
					c.onDataChange();
				}
				else
				if ( e.keyCode == Keyboard.RIGHT )
				{
					if ( c == null ) return;
					c.data.stars = ( c.data.stars + 1 ) % 4;
					c.onDataChange();
				}
				else
				// MARK CARD
				if ( e.keyCode == Keyboard.M )
				{
					if ( c == null ) return;
					switch ( c.data.mark )
					{
						case 0x000000 : c.data.mark = 0x111111; break;
						case 0x111111 : c.data.mark = 0x0088FF; break;
						case 0x0088FF : c.data.mark = 0xFF4400; break;
						case 0xFF4400 : c.data.mark = 0x000000; break;
					}
					c.onDataChange();
				}
				else
				// CHANGE VIEW
				if ( e.keyCode >= Keyboard.NUMBER_1 && e.keyCode <= Keyboard.NUMBER_9 )
					setView( e.keyCode - Keyboard.NUMBER_1 );
				else
				// ARRANGE VIEW
				if ( e.keyCode == Keyboard.SPACE )
					context.currentView.arrangeGroups();
				else
				// GROUP PURGE
				if ( e.keyCode == Keyboard.X )
				{
					if ( g && !g.locked )
						g.purgeCards();
				}
				else
				// GROUP RENAME
				if ( e.keyCode == Keyboard.R )
				{
					if ( g && !g.locked )
						StringInput.generate( stage, g.setName, g.name );
					else
						StringInput.generate( stage, v.setName, v.name );
				}
				else
				// GROUP ADD BY TEXT
				if ( e.keyCode == Keyboard.F )
				{
					if ( g && !g.locked )
						StringInput.generate( stage, fFindByText );
					
					function fFindByText( txt:String ):void
					{
						if ( txt == null || txt == "" ) return;
						for ( var i:int = 0; i < cards.length; i++ )
							if ( g.view.groups[0].containsCard( cards[ i ] ) )
								if ( cards[ i ].data.hasText( txt.toLowerCase() ) )
									g.addCard( cards[ i ], 0 );
					}
				}
				else
				// GROUP ADD BY TAG
				if ( e.keyCode == Keyboard.T )
				{
					if ( g && !g.locked )
						StringInput.generate( stage, fFindByText );
					
					function fFindByTag( tag:String ):void
					{
						if ( tag == null || tag == "" ) return;
						for ( var i:int = 0; i < cards.length; i++ ) 
							if ( g.view.groups[0].containsCard( cards[ i ] ) )
								if ( cards[ i ].data.hasTag( tag ) )
									g.addCard( cards[ i ], 0 );
					}
				}
				else
				// NEW CARD
				if ( e.keyCode == Keyboard.A )
				{
					if ( g )
						g.addCard( generateNewCard(), -1, true );
				}
				else
				// NEW GROUP
				if ( e.keyCode == Keyboard.G )
				{
					context.currentView.addGroup( generateNewGroup() );
				}
				else
				// // // SAVE CHANGES // // //
				if ( e.keyCode == Keyboard.S )
				{
					App.remote.save( this );
				}
			}
			
			CONFIG::desktop
			{
				// TOGGLE FULLSCREEN
				if ( e.keyCode == Keyboard.F11 )
					App.toggleFullScreen();
			}
			
		}
		
		//
		
		public function initFromJson( data:Object ):void
		{
			var i:int;
			var j:int;
			var o:Object;
			
			if ( data.conf != undefined )
			{
				nextCardID = data.conf.nextCardID;
			}
			
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
				cd.vars			= o.vars;
				cd.mark			= o.mark;
				cd.stars		= o.stars;
				cd.priority		= o.priority;
				c = generateNewCard( cd );
			}
			
			var g:CardGroup;
			for ( j = 0; j < data.views.length; j++ ) 
			{
				views[ j ].name = data.views[ j ].name;
				
				o = data.views[ j ].g0;
				if ( o != null )
				{
					g = views[ j ].groups[ 0 ];
					g.tformExpanded.x = o.xe;
					g.tformExpanded.y = o.ye;
					g.tformExpanded.width = o.we;
					g.tformExpanded.height = o.he;
				}
				
				for ( i = 0; i < data.views[ j ].groups.length; i++ ) 
				{
					o = data.views[ j ].groups[ i ];
					g = generateNewGroup( o.name );
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
		}
		
		public function toJson():String
		{
			var i:int;
			var j:int;
			var o:Object;
			var r:Object = { };
			
			// SETTINGS
			
			r.conf = 
			{
				nextCardID : nextCardID
			};
			
			// CARDS
			
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
				o.vars = c.data.vars;
				o.mark = c.data.mark;
				o.stars = c.data.stars;
				o.priority = c.data.priority;
				r.cards.push( o );
			}
			
			// VIEWS & GROUPS
			
			r.views = new Array();
			
			var g:CardGroup;
			for ( i = 0; i < views.length; i++ ) 
			{
				r.views.push( { } );
				r.views[ i ].name = views[ i ].name;
				r.views[ i ].groups = new Array();
				
				g = views[ i ].groups[ 0 ];
				o = { };
				o.xe = g.tformExpanded.x;
				o.ye = g.tformExpanded.y;
				o.we = g.tformExpanded.width;
				o.he = g.tformExpanded.height;
				r.views[ i ].g0 = o;
				
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
			
			// done
			
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
		
		//
		
		public static function findCardBySlug( slug:String ):Card
		{
			for ( var i:int = 0, iMax:int = me.cards.length; i < iMax; i++ )
				if ( me.cards[ i ].data.slug == slug )
					return me.cards[ i ];
			return null;
		}
	}
}