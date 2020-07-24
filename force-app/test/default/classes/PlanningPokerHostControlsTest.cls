@isTest
public class PlanningPokerHostControlsTest {
    @TestSetup
    static void createData() {
        PlanningPokerTestUtil.createTestData();
    }

    @isTest
    static void testFlipCardsEvent() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 3'];
        PlanningPokerCtrl.sendflipCardsEvent(game.Id, 'true');
    }

    @isTest
    static void testResetCards() {
        Backlog_Item__c cbi = [SELECT Id FROM Backlog_Item__c LIMIT 1];

        Game__c game = [
            SELECT Id, Timer_Timestamp__c
            FROM Game__c
            WHERE Name = 'Test 4'
        ];
        game.Current_Story_ID__c = cbi.Id;
        game.Show_Timer__c = true;
        game.Timer_Duration__c = 20;
        update game;

        Player__c player = new Player__c();
        player.Name = 'Test Name';
        player.Game__c = game.Id;
        insert player;

        PlanningPokerCtrl.captureVote(cbi.Id, '2', player.Id, game.Id);

        List<PlanningPokerCtrl.PlayerResponse> responses = PlanningPokerCtrl.getPlayerResponses(
            game.Id,
            cbi.Id
        );
        system.assertEquals(1, responses.size());
        system.assertEquals('2', responses[0].response);

        Test.startTest();
        PlanningPokerCtrl.resetCards(game.Id);
        responses = PlanningPokerCtrl.getPlayerResponses(game.Id, cbi.Id);
        system.assertEquals(1, responses.size());
        system.assertEquals(null, responses[0].response);

        Game__c updatedGame = [
            SELECT Id, Timer_Timestamp__c
            FROM Game__c
            WHERE Name = 'Test 4'
        ];

        system.assert(
            updatedGame.Timer_Timestamp__c != game.Timer_Timestamp__c
        );
        Test.stopTest();
    }

    @isTest
    static void testSaveConsensus() {
        Backlog_Item__c cbi = [
            SELECT Id, Consensus__c
            FROM Backlog_Item__c
            LIMIT 1
        ];
        system.assertEquals(null, cbi.Consensus__c);

        Test.startTest();
        Boolean isSuccess = PlanningPokerCtrl.saveConsensus(
            cbi.Id,
            'Backlog_Item__c',
            'Consensus__c',
            '2'
        );
        system.assert(isSuccess);

        cbi = [SELECT Id, Consensus__c FROM Backlog_Item__c LIMIT 1];
        system.assertEquals('2', cbi.Consensus__c);

        isSuccess = PlanningPokerCtrl.saveConsensus(
            cbi.Id,
            'Some_Object__c',
            'Some_Field__c',
            '2'
        );
        system.assert(!isSuccess);

        Test.stopTest();
    }
}
