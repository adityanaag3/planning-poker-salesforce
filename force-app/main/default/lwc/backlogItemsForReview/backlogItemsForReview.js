/* eslint-disable no-console */
import { LightningElement, wire, api } from 'lwc';

import getCardSet from '@salesforce/apex/PlanningPokerCtrl.getCardSet';
import NODATA_SVG from '@salesforce/resourceUrl/EmptyState';
import captureVote from '@salesforce/apex/PlanningPokerCtrl.captureVote';

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
    publish
} from 'lightning/messageService';

import GameStateChange from '@salesforce/messageChannel/Game_State_Change__c';

import getGameSettings from '@salesforce/apex/PlanningPokerCtrl.getGameSettings';
import updateGameCurrentStory from '@salesforce/apex/PlanningPokerCtrl.updateGameCurrentStory';

import sendflipCardsEvent from '@salesforce/apex/PlanningPokerCtrl.sendflipCardsEvent';

import { getListUi } from 'lightning/uiListApi';

export default class BacklogItemsForReview extends LightningElement {
    @api gameId;
    @api playerId;
    @api namespace;

    estimateOptions;
    currentItem;
    error;
    subscription = null;
    showSpinner = true;

    noDataSvgUrl = `${NODATA_SVG}#noDataErrorIllustration`;

    offset = 0;

    cardsFlipped = false;

    get storyId() {
        return this.currentItem.itemId;
    }

    @wire(MessageContext)
    messageContext;

    pageTokenToRetrieve = 0;
    pageSize;
    nextPageToken;

    isOffsetInProgress = false;
    currentOffset = 0;

    gameSettings;
    listViewId;
    fieldsToRetrieve = [];

    //timer
    showTimer = false;
    timerDuration;

    @wire(getListUi, {
        listViewId: '$listViewId',
        pageToken: '$pageTokenToRetrieve',
        pageSize: '$pageSize',
        optionalFields: '$fieldsToRetrieve'
    })
    processData({ data, error }) {
        if (data) {
            if (this.isOffsetInProgress) {
                this.isOffsetInProgress = false;
                this.pageTokenToRetrieve = data.records.nextPageToken;
                this.pageSize = 1;
            } else {
                this.updateCurrentQuestionOnScreen(data);
            }
        } else if (error) {
            this.currentItem = undefined;
            this.showSpinner = false;
            console.error(error);
        }
    }

    nextQuestion() {
        this.pageTokenToRetrieve = this.nextPageToken;
        this.currentOffset++;
    }

    updateCurrentQuestionOnScreen(data) {
        this.showSpinner = false;
        if (this.gameSettings) {
            this.nextPageToken = data.records.nextPageToken;
            let recordsFromListView = data.records.records;
            if (recordsFromListView && recordsFromListView.length > 0) {
                let currentRecord = recordsFromListView[0];
                let obj = {};
                obj.itemName =
                    currentRecord.fields[this.gameSettings.nameField].value;
                obj.itemDescription =
                    currentRecord.fields[
                        this.gameSettings.descriptionField
                    ].value;
                obj.itemId = currentRecord.fields.Id.value;
                this.currentItem = obj;
                this.cardsFlipped = false;
                this.resetCards();
                this.resetTimer();
            } else {
                this.currentItem = undefined;
            }

            let storyId = this.currentItem
                ? this.currentItem.itemId
                : undefined;

            const payload = { recordId: storyId, state: 'storychange' };
            publish(this.messageContext, GameStateChange, payload);

            updateGameCurrentStory({
                gameId: this.gameId,
                storyId,
                offset: this.currentOffset
            }).catch((error) => {
                console.error(error);
            });
        }
    }

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
        if (message.state === 'flipcards' && message.recordId === this.gameId) {
            this.cardsFlipped = message.additionalData;
        }

        if (
            message.state === 'resetcards' &&
            message.recordId === this.gameId
        ) {
            this.cardsFlipped = false;
            this.resetCards();
            this.resetTimer();
        }

        if (
            message.state === 'nextquestion' &&
            message.recordId === this.gameId
        ) {
            this.nextQuestion();
        }

        if (message.state === 'endgame' && message.recordId === this.gameId) {
            this.dispatchEvent(new CustomEvent('endgame'));
        }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();

        getGameSettings({ gameId: this.gameId })
            .then((result) => {
                this.gameSettings = result;

                this.currentOffset =
                    this.gameSettings.game[
                        `${this.namespace}Question_Offset__c`
                    ];
                if (
                    this.gameSettings.game[
                        `${this.namespace}Question_Offset__c`
                    ] !== 0
                ) {
                    this.pageSize =
                        this.gameSettings.game[
                            `${this.namespace}Question_Offset__c`
                        ];
                    this.isOffsetInProgress = true;
                } else {
                    this.pageSize = 1;
                }

                this.showTimer =
                    this.gameSettings.game[`${this.namespace}Show_Timer__c`];
                if (this.showTimer === true) {
                    this.timerDuration =
                        this.gameSettings.game[
                            `${this.namespace}Timer_Duration__c`
                        ];
                }
                this.fieldsToRetrieve = [
                    result.nameField,
                    result.descriptionField
                ];
                this.listViewId = result.listViewId;
            })
            .catch((error) => {
                console.error(error);
                this.gameSettings = undefined;
            });
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    handleSelectedOption(event) {
        let selectedOption = event.target.dataset.label;
        this.resetCards();
        event.target.classList.add('selectedPokerCard');
        captureVote({
            storyId: this.currentItem.itemId,
            response: selectedOption,
            gameId: this.gameId,
            playerId: this.playerId
        })
            .then(() => {
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
            });
    }

    resetCards() {
        this.template.querySelectorAll('.pokerCard').forEach((node) => {
            node.classList.remove('selectedPokerCard');
        });
    }

    resetTimer() {
        if (this.showTimer && this.template.querySelector('c-timer')) {
            this.template.querySelector('c-timer').resetTimer();
        }
    }

    handleTimeUp() {
        this.cardsFlipped = true;
        sendflipCardsEvent({
            gameId: this.gameId,
            flipped: this.cardsFlipped
        }).catch((error) => {
            console.error(error);
        });
    }
}
