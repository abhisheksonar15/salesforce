//Query Contacts created last week and
// if phone is not populated on contact then copy Phone of Related Account

public class phoneToRelatedContact {
    public static void copyAccountPhoneToContact(){
        List<Contact> conList = [Select Id,Name, Phone,Account.Name,Account.Phone
                                 From Contact 
                                 Where AccountId != null];
        
        if(!conList.isEmpty()){
            for(Contact con : conList){
                if(con.Phone == null){
                    con.Phone = con.Account.Phone;
                }
            }
        }
        if(!conList.isEmpty()){
            update conList;
        }
    }
}