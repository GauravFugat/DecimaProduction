global class BrokerExceptionDataSchedule implements Schedulable
{  
    global void execute(SchedulableContext sc) 
    {
        BrokerExceptionData broker = new BrokerExceptionData(); // Your batch class
        if(!test.isRunningTest()){
            database.executeBatch(broker, 1);}
        else{
             database.executeBatch(broker, 200);
        }
    }
    
}