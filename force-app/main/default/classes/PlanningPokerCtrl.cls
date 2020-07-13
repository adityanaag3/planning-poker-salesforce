public without sharing class PlanningPokerCtrl {
    
    /**
     *  Methods for Game Settings
     */
    
    @AuraEnabled(cacheable=true)
    public static List<Card_Set__mdt> getAvailableCardSets() {
        return [SELECT Id, MasterLabel FROM Card_Set__mdt];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getCustomObjects() {
        List<String> customObjects = new List<String>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for (Schema.SObjectType objTyp : gd.values()) {
            String name = objTyp.getDescribe().getName();
            if (name.endsWith('__c')) {
                customObjects.add(name);
            }
        }
        return customObjects;
    }

    @AuraEnabled(cacheable=true)
    public static List<ListView> getListViewsOfObject(String objName) {
        return [SELECT Id, Name FROM ListView WHERE sObjectType = :objName];
    }

    @AuraEnabled
    public static GameSettings getGameSettings(String gameId) {
        GameSettings gs;
        Game__c game = [
            SELECT Id, Name, Show_Timer__c, Timer_Duration__c, Config__c
            FROM Game__c
            WHERE Id = :gameId
        ];
        if (game.Config__c != null) {
            try {
                Object config = JSON.deserializeUntyped(game.Config__c);
                Map<String, Object> configMap = (Map<String, Object>) config;
                if (
                    configMap.get('object') != null &&
                    configMap.get('name') != null &&
                    configMap.get('description') != null &&
                    configMap.get('listView') != null &&
                    configMap.get('consensus') != null &&
                    configMap.get('object') != null
                ) {
                    gs = new GameSettings();
                    gs.cardSet = (String) configMap.get('cardSet');
                    gs.nameField = (String) configMap.get('name');
                    gs.descriptionField = (String) configMap.get('description');
                    gs.listViewId = (String) configMap.get('listView');
                    gs.consensusField = (String) configMap.get('consensus');
                    gs.objectApiName = (String) configMap.get('object');
                    gs.game = game;
                    gs.game.Config__c = null;
                }
            } catch (Exception e) {
                system.debug(e);
            }
        }
        return gs;
    }

    @AuraEnabled(cacheable=true)
    public static String getHerokuAppURL() {
        String url;
        List<Game_Setting__mdt> gameSettings = [
            SELECT DeveloperName, Value__c
            FROM Game_Setting__mdt
        ];
        if (!gameSettings.isEmpty()) {
            for (Game_Setting__mdt gs : gameSettings) {
                if (gs.DeveloperName == 'Heroku_App_URL') {
                    url = gs.Value__c;
                    if (!url.endsWith('/')) {
                        url = url + '/';
                    }
                }
            }
        }
        return url;
    }

    @AuraEnabled(cacheable=true)
    public static List<PokerCard> getCardSet(String gameId) {
        List<PokerCard> allCards = new List<PokerCard>();
        try {
            Game__c game = [
                SELECT Id, Name, Config__c, Show_Timer__c, Timer_Duration__c
                FROM Game__c
                WHERE Id = :gameId
            ];
            if (game.Config__c != null) {
                Object config = JSON.deserializeUntyped(game.Config__c);
                Map<String, Object> configMap = (Map<String, Object>) config;
                if (configMap.get('cardSet') != null) {
                    String cardSetId = (String) configMap.get('cardSet');
                    Card_Set__mdt cardSet = [
                        SELECT Id, MasterLabel, Card_Values__c
                        FROM Card_Set__mdt
                        WHERE Id = :cardSetId
                    ];
                    if (cardSet.Card_Values__c != null) {
                        List<String> values = cardSet.Card_Values__c.split(',');
                        for (String s : values) {
                            PokerCard pc = new PokerCard();
                            pc.name = s.trim();
                            if (pc.name == 'Pass') {
                                pc.colorHexCode = '#ccc';
                            } else if (pc.name == '?') {
                                pc.colorHexCode = '#efe013';
                            } else {
                                pc.colorHexCode = '#0094ff';
                            }
                            pc.colorHexCode = 'background:' + pc.colorHexCode;
                            allCards.add(pc);
                        }
                    }
                }
            }
        } catch (Exception e) {
            system.debug(e);
        }
        return allCards;
    }


    /**
     *  Methods for Game Launch and Phase Updates
     */

    @AuraEnabled(cacheable=true)
    public static List<Game__c> getValidGames() {
        List<Game__c> games = new List<Game__c>();
        for (Game__c g : [
            SELECT Id, Name, Config__c, Phase__c
            FROM Game__c
            WHERE Phase__c != 'Completed'
            ORDER BY CreatedDate DESC
            LIMIT 100
        ]) {
            if (g.Config__c != null) {
                games.add(g);
            }
        }
        return games;
    }

    @AuraEnabled
    public static Game__c getGameByGameKey(String gameKey) {
        List<Game__c> games = [
            SELECT
                Id,
                Name,
                Config__c,
                Show_Timer__c,
                Timer_Duration__c,
                Phase__c
            FROM Game__c
            WHERE Phase__c != 'Completed' AND Game_Key__c = :gameKey
        ];
        if (!games.isEmpty()) {
            return games[0];
        }
        return null;
    }

    @AuraEnabled
    public static void updateGameCurrentStory(String gameId, String storyId) {
        Game__c game = [
            SELECT Id, Current_Story_ID__c
            FROM Game__c
            WHERE Id = :gameId
        ];
        if (storyId != game.Current_Story_ID__c) {
            game.Current_Story_ID__c = storyId;
            update game;
            /*Game_State_Change__e stateChangeEvent = new Game_State_Change__e();
            stateChangeEvent.GameID__c = gameId;
            stateChangeEvent.Type__c = 'StoryChange';
            stateChangeEvent.Data__c = storyId;
            Eventbus.publish(stateChangeEvent);*/
            PlanningPokerEventUtil.fireStoryChangeEvent(gameId, storyId);
        }
    }

    @AuraEnabled
    public static void changeGamePhase(String gameId, String currentPhase) {
        Game__c game = [SELECT Id, Phase__c FROM Game__c WHERE Id = :gameId];

        String nextPhase;
        if (currentPhase == 'Not Started') {
            nextPhase = 'Registration';
        } else if (currentPhase == 'Registration') {
            nextPhase = 'In Progress';
        } else if (currentPhase == 'In Progress') {
            nextPhase = 'Completed';
        }

        if (nextPhase != null && game.Phase__c != nextPhase) {
            game.Phase__c = nextPhase;
            update game;
            /*Game_State_Change__e stateChangeEvent = new Game_State_Change__e();
            stateChangeEvent.GameID__c = gameId;
            stateChangeEvent.Type__c = 'GamePhaseChange';
            stateChangeEvent.Data__c = nextPhase;
            Eventbus.publish(stateChangeEvent);*/
            PlanningPokerEventUtil.fireGamePhaseChangeEvent(gameId, nextPhase);
        }
    }

    @AuraEnabled
    public static BacklogItem getCurrentStory(String gameId) {
        BacklogItem b;
        Game__c game = [
            SELECT
                Id,
                Name,
                Config__c,
                Show_Timer__c,
                Timer_Duration__c,
                Current_Story_ID__c
            FROM Game__c
            WHERE Id = :gameId
        ];
        if (game.Config__c != null) {
            try {
                Object config = JSON.deserializeUntyped(game.Config__c);
                Map<String, Object> configMap = (Map<String, Object>) config;
                if (
                    configMap.get('object') != null &&
                    configMap.get('name') != null &&
                    configMap.get('description') != null
                ) {
                    String soqlQuery =
                        'select Id, ' +
                        (String) configMap.get('name') +
                        ', ' +
                        (String) configMap.get('description') +
                        ' from ' +
                        (String) configMap.get('object') +
                        ' where Id = \'' +
                        game.Current_Story_ID__c +
                        '\'';
                    system.debug(soqlQuery);
                    List<sObject> records = Database.query(
                        soqlQuery + ' limit 1'
                    );
                    if (records.size() > 0) {
                        sObject record = records[0];
                        b = new BacklogItem();
                        b.itemName = (String) record.get(
                            (String) configMap.get('name')
                        );
                        b.itemDescription = (String) record.get(
                            (String) configMap.get('description')
                        );
                        b.itemId = (String) record.get('Id');
                    }
                }
                b.cards = getCardSet(gameId);
            } catch (Exception e) {
                system.debug(e);
            }
        }
        return b;
    }


    /**
     * Methods for Game Players
     */

    @AuraEnabled
    public static List<Player__c> getGamePlayers(String gameId) {
        return [SELECT Id, Name FROM Player__c WHERE Game__c = :gameId];
    }

    @AuraEnabled
    public static void deleteAllPlayers(String gameId, Boolean exceptMe) {
        if (exceptMe) {
            delete [
                SELECT Id
                FROM Player__c
                WHERE Game__c = :gameId AND Name != :UserInfo.getName()
            ];
        } else {
            delete [SELECT Id FROM Player__c WHERE Game__c = :gameId];
        }
    }

    public static Id checkForExistingPlayers(String gameId, String playerName) {
        List<Player__c> players = [
            SELECT Id
            FROM Player__c
            WHERE Name = :playerName.trim() AND Game__c = :gameId
        ];
        if (players.size() == 0) {
            return null;
        } else {
            return players[0].Id;
        }
    }

    @AuraEnabled
    public static Id insertPlayer(
        String gameId,
        String playerName,
        Boolean isHost,
        Boolean isSalesforcePlayer
    ) {
        if (isHost || isSalesforcePlayer) {
            playerName = UserInfo.getName();
        }

        Id playerId = checkForExistingPlayers(gameId, playerName);
        if (playerId != null) {
            return playerId;
        } else {
            Boolean canInsertPlayer = true;
            Player__c p = new Player__c();
            p.Game__c = gameId;
            p.Name = playerName;
            if (isHost) {
                Game__c g = [
                    SELECT Host_can_vote__c
                    FROM Game__c
                    WHERE Id = :gameId
                ];
                if (!g.Host_can_vote__c) {
                    canInsertPlayer = false;
                }
            }
            if (canInsertPlayer) {
                insert p;
                return p.Id;
            }
        }
        return null;
    }


    /**
     *  Methods for Player Responses
     */

    @AuraEnabled
    public static void captureVote(
        String storyId,
        String response,
        String playerId,
        String gameId
    ) {
        List<Player_Response__c> existingResponse = [
            SELECT Id
            FROM Player_Response__c
            WHERE
                Game__c = :gameId
                AND Player__c = :playerId
                AND Story_ID__c = :storyId
        ];

        Player_Response__c pr = new Player_Response__c();
        pr.Response__c = response;
        if (existingResponse.size() > 0) {
            pr.Id = existingResponse[0].Id;
        } else {
            pr.Game__c = gameId;
            pr.Player__c = playerId;
            pr.Story_ID__c = storyId;
        }
        upsert pr;
    }

    @AuraEnabled(cacheable=true)
    public static List<PlayerResponse> getPlayerResponses(
        String gameId,
        String storyId
    ) {
        List<Player__c> gamePlayers = getGamePlayers(gameId);
        List<PokerCard> pokerCards = getCardSet(gameId);

        Map<Id, String> playerResponsesMap = new Map<Id, String>();
        for (Player_Response__c pr : [
            SELECT Id, Response__c, Player__c
            FROM Player_Response__c
            WHERE Game__c = :gameId AND Story_ID__c = :storyId
        ]) {
            playerResponsesMap.put(pr.Player__c, pr.Response__c);
        }

        Map<String, PokerCard> responseCardMap = new Map<String, PokerCard>();
        for (PokerCard p : pokerCards) {
            responseCardMap.put(p.name, p);
        }

        List<PlayerResponse> playerResponses = new List<PlayerResponse>();
        for (Player__c p : gamePlayers) {
            PlayerResponse pr = new PlayerResponse();
            pr.player = p;
            pr.response = playerResponsesMap.get(p.Id);
            pr.pokerCard = responseCardMap.get(pr.response);
            playerResponses.add(pr);
        }

        return playerResponses;
    }


    /**
     *  Methods for Host Controls
     */

    @AuraEnabled
    public static void sendflipCardsEvent(String gameId, String flipped) {
        /*Game_State_Change__e stateChangeEvent = new Game_State_Change__e();
        stateChangeEvent.GameID__c = gameId;
        stateChangeEvent.Type__c = 'CardFlip';
        stateChangeEvent.Data__c = flipped;
        Eventbus.publish(stateChangeEvent);*/
        PlanningPokerEventUtil.fireFlipCardsEvent(gameId, flipped);
    }

    @AuraEnabled
    public static void resetCards(String gameId) {
        Game__c g = [
            SELECT Id, Current_Story_ID__c
            FROM Game__c
            WHERE Id = :gameId
        ];
        delete ([
            SELECT Id
            FROM Player_Response__c
            WHERE Game__c = :gameId AND Story_ID__c = :g.Current_Story_ID__c
        ]);
        /*Game_State_Change__e stateChangeEvent = new Game_State_Change__e();
        stateChangeEvent.GameID__c = gameId;
        stateChangeEvent.Type__c = 'ResetCards';
        stateChangeEvent.Data__c = g.Current_Story_ID__c;
        Eventbus.publish(stateChangeEvent);*/
        PlanningPokerEventUtil.fireResetCardsEvent(gameId, g.Current_Story_ID__c);
    }

    @AuraEnabled
    public static Boolean saveConsensus(
        String storyId,
        String objectApiName,
        String consensusField,
        String consensusValue
    ) {
        Boolean isSuccess = false;
        Schema.SObjectType targetType = Schema.getGlobalDescribe()
            .get(objectApiName);
        if (targetType != null) {
            sObject s = targetType.newSObject();
            s.put('Id', storyId);
            s.put(consensusField, consensusValue);
            update s;
            isSuccess = true;
        }
        return isSuccess;
    }


    /**
     * Wrapper Classes 
     */
    

    public class PlayerResponse {
        @AuraEnabled
        public Player__c player;

        @AuraEnabled
        public String response;

        @AuraEnabled
        public PokerCard pokerCard;
    }

    public class GameSettings {
        @AuraEnabled
        public Game__c game;

        @AuraEnabled
        public String listViewId;

        @AuraEnabled
        public String nameField;

        @AuraEnabled
        public String descriptionField;

        @AuraEnabled
        public String consensusField;

        @AuraEnabled
        public String objectApiName;

        @AuraEnabled
        public String cardSet;
    }

    public class PokerCard {
        @AuraEnabled
        public String name;

        @AuraEnabled
        public String colorHexCode;
    }

    public class BacklogItem {
        @AuraEnabled
        public String itemName;

        @AuraEnabled
        public String itemDescription;

        @AuraEnabled
        public String itemId;

        @AuraEnabled
        public List<PokerCard> cards;
    }
}
