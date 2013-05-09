/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package com.zondig.gandalf;

import org.cocos2dx.lib.Cocos2dxActivity;

import PokeIn.Java.Client;
import PokeIn.Java.ClientEvents;
import PokeIn.Java.LogLevel;
import android.os.Bundle;
import android.util.Log;

public class gandalf extends Cocos2dxActivity{

	protected void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
	}
	
	//here is your PokeIn Java Client
	PokeIn.Java.Client myClient;
	 
	//below you will listen all the events
	PokeIn.Java.ClientEvents dev = new ClientEvents(){
	    @Override
	    public void OnErrorReceived(Client c, String Message) {
	        //Error received
	    	Log.e("ERROR", Message);
	    }
	 
	    @Override
	    public void OnClientConnected(Client c) {
	        //Client is connected
	    	serverConnected();
	    	Log.w("WARNING", "PokeinClient is Connected!");
	    }
	 
	    @Override
	    public void OnClientDisconnected(Client c) {
	        //Client is disconnected
	    	Log.e("ERROR", "PokeInClient is DISCONNECTED");
	    }
	 
	    @Override
	    public void OnEventLog(Client c, String log, LogLevel level) {
	        //Event Log
	    	Log.w("*********LOG", log);
	    }
	};
	
	public static native void playerShot(int x, int y, int wo, int ho);
	public static native void creatureArray(int []arr);
	public static native void playerLeft();
	public static native void serverConnected();
	
	static gandalf active;
	
	public static void joinGame(int w, int h){
		PokeIn.Java.Client client = active.myClient;
		
	    if(!client.getIsConnected())
	    {
	        //NSLog(@"Not connected!");
	        return;
	    }
	    //Log.w("GONDOR", "Joining to a room : w:" + ((Integer)w).toString() + ", h:" + ((Integer)h).toString());
	    
	    client.Send("Server.joinGame", w, h);
    }
	
	public static void leaveRoom(){
		PokeIn.Java.Client client = active.myClient;
		
	    if(!client.getIsConnected())
	    {
	        //NSLog(@"Not connected!");
	        return;
	    }
	    Log.w("GONDOR", "Leaving the room");
	    client.Send("Server.leaveRoom");
    }
	
	public static void fireShot(String xs, String ys)
	{
		PokeIn.Java.Client client = active.myClient;
		
	    if(!client.getIsConnected())
	    {
	        //NSLog(@"Not connected!");
	        return;
	    }
	    
	    client.Send("Server.gotShot", xs, ys);
	}
	
	Boolean Connect(){
		 
		String connStr = "http://zondig.cloudapp.net/host.PokeIn";
		//String connStr = "http://192.168.1.3/GondorServer/host.PokeIn";
		myTest mt = new myTest();
		//Dummy instance will receive all the method calls from server
		myClient = new Client(mt, connStr);
		
		myTest.activeClient = myClient;
		
		myClient.SocketConfig("zondig.cloudapp.net", 8085);
		//myClient.SocketConfig("192.168.1.3", 8085);

		//just assign the above event listener
		myClient.Events = dev;
		 
		//and connect to PokeIn server
		myClient.AsyncConnect();
		
		return true;
	}
	
	
	
    static 
    {
    	active = new gandalf();
    	
    	if(active.Connect())
    		System.loadLibrary("game");
    }
}