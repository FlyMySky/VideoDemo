package service {
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.ServerSocketConnectEvent;
import flash.net.ServerSocket;
import flash.net.Socket;
import flash.utils.ByteArray;

import mx.events.EffectEvent;

import spark.components.TextArea;

import spark.components.VideoPlayer;

public class WsSocketService {

    internal var wsServerSocket:ServerSocket;
    internal var videoPlayer:VideoPlayer;

    public function WsSocketService() {
    }

    public function startService(videoPlayer:VideoPlayer):void {
        this.videoPlayer = videoPlayer;
        wsServerSocket = new ServerSocket();
        wsServerSocket.addEventListener(ServerSocketConnectEvent.CONNECT, clientHandler)
        wsServerSocket.bind(8989);
        wsServerSocket.listen();
        trace("wait connect ...")
    }

    private function clientHandler(event:ServerSocketConnectEvent):void {
        var socket:Socket = event.socket;
        socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
        socket.addEventListener(Event.CLOSE, socketClosed);
        trace("connect success");
        videoPlayer.addEventListener(EffectEvent.EFFECT_STOP, videoStop)
    }

    private function videoStop(event:EffectEvent):void {
    }

    private function socketClosed(event:Event):void {
        trace("connect socketClosed")
    }

    private function socketDataHandler(event:ProgressEvent):void {
        var socket:Socket = event.currentTarget as Socket;
        var socketBytes:ByteArray = new ByteArray();
        if (socket.bytesAvailable > 0) {
            socket.readBytes(socketBytes);
            var message:String = socketBytes.readUTFBytes(socketBytes.bytesAvailable);
            trace(message);
            if (parseInt(message) == 1) {
                videoPlayer.setVisible(true);
                videoPlayer.play();
            } else if (parseInt(message) == 2) {
                videoPlayer.pause();
                videoPlayer.setVisible(true);
            } else if (parseInt(message) == 3) {
                videoPlayer.stop();
                videoPlayer.setVisible(false);
            } else if (parseInt(message) == 4) {
                videoPlayer.setVisible(true);
                videoPlayer.volume += 0.1;
            } else if (parseInt(message) == 5) {
                videoPlayer.setVisible(true);
                videoPlayer.volume -= 0.1;
            }
        }
    }

    public function close():void {
        if (wsServerSocket != null) {
            wsServerSocket.close()
            trace("wsServerSocket close")
        }
    }
}
}
