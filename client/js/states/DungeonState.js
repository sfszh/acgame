var ProceduralGeneration = ProceduralGeneration || {};

ProceduralGeneration.DungeonState = function () {
    "use strict";
    Phaser.State.call(this);

    this.LEVEL_FILE = "assets/levels/room_level.json";
};

ProceduralGeneration.DungeonState.prototype = Object.create(Phaser.State.prototype);
ProceduralGeneration.DungeonState.prototype.constructor = ProceduralGeneration.DungeonState;

ProceduralGeneration.DungeonState.prototype.init = function (number_of_rooms) {
    "use strict";
    this.number_of_rooms = number_of_rooms;
    this.dungeon = this.dungeon || new ProceduralGeneration.Dungeon(this);
};

ProceduralGeneration.DungeonState.prototype.preload = function () {
    "use strict";
    // load the population JSON file
    this.load.text("population", "assets/levels/population.json");
};

ProceduralGeneration.DungeonState.prototype.create = function () {
    "use strict";
    var initial_room;
    // generate new dungeon
    initial_room = this.dungeon.generate_dungeon(this.number_of_rooms);
    // start RoomState for the initial room of the dungeon
    this.game.state.start("BootState", true, false, this.LEVEL_FILE, "RoomState", {room: initial_room});
};
