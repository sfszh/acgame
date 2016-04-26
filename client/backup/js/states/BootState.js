var RPG = RPG || {};

RPG.BootState = function () {
    "use strict";
    Phaser.State.call(this);
};

RPG.BootState.prototype = Object.create(Phaser.State.prototype);
RPG.BootState.prototype.constructor = RPG.BootState;

RPG.BootState.prototype.init = function (level_file, next_state, extra_parameters) {
    "use strict";
    this.level_file = level_file;
    this.next_state = next_state;
    this.extra_parameters = extra_parameters;
    console.log("hello, there");
    RPG.ws = new WebSocket('ws://192.168.10.233:8001/ws');
    RPG.ws.onopen = function(){
        console.log("open");
        RPG.ws.send('map');
    }
    RPG.ws.onmessage = function(ev) {
        // console.log("reciveved: " + ev.data);
        RPG.map = JSON.parse(ev.data);
        console.log(RPG.map);
    }
    RPG.ws.onclose = function(ev) {
        console.log("close");
    }
    RPG.ws.onerror = function(ev) {
        console.log("error");
    }
};

RPG.BootState.prototype.preload = function () {
    "use strict";
    this.load.text("level1", this.level_file);
};

RPG.BootState.prototype.create = function () {
    "use strict";
    var level_text, level_data;
    level_text = this.game.cache.getText("level1");
    level_data = JSON.parse(level_text);
    this.game.state.start("LoadingState", true, false, level_data, this.next_state, this.extra_parameters);
};
