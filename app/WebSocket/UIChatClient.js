/**
 * 
 * @author jskonst
 */
define('UIChatClient', ['orm', 'forms', 'ui', 'logger','forms/box-pane']
        , function (Orm, Forms, Ui, Logger,BoxPane, ModuleName) {
            function module_constructor() {
                var self = this
                        , model = Orm.loadModel(ModuleName)
                        , form = Forms.loadForm(ModuleName, model);

                self.show = function () {
                    form.show();
                };

                // TODO : place your code here

                model.requery(function () {
                    // TODO : place your code here
                });

                var wsProtocol = "ws:";
                if (window.location.protocol == 'https:')
                    wsProtocol = "wss:";

                // Unfortunately, only solid WebSocket modules names are allowed
                var webSocket = new WebSocket(wsProtocol + "//" + window.location.host + window.location.pathname.substr(0, window.location.pathname.lastIndexOf("/")) + "/ChatEndpoint");
                webSocket.onopen = function () {
                    Logger.info("Ws.onOpen");
                    webSocket.send("Hello Connection");
                };

                webSocket.onerror = function () {
                    Logger.info("Ws.onError");
                };

                webSocket.onmessage = function (evt) {
                    Logger.info("Ws.onMessage");
                    var msgBox = new BoxPane();
                    msgBox.element.innerHTML = evt.data;
                    form.panel.add(msgBox);
                };

                webSocket.onclose = function (evt) {
                    Logger.info("Ws.onClose");
                };

                form.btnSend.onActionPerformed = function () {
                    webSocket.send(form.htmlArea.value);
                    form.htmlArea.value = "";
                    Logger.info("Send");
                };


            }
            return module_constructor;
        });
