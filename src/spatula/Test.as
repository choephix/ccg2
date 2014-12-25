package spatula {
	import chimichanga.common.display.LinearGradientQuad;
	import chimichanga.common.display.positioning.AutoPositioner;
	import chimichanga.common.display.Sprite;
	import chimichanga.common.input.InputManager;
	import chimichanga.global.utils.Angles;
	import chimichanga.global.utils.ArrangeChildren;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import starling.core.Starling;
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Test {
		
		public static function test() {
			
			trace( getTimer() );
			var n:Number;
			var t:Number;
			var i:int;
			var k:InputManager = new InputManager( App.stage );
			k.registerButtonKey( "1", Keyboard.NUMBER_1 );
			k.registerButtonKey( "2", Keyboard.NUMBER_2 );
			k.registerButtonKey( "3", Keyboard.NUMBER_3 );
			k.registerButtonKey( "4", Keyboard.NUMBER_4 );
			k.registerButtonKey( "5", Keyboard.NUMBER_5 );
			k.registerButtonKey( "6", Keyboard.NUMBER_6 );
			k.registerButtonKey( "7", Keyboard.NUMBER_7 );
			k.registerButtonKey( "8", Keyboard.NUMBER_8 );
			k.registerButtonKey( "9", Keyboard.NUMBER_9 );
			//
			
			var bg:Quad = new LinearGradientQuad( 700, 400, 0x004040, 0x400000 );
			addChild( bg );
			
			var con:Sprite = new Sprite();
			addChild(con);
			
			function fnua():void {
				//var q:Quad = new Quad( 111, 60, Math.random() * 0xFFFFFF );
				var q:Quad = new Quad( 50 + Math.random()*100, 25 + Math.random()*50, Math.random() * 0xFFFFFF );
				con.addChild( q );
			}
			for (var l:int = 0; l < 40; l++) fnua();
			
			k.addButtonDownWatcher( "1", ArrangeChildren.asList, [con, 700, 2, 5] );
			k.addButtonDownWatcher( "2", ArrangeChildren.horisontallyOnePerColumn, [con,2] );
			k.addButtonDownWatcher( "3", ArrangeChildren.verticallyOnePerLine, [con,2] );
			
			return
			
			var q:Quad;
			var qq:Quad;
			
			qq = new Quad(700, 400, 0x0088FF);
			addChild( qq );
			Starling.juggler.tween( qq, 5.0, { 
				//scaleX:1.5, scaleY:0.5,
				scaleY:1.5, scaleX:0.5,
				onUpdate : function():void { p.setTo(0, qq.width, 0, qq.height); }
			} );
			var p:AutoPositioner = AutoPositioner.fromObjectBounds( qq );
			//q = new Quad(350, 200, 0x0066FF); addChild( q );
			//q = new Quad(350, 200, 0x0066FF); addChild( q ); q.x = 350; q.y = 200;
			
			fp( 0.0, 0.5, 20.0, -50.0 );
			fp( 0.0, 0.0, 20.0, -50.0 );
			fp( 0.1, 0.9, 20.0, -50.0 );
			fp( 0.7, 0.1, 20.0, -50.0 );
			fp( 1.0, 1.0, 20.0, -50.0 );
			fp( 1.0, 0.0, 20.0, -50.0 );
			fp( 0.0, 1.0, 20.0, -50.0 );
			
			function fp( rX:Number, rY:Number, oX:Number, oY:Number ):void {
				q = new Quad(100, 100, 0xFFCC00);
				addChild( q );
				q.alignPivot();
				p.registerSubject( q, rX, rY, oX, oY );
			}
			
			
			
			return 
			
			var cx:int = 0;
			var cy:int = 0;
			function fq( c:uint ):void {
				const CX:Number = 100;
				const CY:Number = 50;
				var q:Quad;
				q = new Quad( CX, CY, c );
				q.x = CX * cx;
				q.y = CY * cy;
				addChild( q );
				cx++;
				if ( cx >= 8 ) nl();
			}
			function nl():void { cx = 0; cy++; }
			
			function fccc( c:uint ):void { 
				fq( c );
				fq( 0xFFFFFF ^ c );
				nl();
				//trace( c.toString(16), (0xFFFFFF ^ c).toString(16) );
			}
			
			fccc( 0xFFCC00 );
			fccc( 0xFF8800 );
			fccc( 0xFF4400 );
			
			fccc( 0xccff00 );
			fccc( 0x880022 );
			fccc( 0xFF0000 );
			fccc( 0x443322 );
			fccc( 0xaabbcc );
			fccc( 0x0 );
			fccc( 0x00ff00 );
			
			function f():void { trace( c.toString(16) ); }
			var c:uint = 0xFFFFFF;
			f();
			c = 0xFF;
			c /= 16;
			f();
			c *= 0x100;
			f();
			
			return;
			
			
			var k:InputManager = new InputManager( stage );
			k.registerButtonKey( "boom", Keyboard.SPACE );
			k.registerButtonKey( "A", Keyboard.A );
			k.registerButtonKey( "S", Keyboard.S );
			k.addButtonDownWatcher( "boom", trace, ["BTOOOM!"] );
			k.addButtonDownWatcher( "A", trace, ["a!"] );
			k.addButtonDownWatcher( "S", trace, ["s!"] );
			k.addButtonUpWatcher( "A", trace, ["!a"] );
			k.addButtonUpWatcher( "S", trace, ["!s"] );
			//k.addButtonUpWatcher( "S", function():void { trace() } );
			k.registerAxisKeys( "move", Keyboard.LEFT, Keyboard.RIGHT );
			k.registerAxisKeys( "move", Keyboard.A, Keyboard.D );
			k.addAxisChangeWatcher( "move", trace );
			return;
			
			var fi:Number;
			for (var j:int = 0; j < 40; j++) {
				fi = j * .25;
				trace( 
					"\t" + int( Angles.radToDeg( Angles.round( fi ) ) ),
					"\t" + int( Angles.radToDeg( fi ) ), 
					"\t" , 
					"\t" + int( Angles.radToDeg( -fi ) ), 
					"\t" + int( Angles.radToDeg( Angles.round( -fi ) ) ),
					//"\t" + int( Angles.radToDeg( Angles.floor( fi ) ) ),
					//"\t" + int( Angles.radToDeg( Angles.ceil( fi ) ) ),
					""
					);
			}
			
			return;
			
			t = getTimer();
			for ( i = 0; i < 10000000; i++)
				n = 1.0 * 180.0;
			trace( getTimer()-t );
			
			t = getTimer();
			for ( i = 0; i < 10000000; i++)
				n = 1.0 / 180.0;
			trace( getTimer()-t );
			
			t = getTimer();
			for ( i = 0; i < 10000000; i++)
				n = Math.random();
			trace( getTimer()-t );
			
		}
	
	}

}