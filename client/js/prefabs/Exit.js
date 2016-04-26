var ProceduralGeneration = ProceduralGeneration || {};

ProceduralGeneration.Exit = function (game_state, name, position, properties) {
    "use strict";
    ProceduralGeneration.Prefab.call(this, game_state, name, position, properties);
    
    this.anchor.setTo(0.5);
    
    this.direction = properties.direction;

    this.game_state.game.physics.arcade.enable(this);
    this.body.immovable = true;
};

ProceduralGeneration.Exit.prototype = Object.create(ProceduralGeneration.Prefab.prototype);
ProceduralGeneration.Exit.prototype.constructor = ProceduralGeneration.Exit;

ProceduralGeneration.Exit.prototype.update = function () {
    "use strict";
    this.game_state.game.physics.arcade.collide(this, this.game_state.groups.heroes, this.reach_exit, null, this);
};

ProceduralGeneration.Exit.prototype.reach_exit = function () {
    "use strict";
    if (this.game_state.groups.enemies.countLiving() === 0) {
        // restart the game
        this.game_state.game.state.start("DungeonState", true, false, 10);
    }
};