/* eslint-disable no-console */
import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import GameStateChange from '@salesforce/messageChannel/Game_State_Change__c';
import changeGamePhase from '@salesforce/apex/PlanningPokerCtrl.changeGamePhase';
import getNameSpace from '@salesforce/apex/PlanningPokerCtrl.getNameSpace';

export default class HostApp extends LightningElement {
    gameId;
    playerId;

    namespace;

    @wire(MessageContext)
    messageContext;

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

    get isGameSelectionPhase() {
        return this.gameId ? false : true;
    }

    isPlayerRegistrationPhase = false;
    isGamePlayPhase = false;

    launchGame(event) {
        this.gameId = event.detail.gameId;
        let gamePhase = event.detail.gamePhase;
        let phaseUpdatedNeeded = false;
        if (gamePhase === 'Not Started') {
            this.isPlayerRegistrationPhase = true;
            phaseUpdatedNeeded = true;
            const payload = { recordId: this.gameId, state: 'selected' };
            publish(this.messageContext, GameStateChange, payload);
        } else if (gamePhase === 'Registration') {
            this.isPlayerRegistrationPhase = true;
            const payload = { recordId: this.gameId, state: 'selected' };
            publish(this.messageContext, GameStateChange, payload);
        } else if (gamePhase === 'In Progress') {
            this.isPlayerRegistrationPhase = false;
            let playerId = localStorage.getItem('playerId_' + this.gameId);
            if (playerId) {
                this.playerId = playerId;
            }
            this.isGamePlayPhase = true;

            const payload_selected = {
                recordId: this.gameId,
                state: 'selected'
            };
            publish(this.messageContext, GameStateChange, payload_selected);
            const payload_started = { recordId: this.gameId, state: 'started' };
            publish(this.messageContext, GameStateChange, payload_started);
        }

        if (phaseUpdatedNeeded) {
            changeGamePhase({
                gameId: this.gameId,
                currentPhase: gamePhase
            }).catch((error) => {
                console.error(error);
            });
        }
    }

    startGamePlay(event) {
        this.gameId = event.detail.gameId;
        this.playerId = event.detail.playerId;
        this.isPlayerRegistrationPhase = false;
        this.isGamePlayPhase = true;
        const payload = { recordId: this.gameId, state: 'started' };
        publish(this.messageContext, GameStateChange, payload);

        changeGamePhase({
            gameId: this.gameId,
            currentPhase: 'Registration'
        }).catch((error) => {
            console.error(error);
        });
    }

    handleGameEnd() {
        this.isPlayerRegistrationPhase = false;
        this.isGamePlayPhase = false;
        this.gameId = undefined;
        this.playerId = undefined;
    }
}
