public class PlanningPokerTestUtil {
    public static String namespace = PlanningPokerCtrl.getNameSpace(true);

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
            '","object":"Backlog_Item__c","name":"User_Story__c","description":"Notes__c","consensus":"Consensus__c","listView":"00B0p000001XhUQEA0"}';
        games.add(g);

        g = new Game__c();
        g.Phase__c = 'Completed';
        g.Name = 'Test 3';
        g.Config__c = '{"listViewId":"00B0p000001XhUQEA0"}';
        games.add(g);

        g = new Game__c();
        g.Name = 'Test 4';
        g.Host_can_vote__c = true;
        g.Config__c =
            '{"cardSet":"' +
            cs.Id +
            '","object":"Backlog_Item__c","name":"User_Story__c","description":"Notes__c","consensus":"Consensus__c","listView":"00B0p000001XhUQEA0"}';
        games.add(g);

        insert games;

        List<Backlog_Item__c> backlogItems = new List<Backlog_Item__c>();

        Backlog_Item__c bi = new Backlog_Item__c();
        bi.User_Story__c = 'b1';
        bi.Notes__c = 'n1';
        backlogItems.add(bi);

        bi = new Backlog_Item__c();
        bi.User_Story__c = 'b2';
        bi.Notes__c = 'n2';
        backlogItems.add(bi);

        insert backlogItems;

        List<Player__c> players = new List<Player__c>();
        Player__c p = new Player__c();
        p.Name = 'player1';
        p.Game__c = games[1].Id;
        players.add(p);

        p = new Player__c();
        p.Name = 'player2';
        p.Game__c = games[1].Id;
        players.add(p);

        p = new Player__c();
        p.Name = UserInfo.getName();
        p.Game__c = games[1].Id;
        players.add(p);

        p = new Player__c();
        p.Name = 'player3';
        p.Game__c = games[0].Id;
        players.add(p);

        p = new Player__c();
        p.Name = UserInfo.getName();
        p.Game__c = games[0].Id;
        players.add(p);

        insert players;
    }

    public static PlanningPokerRest.PlanningPokerServicesResponse deserializeValues(
        String response
    ) {
        PlanningPokerRest.PlanningPokerServicesResponse ppr = new PlanningPokerRest.PlanningPokerServicesResponse();
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
            response
        );
        ppr.isSuccess = (Boolean) params.get('isSuccess');
        ppr.errorMsg = (String) params.get('errorMsg');
        ppr.data = params.get('data');
        return ppr;
    }
}
