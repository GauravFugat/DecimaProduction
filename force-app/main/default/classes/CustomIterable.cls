/*
* @Purpose: Display report for Broker commissions(pagination)
* @Author: Rahul Ghaytadak
* @CreatedDate:03/04/2021
* @Related Code: 
* @Test Class: VF_Report_BrokerCommissionsHandler_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
global class  CustomIterable implements Iterator<list<wrapperClass>>
{ 
   list<wrapperClass> InnerList{get; set;}
   list<wrapperClass> ListRequested{get; set;}

   Integer i {get; set;} 
   public Integer setPageSize {get; set;} 

   public CustomIterable(List<wrapperClass> lstAccWr)
   {
       InnerList = new list<wrapperClass >(); 
       ListRequested = new list<wrapperClass >();     
       InnerList = lstAccWr;
       setPageSize = 10;
       i = 0; 
   }   

   global boolean hasNext(){ 
       if(i >= InnerList.size()) {
           return false; 
       } else {
           return true; 
       }
   } 
   
   global boolean hasPrevious(){ 
       system.debug('I am in hasPrevious' + i);
       if(i <= setPageSize) {
           return false; 
       } else {
           return true; 
       }
   }   

   public list<wrapperClass> next(){       
       system.debug('i value is ' + i);
       ListRequested = new list<wrapperClass>(); 
       integer startNumber;
       integer size = InnerList.size();
       if(hasNext())
       {  
           if(size <= (i + setPageSize))
           {
               startNumber = i;
               i = size;
           }
           else
           {
               i = (i + setPageSize);
               startNumber = (i - setPageSize);
           }
           
           system.debug('i value is =====' + i);
           system.debug('i value is 2==== ' + (i - setPageSize));
           
           for(integer start = startNumber; start < i; start++)
           {
               ListRequested.add(InnerList[start]);
           }
       } 
       system.debug('ListRequested size>>'+ListRequested.size());
       return ListRequested;
   } 
   
   public list<wrapperClass> previous(){      
       ListRequested = new list<wrapperClass >(); 
       system.debug('i value is previous before =====' + i);
       integer size = InnerList.size(); 
       if(i == size)
       {
           if(math.mod(size, setPageSize) > 0)
           {    
               i = size - math.mod(size, setPageSize);
           }
           else
           {
               i = (size - setPageSize);
           } 
       }
       else
       {
           i = (i - setPageSize);
       }
       
       system.debug('i value is previous =====' + i);
       system.debug('i value is 2previous ==== ' + (i - setPageSize));
       
       for(integer start = (i - setPageSize); start < i; ++start)
       {
           try{
                ListRequested.add(InnerList[start]);
           }
           catch(Exception ex){
               
           }
          
       } 
       return ListRequested;
   }   
}