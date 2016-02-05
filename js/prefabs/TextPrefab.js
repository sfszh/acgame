var RPG = RPG || {};

RPG.TextPrefab = function (game_state, name, position, properties) {
    "use strict";
    Phaser.Text.call(this, game_state.game, position.x, position.y, properties.text, properties.style);
    
    this.game_state = game_state;
    
    this.name = name;
    
    this.game_state.groups[properties.group].add(this);
    
    this.game_state.prefabs[name] = this;
};

RPG.TextPrefab.prototype = Object.create(Phaser.Text.prototype);
RPG.TextPrefab.prototype.constructor = RPG.TextPrefab;