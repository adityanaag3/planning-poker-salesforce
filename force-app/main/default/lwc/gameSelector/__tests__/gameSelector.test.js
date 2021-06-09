import { createElement } from 'lwc';
import getValidGames from '@salesforce/apex/PlanningPokerCtrl.getValidGames';

import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

import GameSelector from 'c/gameSelector';

// Realistic data with a list of games
const mockGameRecords = require('./data/getValidGames.json');

// Register as Apex wire adapter. Some tests verify that provisioned values trigger desired behavior.
const getValidGamesAdapter = registerApexTestWireAdapter(getValidGames);

describe('c-game-selector', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    it('displays list of games when @wire adapter returns data', () => {
        const element = createElement('c-game-selector', {
            is: GameSelector
        });
        document.body.appendChild(element);

        getValidGamesAdapter.emit(mockGameRecords);

        return Promise.resolve().then(() => {
            let optionElements = element.shadowRoot.querySelectorAll('option');
            expect(optionElements.length).toBe(mockGameRecords.length + 1);
            for (
                let i = 1, index = 0;
                i < optionElements.length;
                i++, index++
            ) {
                expect(optionElements[i].textContent).toBe(
                    mockGameRecords[index].Name
                );
            }
        });
    });

    it('displays no list when @wire adapter returns error', () => {
        const WIRE_ERROR = 'Custom Exception';

        const element = createElement('c-game-selector', {
            is: GameSelector
        });
        document.body.appendChild(element);

        getValidGamesAdapter.error(WIRE_ERROR);

        return Promise.resolve().then(() => {
            const optionElements =
                element.shadowRoot.querySelectorAll('option');
            expect(optionElements.length).toBe(1);
        });
    });

    it('toggles button disable property when game selection is made', () => {
        const element = createElement('c-game-selector', {
            is: GameSelector
        });
        document.body.appendChild(element);

        getValidGamesAdapter.emit(mockGameRecords);

        return Promise.resolve()
            .then(() => {
                const buttonEl =
                    element.shadowRoot.querySelector('lightning-button');
                expect(buttonEl.disabled).toBeTruthy();

                const selectEl = element.shadowRoot.querySelector('select');
                const optionElements =
                    element.shadowRoot.querySelectorAll('option');
                selectEl.value = optionElements[1].value;
                selectEl.dispatchEvent(new CustomEvent('change'));
            })
            .then(() => {
                const buttonEl =
                    element.shadowRoot.querySelector('lightning-button');
                expect(buttonEl.disabled).toBeFalsy();
            });
    });

    it('fires a custom event when launch button is clicked', () => {
        const element = createElement('c-game-selector', {
            is: GameSelector
        });
        document.body.appendChild(element);

        // listen to reservationselect event
        const handler = jest.fn();
        element.addEventListener('launch', handler);

        getValidGamesAdapter.emit(mockGameRecords);

        return Promise.resolve()
            .then(() => {
                const selectEl = element.shadowRoot.querySelector('select');
                const optionElements =
                    element.shadowRoot.querySelectorAll('option');
                selectEl.value = optionElements[1].value;
                selectEl.dispatchEvent(new CustomEvent('change'));
            })
            .then(() => {
                const buttonEl =
                    element.shadowRoot.querySelector('lightning-button');
                buttonEl.click();
            })
            .then(() => {
                expect(handler).toHaveBeenCalled();
                expect(handler.mock.calls[0][0].detail.gameId).toBe(
                    mockGameRecords[0].Id
                );
                expect(handler.mock.calls[0][0].detail.gamePhase).toBe(
                    mockGameRecords[0].Phase__c
                );
            });
    });
});
