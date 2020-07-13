public with sharing class PlanningPokerEventUtil {
    
    public static void fireStoryChangeEvent(String gameId, String storyId){
        Game_State_Change__e stateChangeEvent = new Game_State_Change__e();
        stateChangeEvent.GameID__c = gameId;
        stateChangeEvent.Type__c = 'StoryChange';
        stateChangeEvent.Data__c = storyId;
        Eventbus.publish(stateChangeEvent);
    }

    public static void fireGamePhaseChangeEvent(String gameId, String nextPhase){
        Game_State_Change__e stateChangeEvent = new Game_State_Change__e();
        stateChangeEvent.GameID__c = gameId;
        stateChangeEvent.Type__c = 'GamePhaseChange';
        stateChangeEvent.Data__c = nextPhase;
        Eventbus.publish(stateChangeEvent);
    }

    public static void fireFlipCardsEvent(String gameId, String flipped){
        Game_State_Change__e stateChangeEvent = new Game_State_Change__e();
        stateChangeEvent.GameID__c = gameId;
        stateChangeEvent.Type__c = 'CardFlip';
        stateChangeEvent.Data__c = flipped;
        Eventbus.publish(stateChangeEvent);
    }

    public static void fireResetCardsEvent(String gameId, String storyId){
        Game_State_Change__e stateChangeEvent = new Game_State_Change__e();
        stateChangeEvent.GameID__c = gameId;
        stateChangeEvent.Type__c = 'ResetCards';
        stateChangeEvent.Data__c = storyId;
        Eventbus.publish(stateChangeEvent);
    }
}
