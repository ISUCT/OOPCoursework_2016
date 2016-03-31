/**
 * 
 * @author mg
 */
function WebSocketTestClient() {
    var testWsData = '--test web socket data--';
    var self = this;

    self.execute = function (aOnSuccess) {

        var wsProtocol = "ws:";
        if (window.location.protocol == 'https:')
            wsProtocol = "wss:";

        // Unfortunately, only solid WebSocket modules names are allowed
        var webSocket = new WebSocket(wsProtocol + "//" + window.location.host + window.location.pathname.substr(0, window.location.pathname.lastIndexOf("/")) + "/ChatEndpoint");
        webSocket.onopen = function () {
            P.Logger.info("Ws.onOpen");
            webSocket.send(testWsData);
        };

        webSocket.onerror = function () {
            P.Logger.info("Ws.onError");
        };

        webSocket.onmessage = function (evt) {
            if (evt.data !== testWsData) {
                throw "Web socket data violation";
            } else {
                webSocket.close();
                aOnSuccess();
            }
            P.Logger.info("Ws.onMessage");
        };

        webSocket.onclose = function (evt) {
            P.Logger.info("Ws.onClose");
        };

    };
}
