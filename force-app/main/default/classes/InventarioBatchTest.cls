@isTest 
public class InventarioBatchTest {
    @isTest static void startBatch() {
        Test.startTest();
        InventarioBatch batch = new InventarioBatch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
    }
	
}