@RestResource(urlMapping='/PlanningPokerServices/*')
global with sharing class PlanningPokerRest {
    @HttpGet
    global static String doGet() {
        PlanningPokerServicesResponse ppr = new PlanningPokerServicesResponse();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            String serviceName = req.requestURI.substring(
                req.requestURI.lastIndexOf('/') + 1
            );
            switch on serviceName {
                when 'ValidateGameKey' {
                    if (RestContext.request.params != null) {
                        String gameKey = RestContext.request.params.get(
                            'gameKey'
                        );
                        if (gameKey != null) {
                            ppr.data = PlanningPokerCtrl.getGameByGameKey(
                                gameKey
                            );
                        } else {
                            throw new RequiredParametersMissingException(
                                'Required parameters missing'
                            );
                        }
                    } else {
                        throw new RequiredParametersMissingException(
                            'Required parameters missing'
                        );
                    }
                }
                when 'VerifyPlayer' {
                    if (RestContext.request.params != null) {
                        String gameId = RestContext.request.params.get(
                            'gameId'
                        );
                        String playerName = RestContext.request.params.get(
                            'playerName'
                        );
                        if (gameId != null && playerName != null) {
                            ppr.data = PlanningPokerCtrl.checkForExistingPlayers(
                                gameId,
                                playerName
                            );
                        } else {
                            throw new RequiredParametersMissingException(
                                'Required parameters missing'
                            );
                        }
                    } else {
                        throw new RequiredParametersMissingException(
                            'Required parameters missing'
                        );
                    }
                }
                when 'GetAllPlayerResponses' {
                    if (RestContext.request.params != null) {
                        String gameId = RestContext.request.params.get(
                            'gameId'
                        );
                        String storyId = RestContext.request.params.get(
                            'storyId'
                        );
                        if (gameId != null && storyId != null) {
                            ppr.data = PlanningPokerCtrl.getPlayerResponses(
                                gameId,
                                storyId
                            );
                        } else {
                            throw new RequiredParametersMissingException(
                                'Required parameters missing'
                            );
                        }
                    } else {
                        throw new RequiredParametersMissingException(
                            'Required parameters missing'
                        );
                    }
                }
                when 'GetCurrentUnvotedItem' {
                    if (RestContext.request.params != null) {
                        String gameId = RestContext.request.params.get(
                            'gameId'
                        );
                        if (gameId != null) {
                            ppr.data = PlanningPokerCtrl.getCurrentStory(
                                gameId
                            );
                        } else {
                            throw new RequiredParametersMissingException(
                                'Required parameters missing'
                            );
                        }
                    } else {
                        throw new RequiredParametersMissingException(
                            'Required parameters missing'
                        );
                    }
                }
                when 'GetTimerTimestamp' {
                    if (RestContext.request.params != null) {
                        String gameId = RestContext.request.params.get(
                            'gameId'
                        );
                        if (gameId != null) {
                            List<Game__c> g = [select Id, Timer_Timestamp__c from Game__c where Id =: gameId];
                            if(!g.isEmpty()){
                                ppr.data = g[0].Timer_Timestamp__c;
                            } else {
                                throw new DataException('No Game exists with this ID');
                            }
                        } else {
                            throw new RequiredParametersMissingException(
                                'Required parameters missing'
                            );
                        }
                    } else {
                        throw new RequiredParametersMissingException(
                            'Required parameters missing'
                        );
                    }
                }
                when else {
                    throw new NoSuchServiceException(
                        'The service you are trying to reach does not exist'
                    );
                }
            }

            ppr.isSuccess = true;
        } catch (Exception e) {
            ppr.isSuccess = false;
            ppr.errorMsg = e.getMessage();
        }
        return JSON.serialize(ppr);
    }

    @HttpPost
    global static void doPost() {
        PlanningPokerServicesResponse ppr = new PlanningPokerServicesResponse();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String data = RestContext.request.requestBody.toString();
        try {
            String serviceName = req.requestURI.substring(
                req.requestURI.lastIndexOf('/') + 1
            );
            switch on serviceName {
                when 'InsertPlayer' {
                    if (data != null) {
                        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
                            data
                        );
                        String gameId = (String) params.get('gameId');
                        String playerName = (String) params.get('playerName');
                        if (gameId != null && playerName != null) {
                            ppr.data = PlanningPokerCtrl.insertPlayer(
                                gameId,
                                playerName,
                                false,
                                false
                            );
                        } else {
                            throw new RequiredParametersMissingException(
                                'Required parameters missing'
                            );
                        }
                    } else {
                        throw new RequiredParametersMissingException(
                            'Required parameters missing'
                        );
                    }
                }
                when 'CaptureVote' {
                    if (data != null) {
                        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
                            data
                        );
                        String storyId = (String) params.get('storyId');
                        String response = (String) params.get('response');
                        String playerId = (String) params.get('playerId');
                        String gameId = (String) params.get('gameId');
                        if (
                            storyId != null &&
                            response != null &&
                            playerId != null &&
                            gameId != null
                        ) {
                            PlanningPokerCtrl.captureVote(
                                storyId,
                                response,
                                playerId,
                                gameId
                            );
                        } else {
                            throw new RequiredParametersMissingException(
                                'Required parameters missing'
                            );
                        }
                    } else {
                        throw new RequiredParametersMissingException(
                            'Required parameters missing'
                        );
                    }
                }
                when else {
                    throw new NoSuchServiceException(
                        'The service you are trying to reach does not exist'
                    );
                }
            }

            ppr.isSuccess = true;
        } catch (Exception e) {
            ppr.isSuccess = false;
            ppr.errorMsg = e.getMessage();
        }
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(ppr));
    }

    global class PlanningPokerServicesResponse {
        global Boolean isSuccess;
        global String errorMsg;
        global Object data;
    }

    global class NoSuchServiceException extends Exception {
    }

    global class RequiredParametersMissingException extends Exception {
    }

    global class DataException extends Exception {
    }
}
