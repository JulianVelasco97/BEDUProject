@isTest
public class PresupuestoTriggerHandlerTest {
	       
    @testSetup static void setup() {
        // Creamos registros necesarios para realizar la prueba
        Pricebook2 pb = new Pricebook2(Name = 'Price Book TEST', Description = 'Price Book TEST', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'Product TEST', ProductCode ='PT-1', IsActive = true);
        insert prod;
        // Primero inserte un precio para la lista de precios estándar 
        id standardPB = Test.getStandardPricebookId();
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;
        Inventario__c inventario = new Inventario__c(CodigoProd__c = prod.ProductCode, Cantidad_dis__c = 1000, Cantidad_apart__c = 5, Name=prod.Name);
        insert inventario;   
        Opportunity oportunidad = new Opportunity(Name='Oportunidad Test Trigger', StageName='Qualification', CloseDate=date.today(),Pricebook2Id =pb.Id);
        insert oportunidad;
    }
    
    @isTest static void handlernuevoPresupuestoTest() {
        Opportunity oportunidad = [SELECT Name, StageName, CloseDate FROM Opportunity WHERE Name='Oportunidad Test Trigger'];
        Quote presupuesto = new Quote(Name = 'Presupuesto Test Trigger', OpportunityId = oportunidad.Id, Status = 'Borrador');
        Test.startTest();
        //Nos permite obtener el resultado del la insercion, sin importar que alguno falle, con el objetivo de ver cual fallo
        Database.SaveResult result = Database.insert(presupuesto, false);
        Test.stopTest();
        //verifica si el resultado fue exitoso
        System.assert(result.isSuccess());
    }
    
    @isTest static void handlernuevoPresupuestoTestFail() {
        Opportunity oportunidad = [SELECT Name, StageName, CloseDate FROM Opportunity WHERE Name='Oportunidad Test Trigger'];
        Quote presupuesto = new Quote(Name = 'Presupuesto Test Trigger', OpportunityId = oportunidad.Id, Status = 'Aprobado');
        Test.startTest();
        Database.SaveResult result = Database.insert(presupuesto, false);
        Test.stopTest();
        System.assertEquals('No es posible inicializar un presupuesto en esta etapa, por favor verificar',
                             result.getErrors()[0].getMessage());
    }
    
    @isTest static void handlerStatusTest() {
        Opportunity oportunidad = [SELECT Name, StageName, CloseDate FROM Opportunity WHERE Name='Oportunidad Test Trigger'];
        Product2 prod = [SELECT Name, ProductCode, IsActive FROM Product2 WHERE Name='Product TEST'];
        Pricebook2 priceBook = [SELECT Name, Description, IsActive FROM Pricebook2 WHERE Name = 'Price Book TEST'];
        PricebookEntry entrListPrecio = [SELECT Pricebook2Id, Product2Id, UnitPrice, IsActive FROM PricebookEntry WHERE Pricebook2Id=:priceBook.Id AND Product2Id=:prod.Id];
        Quote presupuesto = new Quote(Name = 'Presupuesto Test Trigger', OpportunityId = oportunidad.Id, Status = 'Borrador');
        insert presupuesto;
        QuoteLineItem partPresupuesto = new QuoteLineItem(QuoteId = presupuesto.Id, PricebookEntryId=entrListPrecio.Id, Quantity=100, UnitPrice=100, Product2Id=prod.Id);
        insert partPresupuesto;
        presupuesto.Status = 'Aprobado';
        Test.startTest();
        //Nos permite obtener el resultado del la insercion, sin importar que alguno falle, con el objetivo de ver cual fallo
        Database.SaveResult result = Database.update(presupuesto, false);
        Test.stopTest();
        //verifica si el resultado fue exitoso
        System.assert(result.isSuccess());
    }
    
    @isTest static void handlerStatusTestFail() {
        Opportunity oportunidad = [SELECT Name, StageName, CloseDate FROM Opportunity WHERE Name='Oportunidad Test Trigger'];
        Product2 prod = [SELECT Name, ProductCode, IsActive FROM Product2 WHERE Name='Product TEST'];
        Pricebook2 priceBook = [SELECT Name, Description, IsActive FROM Pricebook2 WHERE Name = 'Price Book TEST'];
        PricebookEntry entrListPrecio = [SELECT Pricebook2Id, Product2Id, UnitPrice, IsActive FROM PricebookEntry WHERE Pricebook2Id=:priceBook.Id AND Product2Id=:prod.Id];
        Quote presupuesto = new Quote(Name = 'Presupuesto Test Trigger', OpportunityId = oportunidad.Id, Status = 'Borrador');
        insert presupuesto;
        presupuesto.Status = 'Aprobado';
        Test.startTest();
        //Nos permite obtener el resultado del la insercion, sin importar que alguno falle, con el objetivo de ver cual fallo
        Database.SaveResult result = Database.update(presupuesto, false);
        Test.stopTest();
        System.assertEquals('No se puede avanzar a esta etapa si no se tienen productos en el presupuesto',
                             result.getErrors()[0].getMessage());
    }
    
    @isTest static void ActualizarCantidadDisponibleTest() {
        Opportunity oportunidad = [SELECT Name, StageName, CloseDate FROM Opportunity WHERE Name='Oportunidad Test Trigger'];
        Product2 prod = [SELECT Name, ProductCode, IsActive FROM Product2 WHERE Name='Product TEST'];
        Pricebook2 priceBook = [SELECT Name, Description, IsActive FROM Pricebook2 WHERE Name = 'Price Book TEST'];
        PricebookEntry entrListPrecio = [SELECT Pricebook2Id, Product2Id, UnitPrice, IsActive FROM PricebookEntry WHERE Pricebook2Id=:priceBook.Id AND Product2Id=:prod.Id];
        Quote presupuesto = new Quote(Name = 'Presupuesto Test Trigger', OpportunityId = oportunidad.Id, Status = 'Borrador');
        insert presupuesto;
        QuoteLineItem partPresupuesto = new QuoteLineItem(QuoteId = presupuesto.Id, PricebookEntryId=entrListPrecio.Id, Quantity=100, UnitPrice=100, Product2Id=prod.Id);
        Test.startTest();
        //Nos permite obtener el resultado del la insercion, sin importar que alguno falle, con el objetivo de ver cual fallo
        Database.SaveResult result = Database.insert(partPresupuesto, false);
        Test.stopTest();
        //verifica si el resultado fue exitoso
        System.assert(result.isSuccess());
    }
}