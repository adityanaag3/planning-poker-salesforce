@isTest
public class PlanningPokerGamePlayerTest {
    @TestSetup
    static void createData() {
        PlanningPokerTestUtil.createTestData();
    }

    @IsTest
    static void checkIfPlayersAreReturnedCorrectly() {
        Game__c g1 = [
            SELECT Id, Game_Key__c
            FROM Game__c
            WHERE Name = 'Test 1'
        ];
        Game__c g2 = [
            SELECT Id, Game_Key__c
            FROM Game__c
            WHERE Name = 'Test 2'
        ];

        Test.startTest();
        List<Player__c> players = PlanningPokerCtrl.getGamePlayers(g1.Id);
        System.assertEquals(2, players.size());

        players = PlanningPokerCtrl.getGamePlayers(g2.Id);
        System.assertEquals(3, players.size());

        Test.stopTest();
    }

    @isTest
    static void checkIfAllPlayersAreDeleted() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 2'];

        Test.startTest();

        PlanningPokerCtrl.deleteAllPlayers(game.Id, false);
        List<Player__c> players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(0, players.size());

        Test.stopTest();
    }

    @isTest
    static void checkIfAllPlayersExceptMeAreDeleted() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 2'];

        Test.startTest();

        PlanningPokerCtrl.deleteAllPlayers(game.Id, true);
        List<Player__c> players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals(UserInfo.getName(), players[0].Name);

        Test.stopTest();
    }

    @isTest
    static void testExternalPlayerInsert() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 3'];

        Test.startTest();
        List<Player__c> players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(0, players.size());

        Id playerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            'JohnDoe',
            false,
            false
        );
        System.assert(playerId != null);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals('JohnDoe', players[0].Name);

        // Try to insert same player again
        Id duplicatePlayerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            'JohnDoe',
            false,
            false
        );
        System.assert(duplicatePlayerId != null);
        System.assert(duplicatePlayerId == playerId);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals('JohnDoe', players[0].Name);

        // Try passing null instead of boolean
        duplicatePlayerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            'JohnDoe',
            null,
            null
        );
        System.assert(duplicatePlayerId != null);
        System.assert(duplicatePlayerId == playerId);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals('JohnDoe', players[0].Name);

        Test.stopTest();
    }

    @IsTest
    static void testSalesforcePlayerInsert() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 3'];

        Test.startTest();
        List<Player__c> players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(0, players.size());

        Id playerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            'JohnDoe',
            false,
            true
        );
        System.assert(playerId != null);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals(UserInfo.getName(), players[0].Name);

        // Try to insert same player again
        Id duplicatePlayerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            'JohnDoe',
            false,
            true
        );
        System.assert(duplicatePlayerId != null);
        System.assert(duplicatePlayerId == playerId);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals(UserInfo.getName(), players[0].Name);

        //Try to insert without passing the name
        Id triplicatePlayerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            null,
            false,
            true
        );
        System.assert(triplicatePlayerId != null);
        System.assert(triplicatePlayerId == playerId);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals(UserInfo.getName(), players[0].Name);

        //Try to insert without passing the boolean
        triplicatePlayerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            null,
            null,
            true
        );
        System.assert(triplicatePlayerId != null);
        System.assert(triplicatePlayerId == playerId);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals(UserInfo.getName(), players[0].Name);

        Test.stopTest();
    }

    @isTest
    static void testHostInsertWhenVotingEnabled() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 4'];

        Test.startTest();
        List<Player__c> players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(0, players.size());

        Id playerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            'JohnDoe',
            true,
            false
        );
        System.assert(playerId != null);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals(UserInfo.getName(), players[0].Name);

        // Try to insert same player again
        Id duplicatePlayerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            'JohnDoe',
            true,
            false
        );
        System.assert(duplicatePlayerId != null);
        System.assert(duplicatePlayerId == playerId);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals(UserInfo.getName(), players[0].Name);

        //Try to insert without passing the name
        Id triplicatePlayerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            null,
            true,
            false
        );
        System.assert(triplicatePlayerId != null);
        System.assert(triplicatePlayerId == playerId);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals(UserInfo.getName(), players[0].Name);

        //Try passing null instead of boolean
        triplicatePlayerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            null,
            true,
            null
        );
        System.assert(triplicatePlayerId != null);
        System.assert(triplicatePlayerId == playerId);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(1, players.size());
        System.assertEquals(UserInfo.getName(), players[0].Name);

        Test.stopTest();
    }

    @isTest
    static void testHostInsertWhenVotingDisabled() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 3'];

        Test.startTest();
        List<Player__c> players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(0, players.size());

        Id playerId = PlanningPokerCtrl.insertPlayer(
            game.Id,
            'JohnDoe',
            true,
            false
        );
        System.assert(playerId == null);

        players = PlanningPokerCtrl.getGamePlayers(game.Id);
        System.assertEquals(0, players.size());

        Test.stopTest();
    }
}
