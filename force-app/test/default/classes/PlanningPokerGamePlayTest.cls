@isTest
public class PlanningPokerGamePlayTest {
    @TestSetup
    static void createData() {
        PlanningPokerTestUtil.createTestData();
    }

    @IsTest
    static void checkGameQueries() {
        Game__c existingGame = [SELECT Id, Game_Key__c FROM Game__c LIMIT 1];

        Test.startTest();
        List<Game__c> games = PlanningPokerCtrl.getValidGames();
        System.assertEquals(2, games.size());

        Game__c game = PlanningPokerCtrl.getGameByGameKey('000000');
        system.assertEquals(null, game);

        game = PlanningPokerCtrl.getGameByGameKey(existingGame.Game_Key__c);
        system.assertEquals(existingGame.Id, game.Id);

        Test.stopTest();
    }

    @isTest
    static void checkIfGameStoryIsUpdated() {
        Game__c g = [
            SELECT
                Id,
                Current_Story_ID__c,
                Timer_Timestamp__c,
                Question_Offset__c
            FROM Game__c
            WHERE Name = 'Test 2'
        ];

        final String STORY_ID = '000000';
        final Integer OFFSET = 2;

        Test.startTest();
        PlanningPokerCtrl.updateGameCurrentStory(g.Id, STORY_ID, 2);
        Game__c updatedGame = [
            SELECT
                Id,
                Current_Story_ID__c,
                Timer_Timestamp__c,
                Question_Offset__c
            FROM Game__c
            WHERE Name = 'Test 2'
        ];

        system.assertEquals(STORY_ID, updatedGame.Current_Story_ID__c);
        system.assertEquals(OFFSET, updatedGame.Question_Offset__c);
        system.assertNotEquals(
            g.Timer_Timestamp__c,
            updatedGame.Timer_Timestamp__c
        );

        Test.stopTest();
    }

    @isTest
    static void checkIfGamePhaseIsUpdated() {
        Game__c g = [SELECT Id, Phase__c FROM Game__c WHERE Name = 'Test 4'];

        Test.startTest();
        system.assertEquals('Not Started', g.Phase__c);
        PlanningPokerCtrl.changeGamePhase(g.Id, 'Not Started');

        g = [SELECT Id, Phase__c FROM Game__c WHERE Name = 'Test 4'];
        system.assertEquals('Registration', g.Phase__c);
        PlanningPokerCtrl.changeGamePhase(g.Id, 'Registration');

        g = [SELECT Id, Phase__c FROM Game__c WHERE Name = 'Test 4'];
        system.assertEquals('In Progress', g.Phase__c);
        PlanningPokerCtrl.changeGamePhase(g.Id, 'In Progress');

        g = [SELECT Id, Phase__c FROM Game__c WHERE Name = 'Test 4'];
        system.assertEquals('Completed', g.Phase__c);

        Test.stopTest();
    }

    @isTest
    static void testIfCurrentStoryIsRetrieved() {
        Game__c g1 = [SELECT Id FROM Game__c WHERE Name = 'Test 1'];
        Game__c g2 = [SELECT Id FROM Game__c WHERE Name = 'Test 2'];

        Test.startTest();
        PlanningPokerCtrl.BacklogItem b = PlanningPokerCtrl.getCurrentStory(
            g1.Id
        );
        system.assertEquals(null, b);

        b = PlanningPokerCtrl.getCurrentStory(g2.Id);
        system.assertEquals(null, b);

        Content_Backlog_Item__c cbi = [
            SELECT Id, User_Story__c, Notes__c
            FROM Content_Backlog_Item__c
            LIMIT 1
        ];

        g2.Current_Story_Id__c = cbi.Id;
        update g2;

        b = PlanningPokerCtrl.getCurrentStory(g2.Id);
        system.assertEquals(cbi.User_Story__c, b.itemName);
        system.assertEquals(cbi.Notes__c, b.itemDescription);
        system.assertEquals(g2.Current_Story_Id__c, b.itemId);

        Test.stopTest();
    }

    @isTest
    static void testIfTimeStampIsReturned() {
        Long currentTimeStamp = Datetime.now().getTime();
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 2'];
        game.Timer_Timestamp__c = String.valueOf(currentTimeStamp);
        update game;

        Test.startTest();
        String timeStamp = PlanningPokerCtrl.getQuestionTimeStamp(game.Id);
        system.assertEquals(String.valueOf(currentTimeStamp), timeStamp);
        Test.stopTest();
    }
}
