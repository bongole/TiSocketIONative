package com.bongole.ti.socketio;

import java.net.MalformedURLException;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import io.socket.IOAcknowledge;
import io.socket.IOCallback;
import io.socket.SocketIO;
import io.socket.SocketIOException;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.json.JSONException;
import org.json.JSONObject;
import org.appcelerator.kroll.common.Log;

@Kroll.proxy(creatableInModule=AndroidModule.class)
public class SocketProxy extends KrollProxy implements IOCallback {
	private SocketIO socketIO = null;
	
	private SocketIO getSocketIO(){
		if( socketIO == null ){
			socketIO = new SocketIO();
		}
		
		return socketIO;
	}
	
	@Kroll.method
	public void disconnect(Object[] args){
		SocketIO s = getSocketIO();
		s.disconnect();
	}
	
	@Kroll.method
	public void sendEvent(Object[] args){
		String event;
		String data;
		
		if( args.length == 2 ){
			event = (String)args[0];
			data = (String)args[1];
		}
		else{
			return;
		}
		
		SocketIO s = getSocketIO();
		s.emit(event, data);
	}
	
	@Kroll.method
	public void connect(Object[] args) throws MalformedURLException{
		String url = null;
		Map opt = null;
		
		if( args.length == 1 ){
			url = (String)args[0];
		}
		else if( args.length == 2 ){
			url = (String)args[0];
			opt = (Map)args[1];
		}
		else{
			return;
		}
		
		String query = "";
		if( opt != null ){
			Set<String> keys = opt.keySet();
			Iterator<String> it = keys.iterator();
			while(it.hasNext()){
				String key = it.next();
				query += key + "=" + opt.get(key);
				if( it.hasNext() ){
					query += "&";
				}
			}
		}
		
		if( !"".equals(query) ){
			url += "?" + query;
		}
		
		SocketIO s = getSocketIO();
		if( s.isConnected() ){
			return;
		}
		
		Log.d("AndroidModule", url);
		s.connect(url, this);
	}

	@Override
	public void on(String event, IOAcknowledge ack, Object... args) {
		KrollDict e = new KrollDict();
		e.put("name", event);
		if( args != null ){
			Object[] tmpArgs = new Object[args.length];
			try {
				for (int i = 0; i < args.length; i++) {
					tmpArgs[i] = JsonHelper.fromJson(args[i]);
				}
				
				e.put("args", tmpArgs);
			} catch (JSONException e1) {
			}
		}
		
		if( this.hasListeners("receiveEvent")){
			this.fireEvent("receiveEvent", e);
		}
	}

	@Override
	public void onConnect() {
		if( this.hasListeners("connect")){
			this.fireEvent("connect", null);
		}
	}

	@Override
	public void onDisconnect() {
		if( this.hasListeners("disconnect")){
			this.fireEvent("disconnect", null);
		}
	}

	@Override
	public void onError(SocketIOException ex) {
		KrollDict e = new KrollDict();
		e.put("error", ex.getMessage());
		if( this.hasListeners("error")){
			this.fireEvent("error", e);
		}
	}

	@Override
	public void onMessage(String data, IOAcknowledge ack) {
		KrollDict e = new KrollDict();
		e.put("data", data);
		
		if( this.hasListeners("receiveMessage")){
			this.fireEvent("receiveMessage", e);
		}	
	}

	@Override
	public void onMessage(JSONObject data, IOAcknowledge ack) {
		// TODO Auto-generated method stub
		
	}
}
