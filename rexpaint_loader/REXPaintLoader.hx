package rexpaint_loader;

import haxe.io.*;

typedef REXPaintTile = {
    ascii_code:Int,
    fg_r:Int,
    fg_g:Int,
    fg_b:Int,
    bg_r:Int,
    bg_g:Int,
    bg_b:Int,
    transparent:Bool
}

typedef REXPaintLayer = {
    tiles:Array<REXPaintTile>
}

typedef REXPaintFile = {
	width:Int,
	height:Int,
	layers:Array<REXPaintLayer>
}

class REXPaintLoader {
	public static function loadXP(bytes:haxe.io.Bytes):REXPaintFile {

        var tmp = new haxe.io.BytesOutput();
        var gz = new format.gz.Reader(new haxe.io.BytesInput(bytes));
        gz.readHeader();
        gz.readData(tmp);

        var b:haxe.io.Bytes = tmp.getBytes();

        var p:Int = 0;
        var xp_width:Int = 0, xp_height:Int = 0;
        var layers:Array<REXPaintLayer> = new Array<REXPaintLayer>();

        var xp_version = b.getInt32(p); p += 4;
        var xp_layers = b.getInt32(p); p += 4;

        // trace("Version: " + xp_version);
        // trace("Number of layers: " + xp_layers);

        for(layerNo in 0 ... xp_layers) {
             xp_width = b.getInt32(p); p += 4;
             xp_height = b.getInt32(p); p += 4;

        //     trace("Width: " + xp_width);
        //     trace("Height: " + xp_height);
        
            var tiles:Array<REXPaintTile> = new Array<REXPaintTile>();

            // .xp files are column-major! http://www.gridsagegames.com/rexpaint/manual.txt

            for(x in 0 ... xp_width) {
                for(y in 0 ... xp_height) {
                    var ascii_code = b.getInt32(p); p += 4;
                    var fg_r = b.get(p); p += 1;
                    var fg_g = b.get(p); p += 1;
                    var fg_b = b.get(p); p += 1;
                    var bg_r = b.get(p); p += 1;
                    var bg_g = b.get(p); p += 1;
                    var bg_b = b.get(p); p += 1;
                    var transparent:Bool = ( bg_r == 255 && bg_g == 0 && bg_b == 255 );

                    var tile:REXPaintTile = { 
                        ascii_code:ascii_code, 
                        fg_r:fg_r,
                        fg_g:fg_g,
                        fg_b:fg_b,
                        bg_r:bg_r,
                        bg_g:bg_g,
                        bg_b:bg_b, 
                        transparent:transparent                      
                    };

                    tiles.push(tile);
                }
            }
            layers.push({tiles:tiles});
        }

        return {width:xp_width, height:xp_height, layers:layers};
    }
}