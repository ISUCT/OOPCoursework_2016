/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
var player; // player whose turn it is, 'x' or 'o'
var winner; // undefined (game in-progress), false (draw) or 'x' or 'o'
var winFrom, winTo; // start/end coordinates for winning sequence
var state; // state of board (matrix of undefined, 'x' and 'o')

$('td').click(function(e) {
    var x = $(e.target).index();
    var y = $(e.target).parent().index();
    
    makeMove(x, y);
    checkWinner();
    updateBoard();
    
    if (winner) {
        document.getElementById('tuturu').play();
    }
    else if (winner === false) {
        document.getElementById('sadtrombone').play();
    }
});

$('.reset').click(function() {
    reset();
    updateBoard();
});

reset(); // need to do an initial reset on load to set everything up

function reset() {
    player = 'x'; // x goes first
    winner = undefined;
    winFrom = undefined;
    winTo = undefined;
    state = [
        new Array(3),
        new Array(3),
        new Array(3)
    ];
}

function makeMove(x, y) {
    if (winner === undefined && !state[y][x]) {
        state[y][x] = player;
        
        if (player === 'x') {
            player = 'o'
        }
        else {
            player = 'x';
        }
    }
}

function updateBoard() {
    for (var i = 0; i < state.length; i++) {
        for (var j = 0; j < state[i].length; j++) {
            var cell = state[i][j];
            var td = $('tr').eq(i).find('td').eq(j);
            
            if (cell) {
                td.attr('data-player', cell);
            }
            else {
                td.removeAttr('data-player');
            }
        }
    }
    
    var overlay = document.getElementById('overlay');
    var ctx = overlay.getContext('2d');
    ctx.clearRect(0, 0, overlay.width, overlay.height);
    if (winner !== undefined) {
        $('.t3').attr('data-winner', winner);
        
        if (winner) {
            ctx.beginPath();
            ctx.moveTo(
                50 + winFrom[1] * 102,
                50 + winFrom[0] * 102);
            ctx.lineTo(
                50 + winTo[1] * 102,
                50 + winTo[0] * 102);
            ctx.lineCap = 'round';
            ctx.lineWidth = 15;
            ctx.strokeStyle = "rgba(204, 0, 0, 0.25)";
            ctx.stroke();
        }
    }
    else {
        $('.t3').removeAttr('data-winner');
    }
}

function checkWinner() {
    // check each row for a winner
    for (var i = 0; i < state.length; i++) {
        var cells = state[i];
        if (isWinning(cells)) {
            winner = cells[0];
            winFrom = [i, 0];
            winTo = [i, 2];
        }
    }
    
    // check each column for a winner
    for (var i = 0; i < state.length; i++) {
        var cells = [state[0][i], state[1][i], state[2][i]];
        if (isWinning(cells)) {
            winner = cells[0];
            winFrom = [0, i];
            winTo = [2, i];
        }
    }
    
    // check the top-left/bottom-right diagonal for a winner
    var cells = [state[0][0], state[1][1], state[2][2]];
    if (isWinning(cells)) {
        winner = cells[0];
        winFrom = [0, 0];
        winTo = [2, 2];
    }
    
    // check the top-right/bottom-left diagonal for a winner
    var cells = [state[0][2], state[1][1], state[2][0]];
    if (isWinning(cells)) {
        winner = cells[0];
        winFrom = [0, 2];
        winTo = [2, 0];
    }
    
    if (winner === undefined) {
        var anyEmptyCells = false;
        for (var i = 0; i < state.length; i++) {
            for (var j = 0; j < state.length; j++) {
                if (!state[i][j]) {
                    var anyEmptyCells = true;
                }
            }
        }
        
        if (!anyEmptyCells) {
            winner = false; // indicates a draw
        }
    }
}

function isWinning(cells) {
    // must be at least one cell!
    if (cells.length < 1)
        return false;
    
    // must be something in the first cell
    if (!cells[0])
        return false;
    
    // all other cells must have the same value as the first cell
    for (var i = 1; i < cells.length; i++) {
        if (cells[i] !== cells[0])
            return false;
    }
    
    return true;
}
