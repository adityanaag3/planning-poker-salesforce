import { LightningElement, track, api } from 'lwc';
import * as empApi from 'lightning/empApi';
import getGamePlayers from '@salesforce/apex/PlanningPokerCtrl.getGamePlayers';
import insertPlayer from '@salesforce/apex/PlanningPokerCtrl.insertPlayer';
import deleteAllPlayers from '@salesforce/apex/PlanningPokerCtrl.deleteAllPlayers';

export default class PlayerList extends LightningElement {
    subscription;
    error;

    @track playerNames = [];

    @api gameId;

    currentPlayerId;

    connectedCallback() {
        insertPlayer({ gameId: this.gameId, isHost: true })
            .then((result) => {
                this.currentPlayerId = result;
                localStorage.setItem(
                    'playerId_' + this.gameId,
                    this.currentPlayerId
                );
                getGamePlayers({ gameId: this.gameId })
                    .then((gamePlayerResult) => {
                        this.playerNames = gamePlayerResult;
                        this.error = undefined;
                        this.initEmpApi();
                    })
                    .catch((error) => {
                        this.error = error;
                    });
            })
            .catch((error) => {
                this.error = error;
            });
    }

    initEmpApi() {
        empApi.onError((error) => {
            // eslint-disable-next-line no-console
            console.error('Streaming API error: ' + JSON.stringify(error));
        });
        empApi
            .subscribe('/topic/GamePlayers', -1, (pushNotification) => {
                this.handlePlayerUpdate(pushNotification);
            })
            .then((response) => {
                this.subscription = response;
            });
    }

    handlePlayerUpdate(pushNotification) {
        const { Id, Name, Game__c } = pushNotification.data.sobject;
        let playerObj = { Id, Name };
        if (this.gameId === Game__c && !this.playerNames.includes(Name)) {
            this.playerNames.push(playerObj);
        }
    }

    disconnectedCallback() {
        if (this.subscription) {
            empApi.unsubscribe(this.subscription, () => {
                this.subscription = undefined;
            });
        }
    }

    get isWaitingForPlayers() {
        return this.playerNames.length > 0 ? false : true;
    }

    doStartPlanning() {
        const event = new CustomEvent('playgame', {
            detail: { gameId: this.gameId, playerId: this.currentPlayerId }
        });
        this.dispatchEvent(event);
    }

    removePlayers() {
        deleteAllPlayers({ gameId: this.gameId, exceptMe: true })
            .then(() => {
                getGamePlayers({ gameId: this.gameId })
                    .then((result) => {
                        this.playerNames = result;
                        this.error = undefined;
                    })
                    .catch((error) => {
                        this.error = error;
                    });
            })
            .catch((error) => {
                this.error = error;
            });
    }
}
