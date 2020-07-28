@isTest
public class PlanningPokerGameSettingsTest {
    static String namespace = PlanningPokerTestUtil.namespace;

    @TestSetup
    static void createData() {
        PlanningPokerTestUtil.createTestData();
    }

    @IsTest
    static void checkFieldsOnGameSettingsForm() {
        if (namespace != null && namespace != '' && !namespace.endsWith('__')) {
            namespace = namespace + '__';
        }

        Test.startTest();

        List<Card_Set__mdt> cardSets = PlanningPokerCtrl.getAvailableCardSets();
        System.assertEquals(2, cardSets.size());

        List<String> customObjects = PlanningPokerCtrl.getCustomObjects();
        System.assert(customObjects.contains(namespace + 'Game__c'));

        List<ListView> views = PlanningPokerCtrl.getListViewsOfObject(
            namespace + 'Game__c'
        );
        System.assert(views.size() > 0);

        Test.stopTest();
    }

    @isTest
    static void checkIfGameSettingsAreCorrectlyRetrieved() {
        Card_Set__mdt cs = [
            SELECT Id
            FROM Card_Set__mdt
            WHERE Label = 'Fibonacci'
        ];
        Game__c g = [
            SELECT Id, Show_Timer__c, Timer_Duration__c
            FROM Game__c
            WHERE Name = 'Test 2'
        ];

        Test.startTest();
        PlanningPokerCtrl.GameSettings gs = PlanningPokerCtrl.getGameSettings(
            g.Id
        );
        system.assertEquals('00B0p000001XhUQEA0', gs.listViewId);
        system.assertEquals('User_Story__c', gs.nameField);
        system.assertEquals('Notes__c', gs.descriptionField);
        system.assertEquals('Consensus__c', gs.consensusField);
        system.assertEquals('Backlog_Item__c', gs.objectApiName);
        system.assertEquals(cs.Id, gs.cardSet);
        system.assertEquals(g.Show_Timer__c, gs.game.Show_Timer__c);
        system.assertEquals(g.Timer_Duration__c, gs.game.Timer_Duration__c);
        Test.stopTest();
    }

    @isTest
    static void checkIfCardSetIsRetrievedCorrectly() {
        Card_Set__mdt cs = [
            SELECT Id
            FROM Card_Set__mdt
            WHERE Label = 'Fibonacci'
        ];
        Game__c g = [
            SELECT Id, Show_Timer__c, Timer_Duration__c
            FROM Game__c
            WHERE Name = 'Test 2'
        ];

        Test.startTest();
        List<PlanningPokerCtrl.PokerCard> pokerCards = PlanningPokerCtrl.getCardSet(
            g.Id
        );
        system.assertEquals(11, pokerCards.size());

        system.assertEquals('0', pokerCards[0].name);
        system.assertEquals('background:#0094ff', pokerCards[0].colorHexCode);

        system.assertEquals('Pass', pokerCards[10].name);
        system.assertEquals('background:#ccc', pokerCards[10].colorHexCode);

        Test.stopTest();
    }

    @isTest
    static void testHerokuAppURL() {
        String url = PlanningPokerCtrl.getHerokuAppURL();
        system.assert(url == null);
    }
}
