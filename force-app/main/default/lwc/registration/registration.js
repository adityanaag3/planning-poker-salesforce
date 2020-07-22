import { LightningElement, wire } from 'lwc';
import NODATA_SVG from '@salesforce/resourceUrl/EmptyState';
import getHerokuAppURL from '@salesforce/apex/PlanningPokerCtrl.getHerokuAppURL';

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import GameStateChange from '@salesforce/messageChannel/Game_State_Change__c';

export default class Registration extends LightningElement {
    noDataSvgUrl = `${NODATA_SVG}#noDataErrorIllustration`;
    gameId;
    subscription = null;
    gamePin;

    @wire(MessageContext)
    messageContext;

    @wire(getHerokuAppURL)
    appUrl;

    get herokuAppUrl() {
        if (this.appUrl.data) {
            return this.appUrl.data + 'play/' + this.gamePin;
        }
        return '';
    }

    // Encapsulate logic for LMS subscribe/unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                GameStateChange,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    // Handler for message received by component
    handleMessage(message) {
        if (message.state === 'selected') {
            this.gameId = message.recordId;
            this.gamePin = this.gameId.substr(10, 5);
        }

        if (message.state === 'endgame' && message.recordId === this.gameId) {
            this.gameId = undefined;
        }
    }

    // Standard lifecycle hooks used to sub/unsub to message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
}
