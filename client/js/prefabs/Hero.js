var ProceduralGeneration = ProceduralGeneration || {};

ProceduralGeneration.Hero = function (game_state, name, position, properties) {
    "use strict";
    ProceduralGeneration.Prefab.call(this, game_state, name, position, properties);
    
    this.anchor.setTo(0.5);
    
    this.walking_speed = +properties.walking_speed;

    this.game_state.game.physics.arcade.enable(this);
    this.body.collideWorldBounds = true;
    
    this.animations.add("walking", [0, 1], 6, true);
    
    this.cursors = this.game_state.game.input.keyboard.createCursorKeys();
};

ProceduralGeneration.Hero.prototype = Object.create(ProceduralGeneration.Prefab.prototype);
ProceduralGeneration.Hero.prototype.constructor = ProceduralGeneration.Hero;

ProceduralGeneration.Hero.prototype.update = function () {
    "use strict";
    this.game_state.game.physics.arcade.collide(this, this.game_state.layers.collision);
    
    if (this.cursors.left.isDown && this.body.velocity.x <= 0) { // move left if is not already moving right
        this.body.velocity.x = -this.walking_speed;
        this.scale.setTo(1, 1);
    } else if (this.cursors.right.isDown && this.body.velocity.x >= 0) { // move right if is not already moving left
        this.body.velocity.x = +this.walking_speed;
        this.scale.setTo(-1, 1);
    } else {
        this.body.velocity.x = 0;
    }

    if (this.cursors.up.isDown && this.body.velocity.y <= 0) { // move up if is not already moving down
        this.body.velocity.y = -this.walking_speed;
    } else if (this.cursors.down.isDown && this.body.velocity.y >= 0) { // move down if is not already moving up
        this.body.velocity.y = +this.walking_speed;
    } else {
        this.body.velocity.y = 0;
    }
    
    if (this.body.velocity.x === 0 && this.body.velocity.y === 0) {
        this.animations.stop();
        this.frame = 0;
    } else {
        // if not moving, stop the animation
        this.animations.play("walking");
    }
};