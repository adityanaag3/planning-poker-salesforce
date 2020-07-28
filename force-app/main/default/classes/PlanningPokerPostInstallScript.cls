global class PlanningPokerPostInstallScript implements InstallHandler {
    global void onInstall(InstallContext context) {
        if (context.previousVersion() == null) {
            String namespace = PlanningPokerCtrl.getNameSpace();
            insertPushTopics(namespace);
        }
    }

    public static void insertPushTopics(String namespace) {
        if (namespace != null && namespace != '' && !namespace.endsWith('__')) {
            namespace = namespace + '__';
        }

        List<PushTopic> pushTopics = new List<PushTopic>();

        PushTopic pushTopic = new PushTopic();
        pushTopic.Name = 'GamePlayers';
        pushTopic.Query =
            'SELECT Id, Name, ' +
            namespace +
            'Game__c from ' +
            namespace +
            'Player__c';
        pushTopic.ApiVersion = 49.0;
        pushTopic.NotifyForOperationCreate = true;
        pushTopic.NotifyForOperationUpdate = false;
        pushTopic.NotifyForOperationUndelete = false;
        pushTopic.NotifyForOperationDelete = true;
        pushTopic.NotifyForFields = 'Referenced';
        pushTopics.add(pushTopic);

        pushTopic = new PushTopic();
        pushTopic.Name = 'PlayerResponses';
        pushTopic.Query =
            'SELECT Id, ' +
            namespace +
            'Story_ID__c, ' +
            namespace +
            'Game__c, ' +
            namespace +
            'Response__c, ' +
            namespace +
            'Player__c from ' +
            namespace +
            'Player_Response__c';
        pushTopic.ApiVersion = 49.0;
        pushTopic.NotifyForOperationCreate = true;
        pushTopic.NotifyForOperationUpdate = true;
        pushTopic.NotifyForOperationUndelete = false;
        pushTopic.NotifyForOperationDelete = true;
        pushTopic.NotifyForFields = 'Referenced';
        pushTopics.add(pushTopic);

        insert pushTopics;
    }
}
