import { LightningElement } from 'lwc';
import getGameByGameKey from '@salesforce/apex/PlanningPokerCtrl.getGameByGameKey';
import insertPlayer from '@salesforce/apex/PlanningPokerCtrl.insertPlayer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PlayerApp extends LightningElement {
    isGameSelectionPhase = true;
    isPlayerRegistrationPhase = false;
    isGamePlayPhase = false;

    gameKey;

    gameId;
    playerId;

    handleGameKeyChange(event) {
        this.gameKey = event.target.value;
    }

    fetchGame() {
        getGameByGameKey({ gameKey: this.gameKey })
            .then(result => {
                if (result && result.Id) {
                    this.gameId = result.Id;
                    insertPlayer({
                        gameId: this.gameId,
                        isSalesforcePlayer: true
                    })
                        .then(insertPlayerResult => {
                            this.playerId = insertPlayerResult;
                            this.isGameSelectionPhase = false;
                            this.isPlayerRegistrationPhase = true;
                        })
                        .catch(error => {
                            this.error = error;
                        });
                } else {
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
            .catch(error => {
                this.error = error;
            });
    }
}
