@isTest
public class PlanningPokerRestTest {
    static String INSTANCE_URL = 'https://yourInstance.salesforce.com/services/apexrest/PlanningPokerServices/';

    @TestSetup
    static void createData() {
        PlanningPokerTestUtil.createTestData();
    }

    @isTest
    static void testValidateGameKey() {
        Game__c existingGame = [SELECT Id, Game_Key__c FROM Game__c LIMIT 1];

        Test.startTest();

        RestRequest request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'ValidateGameKey';
        request.httpMethod = 'GET';
        request.params.put('gameKey', existingGame.Game_Key__c);
        RestContext.request = request;

        String response = PlanningPokerRest.doGet();

        PlanningPokerRest.PlanningPokerServicesResponse ppr = PlanningPokerTestUtil.deserializeValues(
            response
        );
        system.assert(ppr.isSuccess);

        Map<String, Object> gameData = (Map<String, Object>) ppr.data;
        system.assert(gameData != null);
        system.assert(gameData.get('Id') == existingGame.Id);

        //Null param
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'ValidateGameKey';
        request.httpMethod = 'GET';
        request.params.put('gameKey', null);
        RestContext.request = request;

        response = PlanningPokerRest.doGet();
        ppr = PlanningPokerTestUtil.deserializeValues(response);
        system.assert(!ppr.isSuccess);
        system.assertEquals('Required parameters missing', ppr.errorMsg);

        //Missing Params
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'ValidateGameKey';
        request.httpMethod = 'GET';
        RestContext.request = request;

        response = PlanningPokerRest.doGet();
        ppr = PlanningPokerTestUtil.deserializeValues(response);
        system.assert(!ppr.isSuccess);
        system.assertEquals('Required parameters missing', ppr.errorMsg);

        Test.stopTest();
    }

    @isTest
    static void testVerifyIfPlayerExists() {
        Game__c existingGame = [SELECT Id, Game_Key__c FROM Game__c LIMIT 1];

        Test.startTest();

        RestRequest request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'VerifyPlayer';
        request.httpMethod = 'GET';
        request.params.put('gameId', existingGame.Id);
        request.params.put('playerName', 'Test0');
        RestContext.request = request;

        String response = PlanningPokerRest.doGet();

        PlanningPokerRest.PlanningPokerServicesResponse ppr = PlanningPokerTestUtil.deserializeValues(
            response
        );
        system.assert(ppr.isSuccess);

        String playerId = (String) ppr.data;
        system.assert(playerId == null);

        //Add a player
        Player__c p = new Player__c();
        p.Name = 'Test0';
        p.Game__c = existingGame.Id;
        insert p;

        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'VerifyPlayer';
        request.httpMethod = 'GET';
        request.params.put('gameId', existingGame.Id);
        request.params.put('playerName', 'Test0');
        RestContext.request = request;

        response = PlanningPokerRest.doGet();

        ppr = PlanningPokerTestUtil.deserializeValues(response);
        system.assert(ppr.isSuccess);

        playerId = (String) ppr.data;
        system.assert(playerId == p.Id);

        // Missing Params
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'VerifyPlayer';
        request.httpMethod = 'GET';
        RestContext.request = request;

        response = PlanningPokerRest.doGet();
        ppr = PlanningPokerTestUtil.deserializeValues(response);
        system.assert(!ppr.isSuccess);
        system.assertEquals('Required parameters missing', ppr.errorMsg);

        //Null  Params
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'VerifyPlayer';
        request.httpMethod = 'GET';
        request.params.put('gameId', null);
        RestContext.request = request;

        response = PlanningPokerRest.doGet();
        ppr = PlanningPokerTestUtil.deserializeValues(response);
        system.assert(!ppr.isSuccess);
        system.assertEquals('Required parameters missing', ppr.errorMsg);

        Test.stopTest();
    }

    @isTest
    static void testGetAllPlayerResponses() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 2'];
        Player__c player = [
            SELECT Id
            FROM Player__c
            WHERE Game__c = :game.Id
            LIMIT 1
        ];
        Backlog_Item__c cbi = [SELECT Id FROM Backlog_Item__c LIMIT 1];
        PlanningPokerCtrl.captureVote(cbi.Id, '0', player.Id, game.Id);

        Test.startTest();

        RestRequest request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'GetAllPlayerResponses';
        request.httpMethod = 'GET';
        request.params.put('gameId', game.Id);
        request.params.put('storyId', cbi.Id);
        RestContext.request = request;

        String response = PlanningPokerRest.doGet();

        PlanningPokerRest.PlanningPokerServicesResponse ppr = PlanningPokerTestUtil.deserializeValues(
            response
        );
        system.assert(ppr.isSuccess);

        List<Object> playerResponseData = (List<Object>) ppr.data;
        system.assertEquals(3, playerResponseData.size());
        Map<String, Object> responseData = (Map<String, Object>) playerResponseData[0];
        system.assertEquals('0', responseData.get('response'));

        // Missing Params
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'GetAllPlayerResponses';
        request.httpMethod = 'GET';
        RestContext.request = request;

        response = PlanningPokerRest.doGet();
        ppr = PlanningPokerTestUtil.deserializeValues(response);
        system.assert(!ppr.isSuccess);
        system.assertEquals('Required parameters missing', ppr.errorMsg);

        //Null  Params
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'GetAllPlayerResponses';
        request.httpMethod = 'GET';
        request.params.put('gameId', null);
        RestContext.request = request;

        response = PlanningPokerRest.doGet();
        ppr = PlanningPokerTestUtil.deserializeValues(response);
        system.assert(!ppr.isSuccess);
        system.assertEquals('Required parameters missing', ppr.errorMsg);

        Test.stopTest();
    }

    @isTest
    static void testGetCurrentUnvotedItem() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 2'];
        Backlog_Item__c cbi = [
            SELECT Id, User_Story__c, Notes__c
            FROM Backlog_Item__c
            LIMIT 1
        ];
        game.Current_Story_ID__c = cbi.Id;
        game.Show_Timer__c = true;
        game.Timer_Duration__c = 20;
        update game;

        Test.startTest();

        RestRequest request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'GetCurrentUnvotedItem';
        request.httpMethod = 'GET';
        request.params.put('gameId', game.Id);
        RestContext.request = request;

        String response = PlanningPokerRest.doGet();

        PlanningPokerRest.PlanningPokerServicesResponse ppr = PlanningPokerTestUtil.deserializeValues(
            response
        );
        system.assert(ppr.isSuccess);

        Map<String, Object> responseData = (Map<String, Object>) ppr.data;
        system.assertEquals(cbi.User_Story__c, responseData.get('itemName'));
        system.assertEquals(cbi.Notes__c, responseData.get('itemDescription'));
        system.assertEquals(cbi.Id, responseData.get('itemId'));

        // Missing Params
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'GetCurrentUnvotedItem';
        request.httpMethod = 'GET';
        RestContext.request = request;

        response = PlanningPokerRest.doGet();
        ppr = PlanningPokerTestUtil.deserializeValues(response);
        system.assert(!ppr.isSuccess);
        system.assertEquals('Required parameters missing', ppr.errorMsg);

        //Null  Params
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'GetCurrentUnvotedItem';
        request.httpMethod = 'GET';
        request.params.put('gameId', null);
        RestContext.request = request;

        response = PlanningPokerRest.doGet();
        ppr = PlanningPokerTestUtil.deserializeValues(response);
        system.assert(!ppr.isSuccess);
        system.assertEquals('Required parameters missing', ppr.errorMsg);

        Test.stopTest();
    }

    @isTest
    static void testTimerTimestamp() {
        Long currentTimeStamp = DateTime.now().getTime();
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 2'];
        game.Timer_Timestamp__c = String.valueOf(currentTimeStamp);
        game.Show_Timer__c = true;
        game.Timer_Duration__c = 20;
        update game;

        Test.startTest();

        RestRequest request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'GetTimerTimestamp';
        request.httpMethod = 'GET';
        request.params.put('gameId', game.Id);
        RestContext.request = request;

        String response = PlanningPokerRest.doGet();

        PlanningPokerRest.PlanningPokerServicesResponse ppr = PlanningPokerTestUtil.deserializeValues(
            response
        );
        system.assert(ppr.isSuccess);

        String responseData = (String) ppr.data;
        system.assertEquals(String.valueOf(currentTimeStamp), responseData);

        // Missing Params
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'GetTimerTimestamp';
        request.httpMethod = 'GET';
        RestContext.request = request;

        response = PlanningPokerRest.doGet();
        ppr = PlanningPokerTestUtil.deserializeValues(response);
        system.assert(!ppr.isSuccess);
        system.assertEquals('Required parameters missing', ppr.errorMsg);

        //Null  Params
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'GetTimerTimestamp';
        request.httpMethod = 'GET';
        request.params.put('gameId', null);
        RestContext.request = request;

        response = PlanningPokerRest.doGet();
        ppr = PlanningPokerTestUtil.deserializeValues(response);
        system.assert(!ppr.isSuccess);
        system.assertEquals('Required parameters missing', ppr.errorMsg);

        Test.stopTest();
    }

    @isTest
    static void testInsertPlayer() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 2'];

        Test.startTest();

        // Missing Body
        RestRequest request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'InsertPlayer';
        request.httpMethod = 'POST';
        RestContext.request = request;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        PlanningPokerRest.doPost();

        List<Player__c> players = [
            SELECT Id
            FROM Player__c
            WHERE Game__c = :game.Id AND Name = 'SomeRandomName'
        ];
        system.assertEquals(0, players.size());

        //Null  Body values
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'InsertPlayer';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(
            '{"gameId": null, "playerName": null}'
        );
        RestContext.request = request;
        PlanningPokerRest.doPost();

        players = [
            SELECT Id
            FROM Player__c
            WHERE Game__c = :game.Id AND Name = 'SomeRandomName'
        ];
        system.assertEquals(0, players.size());

        //Valid Request
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'InsertPlayer';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(
            '{"gameId":"' +
            game.Id +
            '", "playerName":"SomeRandomName"}'
        );
        RestContext.request = request;
        PlanningPokerRest.doPost();

        players = [
            SELECT Id
            FROM Player__c
            WHERE Game__c = :game.Id AND Name = 'SomeRandomName'
        ];
        system.assertEquals(1, players.size());

        Test.stopTest();
    }

    @isTest
    static void testInsertVote() {
        Game__c game = [SELECT Id FROM Game__c WHERE Name = 'Test 4'];

        Player__c player = new Player__c();
        player.Name = 'Test Name';
        player.Game__c = game.Id;
        insert player;

        Backlog_Item__c cbi = [SELECT Id FROM Backlog_Item__c LIMIT 1];

        Test.startTest();

        // Missing Body
        RestRequest request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'CaptureVote';
        request.httpMethod = 'POST';
        RestContext.request = request;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        PlanningPokerRest.doPost();

        List<PlanningPokerCtrl.PlayerResponse> responses = PlanningPokerCtrl.getPlayerResponses(
            game.Id,
            cbi.Id
        );
        system.assertEquals(null, responses[0].response);

        //Null  Body values
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'CaptureVote';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(
            '{"gameId": null, "playerName": null}'
        );
        RestContext.request = request;
        PlanningPokerRest.doPost();

        responses = PlanningPokerCtrl.getPlayerResponses(game.Id, cbi.Id);
        system.assertEquals(null, responses[0].response);

        //Valid Request
        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'CaptureVote';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(
            '{"gameId":"' +
            game.Id +
            '", "storyId":"' +
            cbi.Id +
            '", "playerId":"' +
            player.Id +
            '", "response":"2"}'
        );
        RestContext.request = request;
        PlanningPokerRest.doPost();

        responses = PlanningPokerCtrl.getPlayerResponses(game.Id, cbi.Id);
        system.assertEquals('2', responses[0].response);

        Test.stopTest();
    }

    @isTest
    static void testGetServiceDoesNotExist() {
        RestRequest request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'SomeRandomService';
        request.httpMethod = 'GET';
        RestContext.request = request;

        String response = PlanningPokerRest.doGet();

        PlanningPokerRest.PlanningPokerServicesResponse ppr = PlanningPokerTestUtil.deserializeValues(
            response
        );
        system.assertEquals(null, ppr.data);
        system.assert(!ppr.isSuccess);
        system.assertEquals(
            'The service you are trying to reach does not exist',
            ppr.errorMsg
        );
    }

    @isTest
    static void testPostServiceDoesNotExist() {
        RestRequest request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'SomeRandomService';
        request.httpMethod = 'POST';
        RestContext.request = request;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        PlanningPokerRest.doPost();

        request = new RestRequest();
        request.requestUri = INSTANCE_URL + 'SomeRandomService';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"gameId":"somedata"}');
        RestContext.request = request;

        PlanningPokerRest.doPost();
    }
}
