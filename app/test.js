/**
 * 
 * @author alina
 */
define('test', ['orm', 'forms', 'ui'], function (Orm, Forms, Ui, ModuleName) {
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

        form.button.onActionPerformed = function () {
            form.label.text = "Hello";
        };

        form.button1.onActionPerformed = function () {
            form.label1.text = form.textField.text;
        };

        form.button2.onActionPerformed = function () {
            form.label2.text = (+form.textField1.text) + (+form.textField2.text);
        };
    }
    return module_constructor;
});
