public class PlanningPokerTestUtil {
    public static void createTestData() {
        List<Game__c> games = new List<Game__c>();

        Card_Set__mdt cs = [
            SELECT Id
            FROM Card_Set__mdt
            WHERE Label = 'Fibonacci'
        ];

        Game__c g = new Game__c();
        g.Phase__c = 'In Progress';
        g.Name = 'Test 1';
        g.Config__c = null;
        games.add(g);

        g = new Game__c();
        g.Phase__c = 'In Progress';
        g.Name = 'Test 2';
        g.Show_Timer__c = true;
        g.Timer_Duration__c = 20;
        g.Config__c =
            '{"cardSet":"' +
            cs.Id +
            '","object":"Content_Backlog_Item__c","name":"User_Story__c","description":"Notes__c","consensus":"Consensus__c","listView":"00B0p000001XhUQEA0"}';
        games.add(g);

        g = new Game__c();
        g.Phase__c = 'Completed';
        g.Name = 'Test 3';
        g.Config__c = '{"listViewId":"00B0p000001XhUQEA0"}';
        games.add(g);

        g = new Game__c();
        g.Name = 'Test 4';
        g.Config__c = null;
        games.add(g);

        insert games;

        List<Content_Backlog_Item__c> backlogItems = new List<Content_Backlog_Item__c>();

        Content_Backlog_Item__c bi = new Content_Backlog_Item__c();
        bi.User_Story__c = 'b1';
        bi.Notes__c = 'n1';
        backlogItems.add(bi);

        bi = new Content_Backlog_Item__c();
        bi.User_Story__c = 'b2';
        bi.Notes__c = 'n2';
        backlogItems.add(bi);

        insert backlogItems;
    }
}