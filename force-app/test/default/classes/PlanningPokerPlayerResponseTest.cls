@isTest
public class PlanningPokerPlayerResponseTest {
    @TestSetup
    static void createData() {
        PlanningPokerTestUtil.createTestData();
    }

    @isTest
    static void checkVoteCapture() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 2'];
        Player__c player = [
            SELECT Id
            FROM Player__c
            WHERE Game__c = :game.Id
            LIMIT 1
        ];
        Content_Backlog_Item__c cbi = [
            SELECT Id
            FROM Content_Backlog_Item__c
            LIMIT 1
        ];

        List<Player_Response__c> responses = [
            SELECT Id
            FROM Player_Response__c
            WHERE
                Game__c = :game.Id
                AND Player__c = :player.Id
                AND Story_ID__c = :cbi.Id
        ];
        system.assertEquals(0, responses.size());

        Test.startTest();
        PlanningPokerCtrl.captureVote(cbi.Id, '0', player.Id, game.Id);

        responses = [
            SELECT Id, Response__c
            FROM Player_Response__c
            WHERE
                Game__c = :game.Id
                AND Player__c = :player.Id
                AND Story_ID__c = :cbi.Id
        ];
        system.assertEquals(1, responses.size());
        system.assertEquals('0', responses[0].Response__c);

        //Duplicate Vote
        PlanningPokerCtrl.captureVote(cbi.Id, '2', player.Id, game.Id);

        responses = [
            SELECT Id, Response__c
            FROM Player_Response__c
            WHERE
                Game__c = :game.Id
                AND Player__c = :player.Id
                AND Story_ID__c = :cbi.Id
        ];
        system.assertEquals(1, responses.size());
        system.assertEquals('2', responses[0].Response__c);

        Test.stopTest();
    }

    @isTest
    static void getExistingVotes() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 4'];

        Player__c player = new Player__c();
        player.Name = 'Test Name';
        player.Game__c = game.Id;
        insert player;

        Content_Backlog_Item__c cbi = [
            SELECT Id
            FROM Content_Backlog_Item__c
            LIMIT 1
        ];
        PlanningPokerCtrl.captureVote(cbi.Id, '2', player.Id, game.Id);

        Test.startTest();
        List<PlanningPokerCtrl.PlayerResponse> responses = PlanningPokerCtrl.getPlayerResponses(
            game.Id,
            cbi.Id
        );
        system.assertEquals(1, responses.size());
        system.assertEquals(player.Id, responses[0].player.Id);
        system.assertEquals('2', responses[0].response);
        system.assertEquals('2', responses[0].pokerCard.name);
        Test.stopTest();
    }
}
