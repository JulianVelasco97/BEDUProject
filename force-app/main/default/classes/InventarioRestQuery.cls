public class InventarioRestQuery {
    public static List<Inventario__c> getExternalInventario(){
        List<Inventario__c> inventarioRetorno = new List<Inventario__c>();
        Http http = new Http();
        HttpRequest solicitud = new HttpRequest();
        solicitud.setEndpoint('https://64bjp0q5wg.execute-api.us-east-2.amazonaws.com/Implement/');
    	solicitud.setMethod('GET');
        HttpResponse respuesta = http.send(solicitud);
        if (respuesta.getStatusCode()==200){
            //respuesta.getBody()-->nos trar el JSON
            System.debug ('respuesta-->'+respuesta.getBody());
            InventarioRest inventrest = InventarioRest.parse(respuesta.getBody());
            System.debug('inventrest-->'+inventrest);
            System.debug('status code del objeto-->'+inventrest.statusCode);
            //Nos permite ver la Lista 
			System.debug('body-->'+inventrest.Body);
            //Nos permite ver el registro que esta en la lista
            for (InventarioRest.Inventory invent : inventrest.Body.Inventory){
                System.debug('inventario-->'+invent);
                Inventario__c inventario = new Inventario__c();
                inventario.CodigoProd__c = invent.ProductID;
                inventario.Name = invent.name;
                inventario.Cantidad_dis__c = invent.Quan;
                inventario.Cantidad_apart__c = invent.BlockedQuan;
                inventarioRetorno.add(inventario);
            }
        }
        return inventarioRetorno;
    }
}