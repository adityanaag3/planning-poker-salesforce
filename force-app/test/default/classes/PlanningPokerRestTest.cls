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
    static void testServiceDoesNotExist() {
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
}
