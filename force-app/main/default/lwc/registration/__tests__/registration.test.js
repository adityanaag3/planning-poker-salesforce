import { createElement } from 'lwc';
import Registration from 'c/registration';

import getHerokuAppURL from '@salesforce/apex/PlanningPokerCtrl.getHerokuAppURL';

import {
    registerApexTestWireAdapter,
    registerTestWireAdapter
} from '@salesforce/sfdx-lwc-jest';

import { subscribe, MessageContext, publish } from 'lightning/messageService';
import GameStateChange from '@salesforce/messageChannel/Game_State_Change__c';

// Register as Apex wire adapter. Some tests verify that provisioned values trigger desired behavior.
const getHerokuAppURLAdapter = registerApexTestWireAdapter(getHerokuAppURL);

// eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
const messageContextWireAdapter = registerTestWireAdapter(MessageContext);

const SELECT_MESSAGE_PAYLOAD = {
    recordId: '012345678901234567',
    state: 'selected',
    additionalData: null
};

const HEROKU_URL = 'https://someurl.com/';

describe('c-registration', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    it('subscribes to the GameStateChange on load', () => {
        const element = createElement('c-registration', {
            is: Registration
        });

        document.body.appendChild(element);

        expect(subscribe).toHaveBeenCalled();
        expect(subscribe.mock.calls[0][1]).toBe(GameStateChange);
    });

    it('shows a no data image on load', () => {
        const element = createElement('c-registration', {
            is: Registration
        });

        document.body.appendChild(element);

        const divEl = element.shadowRoot.querySelector('div');
        expect(divEl.textContent).toBe('Launch a game to view the details');
    });

    it('shows game pin when GameStateChange of type selected is received', () => {
        const element = createElement('c-registration', {
            is: Registration
        });

        document.body.appendChild(element);

        publish(
            messageContextWireAdapter,
            GameStateChange,
            SELECT_MESSAGE_PAYLOAD
        );

        return Promise.resolve().then(() => {
            const divEl = element.shadowRoot.querySelector('.gamePin');
            expect(divEl.textContent).toBe('01234');
        });
    });

    it('game pin is cleared when GameStateChange of type endgame is recieved', () => {
        const element = createElement('c-registration', {
            is: Registration
        });

        document.body.appendChild(element);

        publish(
            messageContextWireAdapter,
            GameStateChange,
            SELECT_MESSAGE_PAYLOAD
        );

        return Promise.resolve()
            .then(() => {
                const ENDGAME_MESSAGE_PAYLOAD = {
                    recordId: '012345678901234567',
                    state: 'endgame',
                    additionalData: null
                };
                publish(
                    messageContextWireAdapter,
                    GameStateChange,
                    ENDGAME_MESSAGE_PAYLOAD
                );
            })
            .then(() => {
                const divEl = element.shadowRoot.querySelector('.gamePin');
                expect(divEl).toBeNull();
            });
    });

    it('shows heroku app url when configured', () => {
        const element = createElement('c-registration', {
            is: Registration
        });

        document.body.appendChild(element);

        publish(
            messageContextWireAdapter,
            GameStateChange,
            SELECT_MESSAGE_PAYLOAD
        );

        getHerokuAppURLAdapter.emit(HEROKU_URL);

        return Promise.resolve().then(() => {
            const aEl = element.shadowRoot.querySelector('a');
            expect(aEl.textContent).toBe(HEROKU_URL + 'play/01234');
        });
    });

    it('does not show heroku app url when not configured', () => {
        const element = createElement('c-registration', {
            is: Registration
        });

        document.body.appendChild(element);

        publish(
            messageContextWireAdapter,
            GameStateChange,
            SELECT_MESSAGE_PAYLOAD
        );

        getHerokuAppURLAdapter.emit(null);

        return Promise.resolve().then(() => {
            const aEl = element.shadowRoot.querySelector('a');
            expect(aEl).toBeNull();
        });
    });
});
