/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author 111
 */
public class DecoratorApp {
    public static void main (String[] args){
        PrinterInterface printer = new Printer("Hello");
            printer.print();
        PrinterInterface printer = new QuotesDecorator("Hello");
            printer.print();
    }

         
    
}

interface PrinterInterface{
    void print();
}

class Printer implements PrinterInterface{
    String value;
    public Printer (String value) {this.value = value;}
    public void print(){
    System.out.print(value);
    }

abstract class Decorator implements PrinterInterface {
    PrinterInterface component;
    public Decorator(PrinterInterface component) {this.component = component;}
}
class QuotesDecorator implements PrinterInterface{
    PrinterInterface component;
    public QuotesDecorator(PrinterInterface component) {this.component = component;}
    public void print(){
        System.out.print("\"");
        component.print();
        System.out.print("\"");
    }
            
}
}