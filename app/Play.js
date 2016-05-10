/**
 * 
 * @author alina
 */
define('Play', ['orm', 'forms', 'ui'], function (Orm, Forms, Ui, ModuleName) {
    function module_constructor() {
        var self = this
                , model = Orm.loadModel(ModuleName)
                , form = Forms.loadForm(ModuleName, model);
        
        var matrix = [[0, 1, 0],[0, 2, 0],[1, 0, 0]];
        console.log(matrix);
        
        function onClick(evt){
            console.log(evt.source.row,evt.source.col);
        }
        
        function matrixDraw(){
            var rows = form.panel.rows;
            var columns = form.panel.columns;
            
            for(var i=0; i<rows;i++){
                for(var j=0; j<columns;j++){
                    var btn = form.panel.child(i,j);
                    if(matrix[i][j]===0){
                        btn.text = "";
                    }
                    if(matrix[i][j]===1){
                        btn.text = "O";
                        btn.selected = true;
                        btn.enabled = false;
                    }
                    if(matrix[i][j]===2){
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
            
            for(var i=0; i<rows;i++){
                for(var j=0; j<columns;j++){
                    var btn = form.panel.child(i,j);
                    btn.row = i;
                    btn.col = j;
                    btn.onActionPerformed = onClick;
                }
            }
            matrixDraw();
        };
        
        // TODO : place your code here
        
        model.requery(function () {
            // TODO : place your code here
        });
        
    }
    return module_constructor;
});
