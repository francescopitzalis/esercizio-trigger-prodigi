public with sharing class TotalAndSharesController {

    private static final Integer ACCOUNTS_PER_PAGE = 5;

    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [
                        SELECT Id, Name, Total__c,
                        (SELECT Id, Name, Share__c FROM Contacts ORDER BY Name)
                        FROM Account
                        ORDER BY Name ASC
                    ]
                ));
                setCon.setPageSize(ACCOUNTS_PER_PAGE);
                setCon.setPageNumber(pageNumber);
            }
            return setCon;
        }
        set;
    }

    public List<Account> getAccounts() {
        return (List<Account>) setCon.getRecords();
    }

    public Integer pageNumber {
        get {
            if (pageNumber == null) {
                pageNumber = 1;
            }
            return pageNumber;
        }
        set;
    }

    public Integer getTotalPages() {
        return (setCon.getResultSize() / ACCOUNTS_PER_PAGE) + 1;
    }

    public Boolean previousDisabled { get { return !setCon.getHasPrevious(); }}

    public PageReference previous() {
        setCon.previous();
        pageNumber = setCon.getPageNumber();
        return null;
    }

    public Boolean nextDisabled { get { return !setCon.getHasNext(); }}

    public PageReference next() {
        setCon.next();
        pageNumber = setCon.getPageNumber();
        return null;
    }

    public PageReference save() {
        update setCon.getRecords();
        setCon = null;
        return null;
    }

}
