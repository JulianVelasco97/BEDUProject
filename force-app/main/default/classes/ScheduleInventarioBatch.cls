global class ScheduleInventarioBatch implements Schedulable{
    global void execute(SchedulableContext sc){
        InventarioBatch batch = new InventarioBatch();
        Id batchId = Database.executeBatch(batch);
    }
}