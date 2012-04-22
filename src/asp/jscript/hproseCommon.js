/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/

/**********************************************************\
 *                                                        *
 * hproseCommon.js                                        *
 *                                                        *
 * hprose common library for ASP.                         *
 *                                                        *
 * LastModified: Jun 22, 2011                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/

var HproseResultMode = {
    Normal: 0,
    Serialized: 1,
    Raw: 2,
    RawWithEndTag: 3
}

function HproseException(message) {
    this.message = message;
    this.description = message;
};
HproseException.prototype = new Error;
HproseException.prototype.name = 'HproseException';

var HproseUtil = {
    isDictionary: function(o) {
        return ((o != null) &&
        (typeof(o) == "object") &&
        (o instanceof ActiveXObject) &&
        (typeof(o.Add) == "unknown") &&
        (typeof(o.Exists) == "unknown") &&
        (typeof(o.Items) == "unknown") &&
        (typeof(o.Keys) == "unknown") &&
        (typeof(o.Remove) == "unknown") &&
        (typeof(o.RemoveAll) == "unknown") &&
        (typeof(o.Count) == "number") &&
        (typeof(o.Item) == "unknown") &&
        (typeof(o.Key) == "unknown"));
    },

    isVBArray: function(o) {
        return ((o != null) &&
        (typeof(o) == "unknown") &&
        (o.constructor == VBArray) &&
        (typeof(o.dimensions) == "function") &&
        (typeof(o.getItem) == "function") &&
        (typeof(o.lbound) == "function") &&
        (typeof(o.toArray) == "function") &&
        (typeof(o.ubound) == "function"));
    },

    toObject: function(dict) {
        var array = (new VBArray(dict.Keys())).toArray();
        var result = {};
        for (var i = 0; i < array.length; i++) {
            if (this.isDictionary(dict(array[i]))) {
                result[array[i]] = this.toObject(dict(array[i]));
            }
            else if (this.isVBArray(dict(array[i]))) {
                result[array[i]] = this.toJSArray(dict(array[i]));
            }
            else {
                result[array[i]] = dict(array[i]);
            }
         }
         return result;
    },

    toDictionary: function(object) {
        var key, result;
        result = new ActiveXObject("Scripting.Dictionary");
        for (key in object) {
            result.Add(key, object[key]);
        }
        return result;
    },

    toJSArray: function(vbArray) {
        function toArray(vbarray, dimension, indices) {
            var rank = vbarray.dimensions();
            if (rank > dimension) {
                indices[dimension] = 0;
                dimension++;
            }
            var lb = vbarray.lbound(dimension);
            var ub = vbarray.ubound(dimension);
            var jsarray = [];
            for (var i = lb; i <= ub; i++) {
                indices[dimension - 1] = i;
                if (rank == dimension) {
                    jsarray[i] = vbarray.getItem.apply(vbarray, indices);
                }
                else {
                    jsarray[i] = toArray(vbarray, dimension, indices);
                }
            }
            return jsarray;
        }

        var vbarray = new VBArray(vbArray);
        if (vbarray.dimensions() == 1 && vbarray.lbound() == 0) {
            return vbarray.toArray();
        }
        return toArray(vbarray, 0, []);
    },

    toVBArray: function(jsarray) {
        return this.toDictionary(jsarray).Items();
    },
    
    binaryToString: function(binary, charSet) {
        try {
            var adTypeText = 2;
            var adTypeBinary = 1;
            var binaryStream = new ActiveXObject("ADODB.Stream");
            binaryStream.Type = adTypeBinary;
            binaryStream.Open();
            binaryStream.Write(binary);
            binaryStream.Position = 0;
            binaryStream.Type = adTypeText;
            if (charSet) {
               binaryStream.CharSet = charSet;
            }
            else {
               binaryStream.CharSet = "UTF-8";
            }
            return binaryStream.ReadText();
        }
        catch (e) {
            return "";
        }
    }
}