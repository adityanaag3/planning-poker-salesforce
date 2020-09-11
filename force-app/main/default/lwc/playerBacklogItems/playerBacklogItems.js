/* eslint-disable no-console */
import { LightningElement, api } from 'lwc';

import NODATA_SVG from '@salesforce/resourceUrl/EmptyState';
import captureVote from '@salesforce/apex/PlanningPokerCtrl.captureVote';
import getCurrentStory from '@salesforce/apex/PlanningPokerCtrl.getCurrentStory';

export default class PlayerBacklogItems extends LightningElement {
    @api gameId;
    @api playerId;
    @api namespace;

    estimateOptions;
    currentItem;
    error;

    noDataSvgUrl = `${NODATA_SVG}#noDataErrorIllustration`;

    cardsFlipped = false;

    get storyId() {
        return this.currentItem.itemId;
    }

    //timer
    @api showTimer;
    @api timerDuration;

    connectedCallback() {
        this.getUnvotedItem();
    }

    @api
    getUnvotedItem() {
        getCurrentStory({ gameId: this.gameId })
            .then((data) => {
                this.error = undefined;
                if (data) {
                    this.estimateOptions = data.cards;
                    this.currentItem = data;
                    this.cardsFlipped = false;
                    this.resetCards();
                }
            })
            .catch((error) => {
                this.error = error;
                console.error(error);
            });
    }

    handleSelectedOption(event) {
        let selectedOption = event.target.dataset.label;
        this.clearSelectedPokerCard();
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

    clearSelectedPokerCard() {
        this.template.querySelectorAll('.pokerCard').forEach((node) => {
            node.classList.remove('selectedPokerCard');
        });
    }

    @api
    resetCards() {
        this.clearSelectedPokerCard();
        this.resetTimer();
    }

    @api
    flipCards(flipped) {
        if (flipped === 'true') {
            this.cardsFlipped = true;
        } else {
            this.cardsFlipped = false;
        }
    }

    resetTimer() {
        if (this.showTimer && this.template.querySelector('c-timer')) {
            this.template.querySelector('c-timer').resetTimer();
        }
    }

    handleTimeUp() {
        this.cardsFlipped = true;
    }
}
