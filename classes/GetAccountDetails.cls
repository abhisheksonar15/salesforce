public with sharing class GetAccountDetails {
    /*@AuraEnabled(cacheable = true)
    public static List<Contact> getAccounts() {

        List<Contact> conList = [SELECT ID, Name, Phone, Email From Contact];

        return conList;

    }*/

    @AuraEnabled(cacheable = true)
    public static List<Account> getAccountList(){
        List<Account> accList = [Select Id,Name,Industry,Phone From Account WHERE Industry!=NULL AND Phone!=NULL limit 5];
        return accList;
    }
}