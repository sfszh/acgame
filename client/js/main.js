var ProceduralGeneration = ProceduralGeneration || {};

var game = new Phaser.Game(600, 600, Phaser.CANVAS);
game.state.add("BootState", new ProceduralGeneration.BootState());
game.state.add("LoadingState", new ProceduralGeneration.LoadingState());
game.state.add("DungeonState", new ProceduralGeneration.DungeonState());
game.state.add("RoomState", new ProceduralGeneration.RoomState());
game.state.start("DungeonState", true, false, 10);
game.globalcount = 0;
