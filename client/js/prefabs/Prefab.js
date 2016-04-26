var ProceduralGeneration = ProceduralGeneration || {};

ProceduralGeneration.Prefab = function (game_state, name, position, properties) {
    "use strict";
    Phaser.Sprite.call(this, game_state.game, position.x, position.y, properties.texture);
    
    this.game_state = game_state;
    
    this.name = name;
    
    if (!this.game_state.groups[properties.group]) {
        console.log(properties.group);
        console.log("group do not exist");
    }
    this.game_state.groups[properties.group].add(this);
    this.frame = +properties.frame;
    
    if (properties.scale) {
        this.scale.setTo(properties.scale.x, properties.scale.y);
    }
    
    this.game_state.prefabs[name] = this;
};

ProceduralGeneration.Prefab.prototype = Object.create(Phaser.Sprite.prototype);
ProceduralGeneration.Prefab.prototype.constructor = ProceduralGeneration.Prefab;