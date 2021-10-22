import { LightningElement, api } from 'lwc';
//nos permitira ver el mensaje de error
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//se importa el controlador "ControladorBuscarProducto" con su metodo"getProductos"
import getProductos from '@salesforce/apex/ControladorBuscarProducto.getProductos';
//se importa el controlador "ControladorBuscarProducto" con su metodo"CreateQuoteLineItem"
import CreateQuoteLineItem from '@salesforce/apex/ControladorBuscarProducto.CreateQuoteLineItem';

const Columnas = [
    { label: 'Nombre del producto', fieldName: 'ProductName' },
    { label: 'Precio de la lista', fieldName: 'ListPrice', type: 'currency' },
    { label: 'Cantidad apartada', fieldName: 'Quantity', editable: true, type: 'number'},
    { label: 'Cantidad disponible', fieldName: 'Available'},
];

export default class BotonCrearPresupuesto extends LightningElement {
    //Nos permite obtener el Id de donde nos encontramos
    @api recordId;
    columns = Columnas;
    data = [];
    //se inicializa la variable de texto en unull
    texto ='';
    // despliega formuladrio despues de click sobre boton, actua sobre el archivo HTML
    showProducts = false;
    // despliega Tabla despues de click sobre boton Buscar, actua sobre el archivo HTML
    showTable = false;

    handleClick(event){
        this.showProducts = true;
    }
    closeModal(){
        this.showProducts = false;
    }
    //se captura el texto del usuario en tiempo real
    hadleText(event){
        //console.log('etse es el texto -->'+event.target.value);
        this.texto = event.target.value;
        console.log('este es el texto THIS -->'+this.texto);
    }
    //trae los valores de la lista producto y los guarda en el arreglo "data"
    handleSearch(event){
        getProductos({searchKey:this.texto})
        .then(result => {
        console.log('esto es el resultado-->' +JSON.stringify(result));
        this.data = result;
        this.showTable = true;
        })
        .catch(error =>{
            console.log('esto es el error-->'+JSON.stringify(error));
            this.showToast('Error en búsqueda',error.body.message,'error');
        });
    }

    handleCellChange(event){
        var tempData = JSON.parse(JSON.stringify(this.data));
        tempData[0].Quantity = event.detail.draftValues[0].Quantity;
        this.data = JSON.parse(JSON.stringify(tempData));
        console.log('Aqui esta el conjunto cambiado --> '+JSON.stringify(tempData));
    }

    handleAtras(event){
        this.date = [];
        this.texto = '';
        this.showTable = false;
    }

    handleGuardar(event){
        var tempData = JSON.parse(JSON.stringify(this.data));
        tempData[0].quoteId= this.recordId;
        console.log('data ->'+JSON.stringify(tempData));
        console.log('Cantidad Disponible ->'+tempData[0].Available);
        console.log('Cantidad apartada ->'+tempData[0].Quantity);
        if(tempData[0].Available>=tempData[0].Quantity && 0<tempData[0].Quantity){
            CreateQuoteLineItem({Productos :tempData})
            .then(result => {
                console.log('esto es el guardado-->' +JSON.stringify(result));
                this.texto='';
                this.data = [];
                this.showTable = false;
            })
            .catch(error =>{
                console.log('esto es el error-->'+JSON.stringify(error));
            });
        }else{
            this.showToast('Error al ingresa la cantidad','La cantidad no puede superar la candidad disponible o ser menor a 1, por favor verificar','error');
        }
        
    }
    //Este metodo nos sirve para ver el error
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}