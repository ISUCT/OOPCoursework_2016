/**
 * @public
 * @stateless
 * 
 * Note that Web Socket endpoint's module should have a solid name.
 * So, 3 argument define should be used or such module should be placed in the root folder - 'app'.
 */
define('ChatEndpoint', ['rpc', 'logger'], function (Lpc, Logger) {
    function mc() {
        var accounter = new Lpc.Proxy('ChatAccounter');

        this.onopen = function (session) {
            accounter.add(session.id, function (aData) {
                session.send(aData);
            });
        };
        this.onclose = function (evt) {
            // evt.id - Session id
            // evt.wasClean - True if session was closed without an error
            // evt.code - Session close code
            // evt.reason - Description of session close
            accounter.remove(evt.id);
        };
        this.onmessage = function (evt) {
            // evt.id - Session id
            // evt.data - Text data recieved from other (client) endpoint
            Logger.info(evt.data);
            var move = JSON.parse(evt.data);
            Logger.info(move);
            Logger.info(accounter.getMatrix(move, function (el) {
                Logger.info(el);
                accounter.broadcast(JSON.stringify(el));
            }));
            //accounter.broadcast(JSON.stringify(accounter.getMatrix()));
        };
        this.onerror = function (evt) {
            // evt.id - Session id
            // evt.message - Error message from container's exception
        };
    }
    return mc;
});

