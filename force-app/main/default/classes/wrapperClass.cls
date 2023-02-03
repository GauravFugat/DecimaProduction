/*
* @Purpose: Display report for Broker commissions(Wrapper)
* @Author: Rahul Ghaytadak
* @CreatedDate:03/04/2021
* @Related Code: 
* @Test Class: VF_Report_BrokerCommissionsHandler_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class wrapperClass{
        public String BrokerName {get;set;} 
        public string  CustomerName {get;set;} 
        public String OppId {get;set;} 
        public String OwnerName {get;set;} 
        public string CommisionType {get;set;} 
        public Decimal  BrokerMargin {get;set;} 
        public string  UtilityAccountNumber {get;set;} 
        public String Utility {get;set;} 
        public Integer AnnualUsage {get;set;}
        public Date StartDate {get;set;} 
        public wrapperClass(String BrokerName,string  CustomerName,String OppId,String OwnerName,string CommisionType,Decimal  BrokerMargin,string  UtilityAccountNumber,String Utility,Integer AnnualUsage,Date StartDate){
            this.BrokerName = BrokerName;
            this.CustomerName = CustomerName;
            this.OppId = OppId;
            this.OwnerName = OwnerName;
            this.CommisionType = CommisionType;
            this.BrokerMargin = BrokerMargin;
            this.UtilityAccountNumber = UtilityAccountNumber;
            this.Utility = Utility;
            this.AnnualUsage = AnnualUsage;
            this.StartDate = StartDate;
        }
        
    }