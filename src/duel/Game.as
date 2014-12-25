package duel
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import duel.cards.Card;
	import duel.cards.CardFactory;
	import duel.gui.Gui;
	import duel.gui.GuiJuggler;
	import duel.gui.HandContainer;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Game extends DisplayObjectContainer implements IAnimatable
	{
		public static var current:Game;
		
		public var jugglerStrict:GuiJuggler;
		public var jugglerMild:GuiJuggler;
		
		public var gui:Gui;
		public var selection:Selection;
		
		public var p1:Player;
		public var p2:Player;
		
		public var bg:Background;
		public var side1:PlayerSide;
		public var side2:PlayerSide;
		
		//
		private var p1hand:HandContainer;
		
		public function Game()
		{
			current = this;
			
			//
			Starling.juggler.add( this );
			
			jugglerStrict = new GuiJuggler();
			jugglerMild = new GuiJuggler();
			
			//
			p1 = generatePlayer( "player1" );
			p2 = generatePlayer( "player2" );
			
			// VISUALS
			bg = new Background( assets.getTexture( "bg" ) );
			bg.onClickedCallback = onBgClicked;
			addChild( bg );
			
			const CHAR_SCALE:Number = 0.5;
			const CHAR_MARGIN_Y:Number = 40;
			
			var char1:Image = assets.generateImage( "char1" );
			char1.alignPivot( "right", "bottom" );
			char1.x = App.W;
			char1.y = App.H - CHAR_MARGIN_Y;
			char1.scaleX = CHAR_SCALE;
			char1.scaleY = CHAR_SCALE;
			addChild( char1 );
			
			var char2:Image = assets.generateImage( "char2" );
			char2.alignPivot( "right", "top" );
			char2.x = 0;
			char2.y = CHAR_MARGIN_Y;
			char2.scaleX = -CHAR_SCALE;
			char2.scaleY =  CHAR_SCALE;
			addChild( char2 );
			
			side1 = new PlayerSide( false );
			addChild( side1 );
			side1.x = App.W * 0.50;
			side1.y = App.H * 0.70;
			
			side2 = new PlayerSide( true );
			addChild( side2 );
			side2.x = App.W * 0.50;
			side2.y = App.H * 0.30;
			
			// GUI AND STUFF
			gui = new Gui();
			addChild( gui );
			
			selection = new Selection();
			
			p1hand = new HandContainer( p1.hand );
			p1hand.x = ( App.W - p1hand.maxWidth ) * 0.5;
			p1hand.y = App.H;
			addChild( p1hand );
		}
		
		public function destroy():void 
		{
			Starling.juggler.remove( this );
			removeFromParent( true );
		}
		
		// INTERACTION
		
		public function onFieldClicked( field:CardField ):void
		{
			if ( selectedCard )
			{
				if ( canPlayHere( selectedCard, field ) )
				{
					field.container.addCardTo( selectedCard, field );
				}
				selectCard( null );
			}
		}
		
		public function onCardClicked( card:Card ):void
		{
			selectCard( selectedCard == card ? null : card );
		}
		
		public function onCardRollOver( card:Card ):void
		{
		
		}
		
		public function onCardRollOut( card:Card ):void
		{
		
		}
		
		private function onBgClicked():void
		{
			if ( p1hand.contains( selection.selectedCard.model ) )
			{
				p1hand.unshow( selection.selectedCard );
			}
			
			selection.selectedCard = null;
		}
		
		private function selectCard( card:Card ):void {
			if ( selectedCard != null && p1hand.contains( selectedCard.model ) )
			{
				p1hand.unshow( selectedCard );
			}
			
			selection.selectedCard = card;
			
			if ( selectedCard != null && p1hand.contains( selectedCard.model ) )
			{
				p1hand.show( selectedCard );
			}
		}
		
		public function get selectedCard():Card { return selection.selectedCard }
		
		//
		
		private function generatePlayer( name:String ):Player
		{
			var p:Player = new Player();
			p.name = name;
			p.lp = 60;
			
			while ( p.hand.count < 12 )
			{
				p.hand.add( CardFactory.produceCard( 0 ) );
			}
			
			return p;
		}
		
		public function advanceTime( time:Number ):void
		{
			jugglerStrict.advanceTime( time );
			jugglerMild.advanceTime( time );
			
			gui.advanceTime( time );
			p1hand.advanceTime( time );
		}
		
		public function get interactable():Boolean
		{
			return jugglerStrict.isIdle;
		}
		
		// QUESTIONS
		
		public function canPlayHere( card:Card, field:CardField ):Boolean
		{
			if ( !side1.contains( field ) )
				return false;
			if ( field.allowedCardType != card.type )
				return false;
			return true;
		}
		
		//
		protected function get assets():AdvancedAssetManager
		{
			return App.assets
		}
	}
}