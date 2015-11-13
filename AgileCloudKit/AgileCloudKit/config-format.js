CloudKit.configure({
    containers: [%@],
    services: {
        authTokenStore: {
            putToken: function(cid,tok){ return window.putTokenBlock(cid, tok); },
            getToken: function(cid){ return window.getTokenBlock(cid); }
        },
       logger: {
           info: function(str){ window.doLog(str); },
           log: function(str){ window.doLog(str); },
           warn: function(str){ window.doLog(str); },
           error: function(str){ window.doLog(str); },
       }
    },

});