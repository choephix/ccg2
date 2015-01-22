package duel.network {
	import com.reyco1.multiuser.data.UserObject;
	import com.reyco1.multiuser.MultiUserSession;
	import duel.Game;
	import flash.system.Capabilities;
	import starling.animation.Juggler;
	import starling.events.EventDispatcher;
	
	CONFIG::air
	{
	import flash.filesystem.File;
	}
	/**
	 * ...
	 * @author choephix
	 */
	public class RemoteConnectionController extends EventDispatcher
	{
		private const SERVER_ADDRESS:String	= "rtmfp://p2p.rtmfp.net/dd445b2af11141d2f0638908-3a1ceb27480a";
		private var connection:MultiUserSession;
		public var onOpponentFoundCallback:Function;
		public var onUserObjectRecievedCallback:Function;
		
		public var myUser:UserObject;
		public var oppUser:UserObject;
		
		public function initialize():void
		{
			connection = new MultiUserSession( SERVER_ADDRESS, "ccg2/test" );
			connection.onConnect 		= onConnected;
			connection.onUserAdded 		= onUserAdded;
			connection.onUserRemoved 	= onUserRemoved;
			connection.onUserExpired 	= onUserRemoved;
			connection.onObjectRecieve 	= onUserObjectRecieved;
			
			var myEnterTime:Number = new Date().time;
			var myName:String = "User_" + myEnterTime.toString( 36 );
			var myColor:uint = Math.random() * 0xFFFFFF;
			
			CONFIG::air
			{ myName = File.userDirectory.name }
			
			CONFIG::mobile
			//{ myName = Capabilities.manufacturer + " " + Capabilities.cpuArchitecture }
			{ myName = Capabilities.cpuArchitecture+"_"+ myEnterTime.toString( 36 ) }
			
			connection.connect(myName, { color:myColor, logtime:myEnterTime } );
		}
		
		public function destroy():void
		{
			connection.close();
			connection = null;
			onOpponentFoundCallback = null;
			onUserObjectRecievedCallback = null;
			myUser = null;
			oppUser = null;
		}
		
		protected function onConnected(user:UserObject):void					
		{
			Game.log( "I'm connected"
				+ "\n" + "username: " + user.name
				+ "\n" + "userid: " + user.id.substr(0,16) + "..."
				+ "\n" + "totalusers: " + connection.userCount
				+ "\n"
				);
			
			myUser = user;
		}
		
		protected function onUserAdded(user:UserObject):void				
		{
			Game.log( "User added"
				+ "\n" + "username: " + user.name
				+ "\n" + "userid: " + user.id.substr(0,16) + "..."
				+ "\n" + "totalusers: " + connection.userCount
				+ "\n"
				); 
			
			if ( oppUser == null )
			{
				oppUser = user;
				( myUser.details.logtime < oppUser.details.logtime ? myUser : oppUser )
					.details.hasFirstTurn = true;
				if ( onOpponentFoundCallback != null )
					onOpponentFoundCallback();
			}
			
			try {
				var a:Array = connection.userArray;
				var i:int = 0;
				var s:String = "";
				for ( i = 0; i < a.length; i++ )
					s += a[ i ].name + " , ";
				Game.log( "> > > " + s );
			} catch (e:Error) {
				Game.log( e.message );
			}
		}
		
		protected function onUserRemoved(user:UserObject):void				
		{
			Game.log( "User disconnected"
				+ "\n" + "username: " + user.name
				+ "\n" + "userid: " + user.id.substr(0,16) + "..."
				+ "\n" + "totalusers: " + connection.userCount
				+ "\n"
				); 
			
			if ( Game.current )
				Game.current.endGame();
		}
		
		public function sendMyUserObject( data:Object ):void			
		{
			Game.log("sendMyUserObject: " + data ); 
			connection.sendObject( data );			
		}
		
		protected function onUserObjectRecieved( userID:String, data:Object ):void
		{
			var userName:String = connection.userList[userID].name;
			Game.log( "onUserObjectRecieved[" + userName + "]: " + data );
			if ( onUserObjectRecievedCallback != null )	
				onUserObjectRecievedCallback( userName, data );
		}
		
		protected function get juggler():Juggler { return Game.current.juggler }
		public function get userCount():int { return connection.running ? connection.userCount : 0 }
	}
}














