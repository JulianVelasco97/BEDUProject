public class PresupuestoTriggerHandler implements ITriggerHandler{
    
    private static void handlernuevoPresupuesto(list<Quote> presupuestos){
    	for(Quote presupuesto : presupuestos){
        	if(presupuesto.Status == 'Aprobado' || presupuesto.Status == 'Aceptado') {
            	presupuesto.AddError('No es posible inicializar un presupuesto en esta etapa, por favor verificar');
            }
        }
    }
    
    private static void handlerStatus(list<Quote> presupuestos){
        for(Quote presupuesto : presupuestos){
            if((presupuesto.Status == 'Aprobado' || presupuesto.Status == 'Aceptado') && presupuesto.LineItemCount <1) {
                presupuesto.AddError('No se puede avanzar a esta etapa si no se tienen productos en el presupuesto');
            }
        }
    }
    
    private static void ActualizarCantidadDisponible(list<Quote> presupuestos){
        set<id> idspre = new set<id>();
        for(Quote presu: presupuestos){
            idspre.add(presu.id);
        }
        list<QuoteLineItem> partidasDePresupuesto = [SELECT Id, Quantity, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId IN: idspre];
        List<string> codprod = new List<string>();
        for(QuoteLineItem partPres: partidasDePresupuesto){
            codprod.add(partPres.Product2.ProductCode);
        }
        list<Inventario__c> inventariosActuales = [SELECT Id, Cantidad_apart__c, Cantidad_dis__c, CodigoProd__c, Name FROM Inventario__c WHERE CodigoProd__c IN:codprod];
        for (QuoteLineItem partPres : partidasDePresupuesto){
            for(Inventario__c invent : inventariosActuales){
                if(invent.CodigoProd__c == partPres.Product2.ProductCode)
                invent.Cantidad_apart__c = invent.Cantidad_apart__c + partPres.Quantity;
                invent.Cantidad_dis__c = invent.Cantidad_dis__c - partPres.Quantity;
        	}
        }
         update inventariosActuales;
    }
    
    public void beforeInsert(List<sObject> newList) {
        list<Quote> presupuestos = new list<Quote>();
        for(sobject obj : newList){
            presupuestos.add((Quote)obj);
        }
        handlernuevoPresupuesto(presupuestos);
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        list<Quote> presupuestos = new list<Quote>();
        for(sobject obj : newList){
            presupuestos.add((Quote)obj);
        }
        handlerStatus(presupuestos);

    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        list<Quote> presupuestos = new list<Quote>();
        for(sobject obj : newList){
            presupuestos.add((Quote)obj);
        }
        ActualizarCantidadDisponible(presupuestos);
    }
    
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        
    }
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
}