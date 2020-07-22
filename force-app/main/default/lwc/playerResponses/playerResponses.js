import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import * as empApi from 'lightning/empApi';
import getPlayerResponses from '@salesforce/apex/PlanningPokerCtrl.getPlayerResponses';

export default class PlayerList extends LightningElement {
    p_subscription;
    pr_subscription;
    error;

    @track playerResponses;

    @api gameId;
    @api storyId;

    @api cardsFlipped;

    @wire(getPlayerResponses, { gameId: '$gameId', storyId: '$storyId' })
    playerResponsesHandler(result) {
        this.wiredPlayerResponses = result;
        const { error, data } = result;
        if (error) {
            this.error = error;
        } else if (data) {
            this.playerResponses = data;
            this.error = undefined;
        }
    }

    connectedCallback() {
        this.initEmpApi();
    }

    initEmpApi() {
        empApi.onError((error) => {
            // eslint-disable-next-line no-console
            console.error('Streaming API error: ' + JSON.stringify(error));
        });
        empApi
            .subscribe('/topic/GamePlayers', -1, (pushNotification) => {
                this.handlePlayerCreationEvent(pushNotification);
            })
            .then((response) => {
                this.p_subscription = response;
            });

        empApi
            .subscribe('/topic/PlayerResponses', -1, (pushNotification) => {
                this.refreshCards(pushNotification);
            })
            .then((response) => {
                this.pr_subscription = response;
            });
    }

    handlePlayerCreationEvent(pushNotification) {
        const { Game__c } = pushNotification.data.sobject;
        if (this.gameId === Game__c) {
            refreshApex(this.wiredPlayerResponses);
        }
    }

    refreshCards(pushNotification) {
        const { Story_ID__c, Game__c } = pushNotification.data.sobject;
        if (
            (this.gameId === Game__c && this.storyId === Story_ID__c) ||
            pushNotification.data.event.type === 'deleted'
        ) {
            refreshApex(this.wiredPlayerResponses);
        }
    }

    disconnectedCallback() {
        if (this.p_subscription) {
            empApi.unsubscribe(this.p_subscription, () => {
                this.p_subscription = undefined;
            });
        }

        if (this.pr_subscription) {
            empApi.unsubscribe(this.pr_subscription, () => {
                this.pr_subscription = undefined;
            });
        }
    }

    get isWaitingForPlayers() {
        return this.playerNames.length > 0 ? false : true;
    }

    doStartPlanning() {
        const event = new CustomEvent('playgame', {
            detail: { gameId: this.gameId }
        });
        this.dispatchEvent(event);
    }
}
