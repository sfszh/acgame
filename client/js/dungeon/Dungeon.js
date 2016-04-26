var ProceduralGeneration = ProceduralGeneration || {};

ProceduralGeneration.Dungeon = function (game_state) {
    "use strict";
    this.TILE_DIMENSIONS = new Phaser.Point(40, 40);

    this.game_state = game_state;
};

ProceduralGeneration.Dungeon.prototype.generate_dungeon = function (number_of_rooms) {
    "use strict";
    var grid_size, rooms_to_creates, current_room_coordinate, current_room, created_rooms, initial_room_coordinate, final_room_coordinate, max_distance_to_initial_room, distance_to_initial_room, population;
    // initialize the grid
    grid_size = 2 * number_of_rooms;
    this.initialize_grid(grid_size);

    // add the middle coordinate as initial
    initial_room_coordinate = new Phaser.Point((grid_size / 2) - 1, (grid_size / 2) - 1);
    final_room_coordinate = new Phaser.Point(initial_room_coordinate.x, initial_room_coordinate.y);
    rooms_to_creates = [];
    rooms_to_creates.push({row: initial_room_coordinate.y, column: initial_room_coordinate.x});
    created_rooms = [];
    // iterate creating rooms
    while (rooms_to_creates.length > 0 && created_rooms.length < number_of_rooms) {
        current_room_coordinate = rooms_to_creates.shift();
        // create room with current coordinate
        current_room = new ProceduralGeneration.Room(this.game_state, current_room_coordinate, this.TILE_DIMENSIONS);
        this.grid[current_room_coordinate.row][current_room_coordinate.column] = current_room;
        created_rooms.push(current_room);
        // add random number of neighbors to rooms_to_create
        this.check_for_neighbors(current_room, rooms_to_creates);
    }

    // load the population data from the JSON file
    population = JSON.parse(this.game_state.game.cache.getText("population"));
    
    max_distance_to_initial_room = 0;
    // iterate through rooms to connect and populate them
    created_rooms.forEach(function (room) {
        room.neighbor_coordinates().forEach(function (coordinate) {
            if (this.grid[coordinate.row][coordinate.column]) {
                room.connect(coordinate.direction, this.grid[coordinate.row][coordinate.column]);
            }
        }, this);
        // populate the room
        room.populate(population);
        
        // check distance to the initial room
        distance_to_initial_room = Math.abs(room.coordinate.column - initial_room_coordinate.x) + Math.abs(room.coordinate.row - initial_room_coordinate.y);
        if (distance_to_initial_room > max_distance_to_initial_room) {
            final_room_coordinate.x = room.coordinate.column;
            final_room_coordinate.y = room.coordinate.row;
        }
    }, this);
    
    this.grid[final_room_coordinate.y][final_room_coordinate.x].populate_prefabs(1, [{prefab: "exit", properties: {texture: "exit_image", group: "exits"}}]);

    return this.grid[initial_room_coordinate.y][initial_room_coordinate.x];
};

ProceduralGeneration.Dungeon.prototype.print_grid = function () {
    "use strict";
    var row_index, column_index, row;
    for (row_index = 0; row_index < this.grid.length; row_index += 1) {
        row = "";
        for (column_index = 0; column_index < this.grid[row_index].length; column_index += 1) {
            if (this.grid[row_index][column_index]) {
                row += "R";
            } else {
                row += "X";
            }
        }
        console.log(row);
    }
};

ProceduralGeneration.Dungeon.prototype.initialize_grid = function (grid_size) {
    "use strict";
    var row_index, column_index;
    this.grid = [];
    // initialize all rooms as null
    for (row_index = 0; row_index < grid_size; row_index += 1) {
        this.grid.push([]);
        for (column_index = 0; column_index < grid_size; column_index += 1) {
            this.grid[row_index].push(null);
        }
    }
};

ProceduralGeneration.Dungeon.prototype.check_for_neighbors = function (room, rooms_to_creates) {
    "use strict";
    var coordinates_to_check, available_neighbors, number_of_neighbors, neighbor_index, random_number, room_frac, available_neighbor_index;
    coordinates_to_check = room.neighbor_coordinates();
    available_neighbors = [];
    // find neighbor coordinates that are free
    coordinates_to_check.forEach(function (coordinate) {
        if (!this.grid[coordinate.row][coordinate.column]) {
            available_neighbors.push(coordinate);
        }
    }, this);
    // select random number of neighbors
    number_of_neighbors = this.game_state.game.rnd.between(1, available_neighbors.length - 1);

    // select the neighbor coordinates
    for (neighbor_index = 0; neighbor_index < number_of_neighbors; neighbor_index += 1) {
        random_number = this.game_state.game.rnd.frac();
        room_frac = 1 / available_neighbors.length;
        // assign a range to each neighbor and select the one whose range contains room_frac
        for (available_neighbor_index = 0; available_neighbor_index < available_neighbors.length; available_neighbor_index += 1) {
            if (random_number < room_frac) {
                rooms_to_creates.push(available_neighbors[available_neighbor_index]);
                available_neighbors.splice(available_neighbor_index, 1);
                break;
            } else {
                room_frac += (1 / available_neighbors.length);
            }
        }
    }
};
