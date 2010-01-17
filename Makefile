default: flash/jssocket.swf flash/jssocket.debug.swf

flash/jssocket.swf: lib/JSSocket.hx
	haxe -swf9 flash/jssocket.swf -cp lib -main JSSocket -swf-header 1:1:1
	
flash/jssocket.debug.swf: lib/JSSocket.hx
	haxe -swf9 flash/jssocket.debug.swf -cp lib -main JSSocket -swf-header 1:1:1 -D debugEnabled
