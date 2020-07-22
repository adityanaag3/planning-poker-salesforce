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
        System.assertEquals(1, games.size());

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
}
