/* eslint-disable no-console */
import { LightningElement, wire } from 'lwc';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
    publish
} from 'lightning/messageService';
import GameStateChange from '@salesforce/messageChannel/Game_State_Change__c';
import getCardSet from '@salesforce/apex/PlanningPokerCtrl.getCardSet';
import sendflipCardsEvent from '@salesforce/apex/PlanningPokerCtrl.sendflipCardsEvent';
import changeGamePhase from '@salesforce/apex/PlanningPokerCtrl.changeGamePhase';
import resetCards from '@salesforce/apex/PlanningPokerCtrl.resetCards';
import saveConsensus from '@salesforce/apex/PlanningPokerCtrl.saveConsensus';
import getGameSettings from '@salesforce/apex/PlanningPokerCtrl.getGameSettings';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HostControls extends LightningElement {
    gameId;
    storyId;
    subscription = null;

    flipped = false;

    estimateOptions;
    gameSettings;

    @wire(MessageContext)
    messageContext;

    @wire(getCardSet, { gameId: '$gameId' })
    cardSetValues({ error, data }) {
        if (data) {
            this.estimateOptions = data;
        } else if (error) {
            console.error(error);
            this.error = error;
        }
    }

    // Encapsulate logic for LMS subscribe/unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                GameStateChange,
                message => this.handleMessage(message),
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
        if (message.state === 'started') {
            this.gameId = message.recordId;
            getGameSettings({ gameId: this.gameId })
                .then(result => {
                    this.gameSettings = result;
                })
                .catch(error => {
                    console.error(error);
                    this.gameSettings = undefined;
                });
        }

        if (message.state === 'storychange') {
            this.storyId = message.recordId;
        }
    }

    // Standard lifecycle hooks used to sub/unsub to message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    revealCards() {
        this.flipCards(true);
    }

    hideCards() {
        this.flipCards(false);
    }

    flipCards(flipState) {
        this.flipped = flipState;
        const payload = {
            recordId: this.gameId,
            state: 'flipcards',
            additionalData: this.flipped
        };
        publish(this.messageContext, GameStateChange, payload);

        sendflipCardsEvent({
            gameId: this.gameId,
            flipped: this.flipped
        }).catch(error => {
            console.error(error);
        });
    }

    goToNextStory() {
        const payload = { recordId: this.gameId, state: 'nextquestion' };
        publish(this.messageContext, GameStateChange, payload);
    }

    endGame() {
        localStorage.removeItem('playerId_' + this.gameId);
        localStorage.removeItem('nextPageToken_' + this.gameId);
        localStorage.removeItem('currentPageToken_' + this.gameId);
        changeGamePhase({ gameId: this.gameId, currentPhase: 'In Progress' })
            .then(() => {
                const payload = { recordId: this.gameId, state: 'endgame' };
                publish(this.messageContext, GameStateChange, payload);
                this.gameId = undefined;
            })
            .catch(error => {
                console.error(error);
            });
    }

    resetAllCards() {
        resetCards({ gameId: this.gameId })
            .then(() => {
                const payload = { recordId: this.gameId, state: 'resetcards' };
                publish(this.messageContext, GameStateChange, payload);
            })
            .catch(error => {
                console.error(error);
            });
    }

    saveChosenConsensus() {
        let consensus = this.template.querySelector('[name=consensus]').value;
        saveConsensus({
            storyId: this.storyId,
            objectApiName: this.gameSettings.objectApiName,
            consensusField: this.gameSettings.consensusField,
            consensusValue: consensus
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Update Successful',
                        message: 'Consensus updated successfully.',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'An error occurred',
                        message: error,
                        variant: 'error'
                    })
                );
            });
    }
}
