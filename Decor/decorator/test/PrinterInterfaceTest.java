/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author 111
 */
public class PrinterInterfaceTest {
    
    public PrinterInterfaceTest() {
    }
    
    @BeforeClass
    public static void setUpClass() {
    }
    
    @AfterClass
    public static void tearDownClass() {
    }
    
    @Before
    public void setUp() {
    }
    
    @After
    public void tearDown() {
    }

    /**
     * Test of print method, of class PrinterInterface.
     */
    @Test
    public void testPrint() {
        System.out.println("print");
        PrinterInterface instance = new PrinterInterfaceImpl();
        instance.print();
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    public class PrinterInterfaceImpl implements PrinterInterface {

        public void print() {
        }
    }
    
}
