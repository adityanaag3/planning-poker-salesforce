/* eslint-disable no-console */
import { LightningElement, wire } from 'lwc';
import getGameByGameKey from '@salesforce/apex/PlanningPokerCtrl.getGameByGameKey';
import insertPlayer from '@salesforce/apex/PlanningPokerCtrl.insertPlayer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getNameSpace from '@salesforce/apex/PlanningPokerCtrl.getNameSpace';

import * as empApi from 'lightning/empApi';

export default class PlayerApp extends LightningElement {
    showSpinner = false;

    get isGameSelectionPhase() {
        return this.gameId ? false : true;
    }

    get isGamePlayPhase() {
        return this.gameId && this.gameStatus === 'In Progress' && this.playerId
            ? true
            : false;
    }

    get isPlayerRegistrationPhase() {
        return (
            this.gameId &&
            this.gameStatus !== 'In Progress' &&
            this.gameStatus !== 'Completed'
        );
    }

    gameStateChange_subscription;

    gameKey;
    gameStatus;

    error;

    gameId;
    playerId;

    namespace;

    @wire(getNameSpace, { withUnderscore: true })
    namespaceFn({ error, data }) {
        if (error) {
            this.namespace = '';
        } else if (data) {
            this.namespace = data;
            if (!this.namespace) {
                this.namespace = '';
            }
        }
    }

    connectedCallback() {
        this.initEmpApi();
    }

    disconnectedCallback() {
        if (this.gameStateChange_subscription) {
            empApi.unsubscribe(this.gameStateChange_subscription, () => {
                this.gameStateChange_subscription = undefined;
            });
        }
    }

    handleGameKeyChange(event) {
        this.gameKey = event.target.value;
    }

    initEmpApi() {
        empApi.onError((error) => {
            // eslint-disable-next-line no-console
            console.error('Streaming API error: ' + JSON.stringify(error));
        });
        empApi
            .subscribe('/event/Game_State_Change__e', -1, (message) => {
                this.handleGameStateChange(message);
            })
            .then((response) => {
                this.gameStateChange_subscription = response;
            });
    }

    handleGameStateChange(message) {
        let data = message.data;
        let payload = data.payload;
        if (payload[`${this.namespace}GameID__c`] === this.gameId) {
            if (payload[`${this.namespace}Type__c`] === 'GamePhaseChange') {
                this.gameStatus = payload[`${this.namespace}Data__c`];
                if (this.gameStatus === 'Completed') {
                    this.gameId = null;
                }
            } else if (payload[`${this.namespace}Type__c`] === 'StoryChange') {
                this.template
                    .querySelector('c-player-backlog-items')
                    .getUnvotedItem();
            } else if (payload[`${this.namespace}Type__c`] === 'CardFlip') {
                this.template
                    .querySelector('c-player-backlog-items')
                    .flipCards(payload[`${this.namespace}Data__c`]);
            } else if (payload[`${this.namespace}Type__c`] === 'ResetCards') {
                this.template
                    .querySelector('c-player-backlog-items')
                    .resetCards();
            }
        }
    }

    fetchGame() {
        this.showSpinner = true;
        getGameByGameKey({ gameKey: this.gameKey })
            .then((result) => {
                this.error = undefined;
                if (result && result.Id) {
                    this.gameId = result.Id;
                    this.gameStatus = result[`${this.namespace}Phase__c`];
                    this.showTimer = result[`${this.namespace}Show_Timer__c`];
                    this.timerDuration =
                        result[`${this.namespace}Timer_Duration__c`];
                    insertPlayer({
                        gameId: this.gameId,
                        isSalesforcePlayer: true
                    })
                        .then((insertPlayerResult) => {
                            this.error = undefined;
                            this.playerId = insertPlayerResult;
                            this.showSpinner = false;
                        })
                        .catch((error) => {
                            this.error = error;
                            this.showSpinner = false;
                            console.error(error);
                        });
                } else {
                    this.showSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Game not found',
                            message:
                                'No game in progress is found with the key you have entered',
                            variant: 'error'
                        })
                    );
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                this.error = error;
                console.error(error);
            });
    }
}
