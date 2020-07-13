@isTest
public class PlanningPokerTest {

    @TestSetup
    static void makeData(){
        List<Game__c> games = new List<Game__c>();
        
        Game__c g = new Game__c();
        g.Phase__c = 'In Progress';
        g.Name = 'Test 1';
        g.Config__c = null;
        games.add(g);

        g = new Game__c();
        g.Phase__c = 'In Progress';
        g.Name = 'Test 1';
        g.Config__c = '{"listViewId":"0000000000"}';
        games.add(g);

        g = new Game__c();
        g.Phase__c = 'Completed';
        g.Name = 'Test 1';
        g.Config__c = '{"listViewId":"0000000000"}';
        games.add(g);

        insert games;

        List<Content_Backlog_Item__c> backlogItems = new List<Content_Backlog_Item__c>();

        Content_Backlog_Item__c bi = new Content_Backlog_Item__c();
        bi.Topic__c = 'b1';
        bi.Notes__c = 'n1';
        backlogItems.add(bi);

        bi = new Content_Backlog_Item__c();
        bi.Topic__c = 'b2';
        bi.Notes__c = 'n2';
        backlogItems.add(bi);

        insert backlogItems;

    }

    @IsTest
    static void checkGameSettings(){
        Test.startTest();

        List<Card_Set__mdt> cardSets = PlanningPokerCtrl.getAvailableCardSets();
        System.assertEquals(2, cardSets.size());

        List<String> customObjects = PlanningPokerCtrl.getCustomObjects();
        System.assert(customObjects.contains('Game__c'));

        List<ListView> views = PlanningPokerCtrl.getListViewsOfObject('Game__c');
        System.assert(views.size() > 0);

        Test.stopTest();
    }

    @IsTest
    static void checkGames(){
        Game__c existingGame = [select Id, Game_Key__c from Game__c limit 1];

        Test.startTest();
        List<Game__c> games = PlanningPokerCtrl.getValidGames();
        System.assertEquals(1, games.size());

        Game__c game = PlanningPokerCtrl.getGameByGameKey('000000');
        system.assertEquals(null, game);

        game = PlanningPokerCtrl.getGameByGameKey(existingGame.Game_Key__c);
        system.assertEquals(existingGame.Id, game.Id);

        Test.stopTest();
        
    }
}
