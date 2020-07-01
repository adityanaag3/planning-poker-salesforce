List<PushTopic> pushTopics = new List<PushTopic>();

PushTopic pushTopic = new PushTopic();
pushTopic.Name = 'GamePlayers';
pushTopic.Query = 'SELECT Id, Name, Game__c from Player__c';
pushTopic.ApiVersion = 48.0;
pushTopic.NotifyForOperationCreate = true;
pushTopic.NotifyForOperationUpdate = false;
pushTopic.NotifyForOperationUndelete = false;
pushTopic.NotifyForOperationDelete = true;
pushTopic.NotifyForFields = 'Referenced';
pushTopics.add(pushTopic);

pushTopic = new PushTopic();
pushTopic.Name = 'PlayerResponses';
pushTopic.Query = 'SELECT Id, Story_ID__c, Game__c, Response__c, Player__c from Player_Response__c';
pushTopic.ApiVersion = 48.0;
pushTopic.NotifyForOperationCreate = true;
pushTopic.NotifyForOperationUpdate = true;
pushTopic.NotifyForOperationUndelete = false;
pushTopic.NotifyForOperationDelete = true;
pushTopic.NotifyForFields = 'Referenced';
pushTopics.add(pushTopic);

insert pushTopics;