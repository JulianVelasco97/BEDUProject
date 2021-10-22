//para que salesforce sepa que es una prueba 
@isTest
public class ControladorBuscarProductoTest {
	@testSetup static void setup() {
        // Creamos registros necesarios para realizar la prueba
        Pricebook2 pb = new Pricebook2(Name = 'Price Book TEST', Description = 'Price Book TEST', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'Product TEST', ProductCode ='PT-1', IsActive = true);
        insert prod;
        // First insert a price for the standard price book
        id standardPB = Test.getStandardPricebookId();
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;
        Inventario__c inventario = new Inventario__c(CodigoProd__c = prod.ProductCode, Cantidad_dis__c = 100, Cantidad_apart__c = 5, Name=prod.Name);
        insert inventario;   
        Opportunity oportunidad = new Opportunity(Name='Oportunidad Test', StageName='presupuesto', CloseDate=date.today(),Pricebook2Id =pb.Id);
        insert oportunidad;
        Quote presupuesto = new Quote(Name='Presupuesto Test', OpportunityId= oportunidad.Id, Pricebook2Id=pb.Id);
        insert presupuesto;
    }
       
    @isTest static void getProductosTest() {
        List<ControladorBuscarProducto.Producto> productos = new List<ControladorBuscarProducto.Producto>();
        productos = ControladorBuscarProducto.getProductos('PT-1');
        system.assert(productos.size() > 0);
    }

    @isTest static void getProductosTestFail() {
        try {
            list<ControladorBuscarProducto.Producto> producto = ControladorBuscarProducto.getProductos('PT-2');
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getTypeName());
            System.assertEquals('No es posible encontrar el producto solicitado', e.getMessage());
        }     
    }
    
    @isTest static void CreateQuoteLineItemTest() {
        List<ControladorBuscarProducto.Producto> productos = new List<ControladorBuscarProducto.Producto>();
        Quote presupuestos = [SELECT Name,OpportunityId FROM Quote WHERE Name='Presupuesto Test' LIMIT 1];       
        productos = ControladorBuscarProducto.getProductos('PT-1');
        for (ControladorBuscarProducto.Producto produc : productos){
            produc.Quantity = 10;
            produc.quoteId =presupuestos.Id;
            
        }
        ControladorBuscarProducto.CreateQuoteLineItem(productos);
        System.assert(System.isQueueable());
    }

    @isTest static void CreateQuoteLineItemTestFail() {
        try {
            List<ControladorBuscarProducto.Producto> productos = new List<ControladorBuscarProducto.Producto>();
            ControladorBuscarProducto.CreateQuoteLineItem(productos);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getTypeName());
            System.assertEquals('No es posible crear la partida de presupuesto, porfavor verificar los datos ingresados', e.getMessage());
        }     
    }    
}