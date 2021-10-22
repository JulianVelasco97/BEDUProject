public class InventarioBatch Implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Obtenemos todos los inventarios    
        String query = 'SELECT Id, Name, Cantidad_dis__c, Cantidad_apart__c,CodigoProd__c FROM Inventario__c';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Inventario__c> inventarios) {        
        // Procesar cada batch de registros (200 por defecto)
        List<Inventario__c> inventariosExternos = InventarioRestQuery.getExternalInventario();
        List<Inventario__c> inventariosExistentes = new List<Inventario__c>();
        List<Inventario__c> inventariosNuevos = new List<Inventario__c>();
        List<String> codProd = new List<String>();
        for(Inventario__c invent : inventarios){
            codProd.add(invent.CodigoProd__c);
        }
        for(Inventario__c inventextern : inventariosExternos) {
            if(codProd.contains(inventextern.CodigoProd__c)){
                inventariosExistentes.add(inventextern);
            }else{
                inventariosNuevos.add(inventextern);
            }
        }
        for(Inventario__c invent : inventarios) {        
            for(Inventario__c inventexist : inventariosExistentes) {  
                if(invent.CodigoProd__c == inventexist.CodigoProd__c){
                    invent.Cantidad_dis__c = inventexist.Cantidad_dis__c;
                    invent.Cantidad_apart__c = inventexist.Cantidad_apart__c;
                    invent.Name = inventexist.Name;
                }
            }
        }
        try {
            // Actualiar la lista de inventarios
            update inventarios;
            if(inventariosNuevos.size()>0){
                insert inventariosNuevos;
            }
        } catch(Exception e) {
            System.debug(e);
        }         
    }
    public void finish(Database.BatchableContext BC) {
        System.debug('Se ha actualizado la cantidad disponible');
    }
}