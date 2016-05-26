/**
 * 
 * @author alina
 */
define('Play', ['orm', 'forms', 'ui','logger'], function (Orm, Forms, Ui,Logger, ModuleName) {

    function module_constructor() {
        var self = this
                , model = Orm.loadModel(ModuleName)
                , form = Forms.loadForm(ModuleName, model);

        var matrix = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
//        console.log(matrix);


        function wsUrl() {
            var location = window.location;
            return (location.protocol === 'https:' ? 'wss:' : 'ws:')
                    + '//'
                    + location.host
                    + location.pathname.substring(0, location.pathname.lastIndexOf('/') + 1);
        }



        function onClick(evt) {
             wsProxy.send(JSON.stringify({row:evt.source.row,col: evt.source.col}));
        }

        function matrixDraw(matrix) {
            var rows = form.panel.rows;
            var columns = form.panel.columns;

            for (var i = 0; i < rows; i++) {
                for (var j = 0; j < columns; j++) {
                    var btn = form.panel.child(i, j);
                    if (matrix[i][j] === 0) {
                        btn.text = "";
                    }
                    if (matrix[i][j] === 1) {
                        btn.text = "O";
                        btn.selected = true;
                        btn.enabled = false;
                    }
                    if (matrix[i][j] === 2) {
                        btn.text = "X";
                        btn.selected = true;
                        btn.enabled = false;
                    }


                }
            }
        }

        self.show = function () {
            form.show();
            var rows = form.panel.rows;
            var columns = form.panel.columns;

            for (var i = 0; i < rows; i++) {
                for (var j = 0; j < columns; j++) {
                    var btn = form.panel.child(i, j);
                    btn.row = i;
                    btn.col = j;
                    btn.onActionPerformed = onClick;
                }
            }
            matrixDraw(matrix);
        };

        var wsProxy;

        form.onWindowOpened = function () {
            /**
             * Note that Web Socket endpoint's module should have a solid name.
             * (e.g. 3 argument define should be used or such module should be placed in the root folder - 'app')
             * @see 'ChatEndpoint' module itself.
             */
            wsProxy = new WebSocket(wsUrl() + 'ChatEndpoint');

            wsProxy.onopen = function () {
                Logger.info('Subscribed');
            };

            wsProxy.onerror = function (evt) {
                Logger.info('Web scket error occured');
            };

            wsProxy.onmessage = function (evt) {
                Logger.info('Message - ' + evt.data);
                matrixDraw(JSON.parse(evt.data));
            };

            wsProxy.onclose = function () {
                Logger.info('Unsubscribed');
            };
        };

        form.onWindowClosed = function (evt) {
            wsProxy.close();
        };





    }
    return module_constructor;
    

});
