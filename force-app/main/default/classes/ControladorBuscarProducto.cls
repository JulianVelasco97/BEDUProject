public with sharing class ControladorBuscarProducto {
    @AuraEnabled(cacheable=true)	
    public static list<Producto> getProductos(string searchKey){
        try{
            list<Producto> retorno = new list<Producto>();
            PriceBookEntry query = [SELECT Id, Product2Id, Product2.Name, UnitPrice, ProductCode FROM PricebookEntry WHERE ProductCode  =: searchKey  AND Product2.isactive = true  AND IsActive = true LIMIT 1];
            system.debug('query-->'+query);
            Inventario__c inventarios = [SELECT Id, CodigoProd__c, Cantidad_dis__c, Cantidad_apart__c FROM Inventario__c WHERE CodigoProd__c =: searchKey];
            system.debug('inventarios-->'+inventarios);
            Producto prod = new Producto();
            prod.PriceBookEntryId = query.Id;
            prod.ProductName = query.Product2.Name;
            prod.ListPrice = query.UnitPrice;
            prod.ProductCode = query.ProductCode;
            prod.Available = inventarios.Cantidad_dis__c;
            retorno.add(prod);
            system.debug('retorno-->'+retorno);
            return retorno;
        }catch(QueryException ex){
            string error ='No es posible encontrar el producto solicitado';
            AuraHandledException e = new AuraHandledException(error);
            e.setMessage(error);
            throw e;
        }

        
    }
    
    @AuraEnabled	
    public static void CreateQuoteLineItem(list<Producto> Productos){
        try{
            list<QuoteLineItem> lista = new list<QuoteLineItem>();
            for(Producto prod : Productos){
                QuoteLineItem presup = new QuoteLineItem();
                presup.pricebookEntryId = prod.PricebookEntryId;
                presup.QuoteId = prod.quoteId;
                presup.UnitPrice = prod.ListPrice;
                presup.Quantity = prod.Quantity;
                lista.add(presup);
            }
            System.debug('lista-->'+lista);
            insert lista;
        }catch(QueryException ex){
            string error ='No es posible crear la partida de presupuesto, porfavor verificar los datos ingresados';
            AuraHandledException e = new AuraHandledException(error);
            e.setMessage(error);
            throw e;
        }
        
    }

    public class Producto{
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string ProductName {get;set;}
        @AuraEnabled
        public double ListPrice {get;set;}
        @AuraEnabled
        public string ProductCode {get;set;}
        @AuraEnabled
        public integer Quantity {get;set;}
        @AuraEnabled
        public decimal Available {get;set;}
        @AuraEnabled
        public string opportunityId {get;set;}
        @AuraEnabled
        public string PriceBookEntryId {get;set;}
        @AuraEnabled
        public string quoteId {get;set;}
        public Producto(){
        }
    }
}