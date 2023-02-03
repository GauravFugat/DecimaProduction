global class BrokerReportSenderScheduler implements Schedulable {
    global string reportName = '';
    global String batchRunType = '';
    global Decimal numberOfDays = 0;
    global void execute(SchedulableContext sc) {
        BrokerReportSenderBatch b = new BrokerReportSenderBatch(); 
        b.reportName = reportName;
        b.batchRunType = batchRunType;
        b.numberOfDays = numberOfDays;
        database.executebatch(b, 1);
    }
    
}