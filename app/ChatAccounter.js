/**
 * @resident
 */
define(function () {

    var sessions = {};
    var matrix = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
    var i=0;
    function mc() {

        this.add = function (aSessionId, aOnMessage) {
            sessions[aSessionId] = aOnMessage;
        };
        this.remove = function (aSessionId) {
            delete sessions[aSessionId];
        };

        this.getMatrix = function (userMove,aOnSuccess) {
            i++;
            if (i>2){
                i=1;
            }
            matrix[userMove.row][userMove.col] = i;
            aOnSuccess(matrix);
            
        };

        this.broadcast = function (aData) {
            for (var s in sessions) {
                sessions[s](aData);// Always async call because of LPC mechanism.
            }
        };
    }
    return mc;
});