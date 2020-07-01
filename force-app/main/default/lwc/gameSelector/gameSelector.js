import { LightningElement, wire } from 'lwc';
import getValidGames from '@salesforce/apex/PlanningPokerCtrl.getValidGames';
import { refreshApex } from '@salesforce/apex';

export default class GameSelector extends LightningElement {
    @wire(getValidGames)
    validGames;

    selectedGame;

    isLaunchDisabled = true;

    handleGameChange(event) {
        this.selectedGame = event.target.value;
        if (this.selectedGame) {
            this.isLaunchDisabled = false;
        } else {
            this.isLaunchDisabled = true;
        }
    }

    doLaunchGame() {
        let selectedGamePhase;
        if (this.validGames.data) {
            this.validGames.data.forEach(game => {
                if (game.Id === this.selectedGame) {
                    selectedGamePhase = game.Phase__c;
                }
            });
            const event = new CustomEvent('launch', {
                detail: {
                    gameId: this.selectedGame,
                    gamePhase: selectedGamePhase
                }
            });
            this.dispatchEvent(event);
        }
    }

    connectedCallback() {
        if (this.validGames && this.validGames.data) {
            refreshApex(this.validGames);
        }
    }
}
