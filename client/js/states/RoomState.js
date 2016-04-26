var ProceduralGeneration = ProceduralGeneration || {};

ProceduralGeneration.RoomState = function () {
    "use strict";
    Phaser.State.call(this);
    
    this.MAP_KEY = "room_tilemap";
    this.MAP_TILESET = "dungeon_tileset";
    
    this.prefab_classes = {
        "hero": ProceduralGeneration.Hero.prototype.constructor,
        "door": ProceduralGeneration.Door.prototype.constructor,
        "enemy": ProceduralGeneration.Enemy.prototype.constructor,
        "exit": ProceduralGeneration.Exit.prototype.constructor
    };
};

ProceduralGeneration.RoomState.prototype = Object.create(Phaser.State.prototype);
ProceduralGeneration.RoomState.prototype.constructor = ProceduralGeneration.RoomState;

ProceduralGeneration.RoomState.prototype.init = function (level_data, extra_parameters) {
    "use strict";
    var tileset_index, tile_dimensions;
    this.level_data = this.level_data || level_data;
    
    this.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL;
    this.scale.pageAlignHorizontally = true;
    this.scale.pageAlignVertically = true;
    
    // start physics system
    this.game.physics.startSystem(Phaser.Physics.ARCADE);
    this.game.physics.arcade.gravity.y = 0;
    
    // get current room
    this.room = extra_parameters.room;
};

ProceduralGeneration.RoomState.prototype.preload = function () {
    "use strict";
    this.load.tilemap(this.MAP_KEY, "assets/maps/" + this.room.template_name(), null, Phaser.Tilemap.TILED_JSON);
};

ProceduralGeneration.RoomState.prototype.create = function () {
    "use strict";
    var group_name, object_layer, collision_tiles, new_prefab;
    // create map
    this.map = this.game.add.tilemap(this.MAP_KEY);
    this.map.addTilesetImage(this.map.tilesets[0].name, this.MAP_TILESET);
    
    // create map layers
    this.layers = {};
    this.map.layers.forEach(function (layer) {
        this.layers[layer.name] = this.map.createLayer(layer.name);
        if (layer.properties.collision) { // collision layer
            this.map.setCollisionByExclusion([-1], true, layer.name);
        }
    }, this);
    // resize the world to be the size of the current layer
    this.layers[this.map.layer.name].resizeWorld();
    
    // create groups
    this.groups = {};
    this.level_data.groups.forEach(function (group_name) {
        this.groups[group_name] = this.game.add.group();
    }, this);
    
    this.prefabs = {};
    
    // create objects (prefabs)
    for (object_layer in this.map.objects) {
        if (this.map.objects.hasOwnProperty(object_layer)) {
            // create layer objects
            this.map.objects[object_layer].forEach(this.create_object, this);
        }
    }
    
    // add tiles to the room
    this.room.tiles.forEach(function (tile) {
        this.map.putTile(tile.tile, tile.position.x, tile.position.y, tile.layer);
    }, this);
    
    this.room.prefabs.forEach(function (prefab) {
        new_prefab = new this.prefab_classes[prefab.prefab](this, prefab.name, prefab.position, prefab.properties);
    }, this);
};

ProceduralGeneration.RoomState.prototype.create_object = function (object) {
    "use strict";
    var object_y, position, prefab;
    // tiled coordinates starts in the bottom left corner
    object_y = (object.gid) ? object.y - (this.map.tileHeight / 2) : object.y + (object.height / 2);
    position = {"x": object.x + (this.map.tileHeight / 2), "y": object_y};
    // create object according to its type
    if (this.prefab_classes.hasOwnProperty(object.type)) {
        prefab = new this.prefab_classes[object.type](this, object.name, position, object.properties);
    }
    this.prefabs[object.name] = prefab;
};
