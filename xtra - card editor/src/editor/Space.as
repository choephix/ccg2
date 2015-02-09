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
		
		public var view:SpaceView = null;
		
		private var viewLabel:TextField;
		
		public function Space() 
		{
			super();
			
			viewLabel = new TextField( 200, 200, "0", "Consolas", 100, 0x909090, true );
			viewLabel.alignPivot();
			viewLabel.x = .5 * width;
			viewLabel.y = .5 * height;
			addChild( viewLabel );
			
			//
			
			for ( var i:int = 0; i < views.length; i++ )
				views[ i ] = new SpaceView( this, i * height, generateNewGroup( null ) );
			
			views[ 0 ].addGroup( generateNewGroup( "type0" ) );
			views[ 0 ].addGroup( generateNewGroup( "type1" ) );
			views[ 0 ].addGroup( generateNewGroup( "type2" ) );
			views[ 0 ].addGroup( generateNewGroup( "type3" ) );
				
			setView( 0 );
		}
		
		private function generateNewGroup( tag:String = null ):CardGroup 
		{
			var g:CardGroup;
			
			g = new CardGroup();
			g.space = this;
			addChild( g );
			
			g.initialize( tag );
			
			g.addCard( generateNewCard() );
			g.addCard( generateNewCard() );
			
			//g.visible = false;
			
			return g;
		}
		
		public function generateNewCard():Card
		{
			var c:Card = new Card();
			c.type = Math.random() * 4;
			c.x = width * ( 0.25 + 0.50 * Math.random() );
			c.y = height * ( 0.25 + 0.50 * Math.random() );
			addChild( c );
			cards.push( c );
			return c;
		}
		
		public function setView( index:uint ):void 
		{
			viewLabel.text = String( index + 1 );
			
			var gi:int;
			var ci:int;
			
			if ( view != null )
			{
				view.active = false;
			}
			
			view = views[ index ];
			
			if ( view != null )
			{
				view.active = true;
				y = -view.y;
				
				//var c:Card;
				//var g:CardGroup;
				//for ( ci = 0; gi < cards.length; gi++ )
				//{
					//c = cards[ ci ];
					//g = view.groups[ 0 ];
					//for ( gi = 1; gi < view.groups.length; gi++ )
						//if ( c.hasTag( view.groups[ gi ].tag ) )
							//g = view.groups[ gi ];
					//g.addCard( c );
				//}
				
			}
			
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