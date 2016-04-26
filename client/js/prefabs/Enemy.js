var ProceduralGeneration = ProceduralGeneration || {};

ProceduralGeneration.Enemy = function (game_state, name, position, properties) {
    "use strict";
    ProceduralGeneration.Prefab.call(this, game_state, name, position, properties);
    
    this.anchor.setTo(0.5);

    this.game_state.game.physics.arcade.enable(this);
    this.body.immovable = true;
};

ProceduralGeneration.Enemy.prototype = Object.create(ProceduralGeneration.Prefab.prototype);
ProceduralGeneration.Enemy.prototype.constructor = ProceduralGeneration.Enemy;

var popup;
var tween =null;
function popupwindow(){
    this.kill();
    createPopup();
    openWindow();
    game.globalcount += 1;
}
function createPopup(){
    //  You can drag the pop-up window around
    popup = game.add.sprite(game.world.centerX, game.world.centerY, 'background_image');
    popup.alpha = 0.8;
    popup.anchor.set(0.5);
    popup.inputEnabled = true;
    popup.input.enableDrag();
    //  Position the close button to the top-right of the popup sprite (minus 8px for spacing)
    var pw = (popup.width / 2) - 320;
    var ph = (popup.height / 2) - 500;

    //  And click the close button to close it down again
    var closeButton = game.make.sprite(pw, -ph, 'win_image');
    closeButton.inputEnabled = true;
    closeButton.input.priorityID = 1;
    closeButton.input.useHandCursor = true;
    closeButton.events.onInputDown.add(closeWindow, this);
    var lw = (popup.width/2) - 320 ;
    var lh = (popup.height/2) - 400;
    var loseButton = game.make.sprite(lw, -lh, 'lose_image');
    loseButton.inputEnabled = true;
    loseButton.input.priorityID = 2;
    loseButton.input.useHandCursor = true;
    loseButton.events.onInputDown.add(closeWindow, this);

    //  Add the "close button" to the popup window image
    popup.addChild(closeButton);

    //  Hide it awaiting a click
    popup.scale.set(0.1);
}

function openWindow() {

    if ((tween !== null && tween.isRunning) || popup.scale.x === 1)
    {
        return;
    }

    //  Create a tween that will pop-open the window, but only if it's not already tweening or open
    tween = game.add.tween(popup.scale).to( { x: 0.8, y: 0.8 }, 1000, Phaser.Easing.Elastic.Out, true);

}

function closeWindow() {

    if (tween && tween.isRunning || popup.scale.x === 0.1)
    {
        return;
    }
    console.log("closeWindow");
    //  Create a tween that will close the window, but only if it's not already tweening or closed
    tween = game.add.tween(popup.scale).to( { x: 0, y: 0 }, 500, Phaser.Easing.Elastic.In, true);

}
function mykill() {
    console.log("bbbbbb");
}
ProceduralGeneration.Enemy.prototype.update = function () {
    "use strict";
//    createPopup();
//    openWindow();
    this.game_state.game.physics.arcade.overlap(this, this.game_state.groups.heroes, popupwindow, null, this);
};
