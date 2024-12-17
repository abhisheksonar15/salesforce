public class AccountTriggerHandler {
    
    //Write a trigger on the Account when the Account is updated check all opportunities related to the account. 
    //Update all Opportunities Stage to close lost if an opportunity created date is greater than 30 days 
    //from today and stage not equal to close won.
    
   public static void updateOppOfAcc(List<Account> accList){
        set<Id> accIds = new set<Id>();
        for(Account acc : accList){
            accIds.add(acc.Id);
        }
        Datetime day30 = system.now()-30;
        List<Opportunity> oppList = [Select Id,AccountId, CloseDate, StageName,CreatedDate From Opportunity Where AccountId IN:accIds];
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        if(!oppList.isEmpty()){
            for(Opportunity opp : oppList){
                if(opp.CreatedDate < day30 && opp.StageName != 'Prospecting'){
                    opp.StageName = 'Closed Won';
                    opp.CloseDate = system.today();
                    oppListToUpdate.add(opp);
                        }
                
            }
        }
        if(!oppListToUpdate.isEmpty()){
            update oppListToUpdate;
        }
    }

    
    
    
    
    
    //Write a trigger on Account, when an account is inserted,
    //automatically account billing address should populate into the account shipping address.
    
    public static void updateAccBillingAddr(List<account> accList){
        for(Account acc : accList){
            if(acc.BillingCity != null)
                acc.ShippingCity = acc.BillingCity;
        }
    }
    
    
    
    
    
    
    public static void updateAccount(List<Account> accList, Map<Id,Account> accOldMap)
    {
        List<Account> listToBeUpdated = new List<Account>();
        for(Account acc : accList){
            Account ac = new Account();
            ac.id = acc.Id;
            ac.description = 'Test Recursion';
            listToBeUpdated.add(ac);
        }
        if(!listToBeUpdated.isEmpty()){
            update listToBeUpdated;
        }
    }
    public static void updateCheckBox(List<Account> accList, Map<Id,Account> accOldMap){
        for(Account acc : accList){
            if(accOldMap.get(acc.Id).Industry != 'Agriculture' && acc.Industry == 'Agriculture'){
                acc.isCheck__c = true;
            }
        }
    }
    
    public static void uniqueAccName(List<Account> accList, Map<Id,Account> accOldMap)
    {
        Set<String> setNames = new Set<String>();
        for(Account acc: accList){
            setNames.add(acc.name);
        }
        if(!setNames.isEmpty()){
            List<Account> accNameList = [SELECT Id, Name FROM Account Where Name IN: setNames];
            Map<String,Account> accNameMap = new Map<String,Account>();
            for(Account acc : accNameList){
                accNameMap.put(acc.Name,acc);
            }
            for(Account acc : accList){
                if(accNameMap.containsKey(acc.Name)){
                    acc.Name.addError('Account Name already exists!!');
                }
                else if(accOldMap.get(acc.Id).Name == acc.Name){
                    acc.Name.addError('Cannot update account name');
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    /*  

Set<String> setName = new Set<String>();
Map<String ,Account> mapNameWiseAccount = new Map<String,Account>();
For(Account acc : accList) 
{ 
setName.add(acc.name);
}
if(!setName.isEmpty())
{            
List<Account> lstAccount = [select name, id from account where name in :setName ];

For(Account acc: lstAccount)  
{ 
mapNameWiseAccount.put(acc.name ,acc); 
}
For(Account acc : accList) 
{
if(mapNameWiseAccount.containsKey(acc.name))   
{   
acc.Name.addError('Name already Exist ');  
}
}
}   
}*/
    
    /*{
for(Account acc : accList){
if(acc.Name == accOldMap.get(acc.Id).Name){
acc.addError('Account Name already exists, please choose another name');
}
}
}*/
    
    public static void preventDeleteion(List<Account> accList){
        Profile p = [SELECT ID,Name from Profile WHERE Name = 'System Administrator'];
        for(Account acc : accList){
            if(UserInfo.getProfileId() != p.id || acc.Active__c == 'Yes'){
                acc.addError('Active account cannot be deleted');
            }
        }
        
    }
    
    public static void updatePhoneOnRelatedContact(List<Account> accList, Map<Id,Account> accOldMap){
        
        List<Contact> conList = new List<Contact>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Set<Id> setIds = new Set<Id>();
        for(Account acc : accList){
            if(acc.Phone != accOldMap.get(acc.Id).Phone)
            {
                //accMap.put(acc.Id, acc);
                setIds.add(acc.Id);
            }
        }
        List<Contact> conList1 = new List<Contact>();
        conList1 = [Select Id, HomePhone, AccountId From Contact Where AccountId IN: accMap.keySet()];
        system.debug('ConList1*****' + conList1);
        system.debug('****ACCMAP*****' + accMap);
        List<Account> accList1 = [SELECT Id,Phone, (Select AccountId,HomePhone From Contacts) From Account Where Id IN:setIds];
        System.debug('***ACCLIST***'+accList1);
        for(Account acc : accList1)
        {
            if(acc.Contacts != null){
                for(Contact con : acc.Contacts){
                    con.HomePhone = acc.Phone;
                    conList.add(con);
                }
            }
            /*if(accMap.containsKey(con.AccountID))
{
con.HomePhone = accMap.get(con.AccountId).Phone;
conList.add(con);
}*/
        }
        system.debug('ConList*****' + conList);
        if(!conList.isEmpty()){
            update conList;
        }
    }
    
    /* //After Update
//If account phone is updated then populate the phone number on all related contacts
//Using Map and Parent-Child SOQL
public static void updatePhoneOnRelatedContact(List<Account> accList, Map<Id,Account> accOldMap){

//Created List to store the contacts and insert/update the list with new phone number
List<Contact> conList = new List<Contact>();

//Created Map of account to store the account whose phone number is updated
Map<Id,Account> accMap = new Map<Id,Account>();

for(Account acc : accList){
//This condition will check new phone number and old phone number and if it is not equal 
//then accMap will store only those account whose phone is updated
//Comparing if the Account new Phone number != Account old phone after updating.
if(acc.Phone != accOldMap.get(acc.Id).Phone)
{
//If it is not equal then it will enter this if condition and we will store the Id and Account details
// in AccMap to use this in Contact query
accMap.put(acc.Id, acc);
}
}
//Where running a for loop with query which will fetch the field records where 
//account id is matching in the AccMap where we stored the account details whose phone number is updated
//KeySet() will gives the keys(ids) of the map records
//for example:
//Id		FName   LName Number
//678912,(Abhishek,Sonar,78934)
//we need the id of the account to fetch only those account record where phone number is updated
for(Contact con : [Select Id, HomePhone, AccountId From Contact Where AccountId IN: accMap.keySet()])
{
//This if conditionis checking whether the accMap is containing the Key(ID) of the 
//account record which retirieved in the above contacts SOQL query
if(accMap.containsKey(con.AccountID))
{
//If the Key is present the HomePhone will be updated by Account Phone field
con.HomePhone = accMap.get(con.AccountId).Phone;
//we will add the updated record in the ConList after which we will update/insert it through DML
conList.add(con);
}
}
//Null check to see whether conList is empty or not if it is not then we will perform the DML
if(!conList.isEmpty()){
update conList;
}
}*/
    
    
    public static void updatePhone(List<Account> accList,Map<Id,Account> accOldMap){
        for(Account acc : accList){
            if(acc.Phone != accOldMap.get(acc.Id).Phone){
                if(accOldMap.get(acc.Id).Phone == null){
                    acc.Description = 'Phone is Updated | Old Phone: Old Phone number not available' + ' New Phone: ' + acc.Phone;
                }
                else{
                    acc.Description = 'Phone is Updated | Old Phone: ' + accOldMap.get(acc.Id).Phone + ' New Phone: ' + acc.Phone;
                }
            }
        }     
    }
    
    public static void accountUpdate(List<Account> accList){
        if(!accList.isEmpty()){
            for(Account acc : accList){
                acc.Description = 'New Account is created by Handler method';
                
            }
        }
    }
    
    public static void ratingUpdate(List<Account> accList, Map<Id,Account> accOldMap)
    {
        for(Account acc: accList){
            if((accOldMap == null && acc.Industry != null && acc.Industry == 'Media') ||
               (acc.Industry != accOldMap.get(acc.Id).Industry && acc.Industry == 'Media'))
            {
                acc.Rating = 'Cold';
            } 
        }
    }
    
    public static void createOpp(List<Account> accList){
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(Account acc: accList)
        {
            Opportunity opp = new Opportunity();
            opp.Name = acc.Name;
            opp.CloseDate = System.today();
            opp.StageName = 'Prospecting';
            opp.AccountId = acc.Id;
            oppList.add(opp);
        }
        if(!oppList.isEmpty()){
            insert oppList;
        }
    }
}