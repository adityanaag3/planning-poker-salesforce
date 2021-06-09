import { createElement } from 'lwc';

import getQuestionTimeStamp from '@salesforce/apex/PlanningPokerCtrl.getQuestionTimeStamp';

import Timer from 'c/timer';

// Mocking imperative Apex method call
jest.mock(
    '@salesforce/apex/PlanningPokerCtrl.getQuestionTimeStamp',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe('c-timer', () => {
    beforeAll(() => {
        // We use fake timers as setInterval is used in the JavaScript file.
        jest.useFakeTimers();
    });

    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllTimers();
    });

    function flushPromises() {
        // eslint-disable-next-line no-undef
        return new Promise((resolve) => setImmediate(resolve));
    }

    it('displays remaining time correctly on load when no data from server is sent', () => {
        getQuestionTimeStamp.mockResolvedValue(null);

        const element = createElement('c-timer', {
            is: Timer
        });
        element.durationInSeconds = 60;
        element.gameId = '000000';

        document.body.appendChild(element);

        return flushPromises().then(() => {
            let timeEl = element.shadowRoot.querySelector('.base-timer__label');
            expect(timeEl.textContent).toBe('1:00');
        });
    });

    it('displays remaining time correctly on load when server data is sent', () => {
        const date = new Date();
        const currentTimestamp = date.getTime();
        const thirtysecondslater = currentTimestamp + 30 * 1000;

        getQuestionTimeStamp.mockResolvedValue(thirtysecondslater);

        const element = createElement('c-timer', {
            is: Timer
        });
        element.durationInSeconds = 60;
        element.gameId = '000000';

        document.body.appendChild(element);

        return flushPromises().then(() => {
            let timeEl = element.shadowRoot.querySelector('.base-timer__label');
            expect(timeEl.textContent).toBe('0:30');
        });
    });

    it('emit timeout event on load when time from server is in the past', () => {
        const date = new Date();
        const currentTimestamp = date.getTime();
        const thirtysecondsbefore = currentTimestamp - 30 * 1000;

        getQuestionTimeStamp.mockResolvedValue(thirtysecondsbefore);

        const element = createElement('c-timer', {
            is: Timer
        });
        element.durationInSeconds = 60;
        element.gameId = '000000';

        document.body.appendChild(element);

        // listen to reservationselect event
        const handler = jest.fn();
        element.addEventListener('timeup', handler);

        return flushPromises().then(() => {
            let timeEl = element.shadowRoot.querySelector('.base-timer__label');
            expect(timeEl.textContent).toBe('0:00');
            expect(handler).toHaveBeenCalled();
        });
    });

    it('emit timeout event when timer runs out', () => {
        getQuestionTimeStamp.mockResolvedValue(null);

        const element = createElement('c-timer', {
            is: Timer
        });
        element.durationInSeconds = 60;
        element.gameId = '000000';

        document.body.appendChild(element);

        // listen to reservationselect event
        const handler = jest.fn();
        element.addEventListener('timeup', handler);

        return flushPromises()
            .then(() => {
                jest.runAllTimers();
            })
            .then(() => {
                let timeEl =
                    element.shadowRoot.querySelector('.base-timer__label');
                expect(timeEl.textContent).toBe('0:00');
                expect(handler).toHaveBeenCalled();
            });
    });

    it('timer value changes when duration has passed', () => {
        getQuestionTimeStamp.mockResolvedValue(null);

        const element = createElement('c-timer', {
            is: Timer
        });
        element.durationInSeconds = 60;
        element.gameId = '000000';

        document.body.appendChild(element);

        return flushPromises()
            .then(() => {
                jest.advanceTimersByTime(10 * 1000);
            })
            .then(() => {
                let timeEl =
                    element.shadowRoot.querySelector('.base-timer__label');
                expect(timeEl.textContent).toBe('0:50');
            });
    });

    it('timer value doesnt go into negative value', () => {
        getQuestionTimeStamp.mockResolvedValue(null);

        const element = createElement('c-timer', {
            is: Timer
        });
        element.durationInSeconds = 60;
        element.gameId = '000000';

        document.body.appendChild(element);

        return flushPromises()
            .then(() => {
                jest.advanceTimersByTime(70 * 1000);
            })
            .then(() => {
                let timeEl =
                    element.shadowRoot.querySelector('.base-timer__label');
                expect(timeEl.textContent).toBe('0:00');
            });
    });

    it('timer value is reset when reset method is called', () => {
        getQuestionTimeStamp.mockResolvedValue(null);

        const element = createElement('c-timer', {
            is: Timer
        });
        element.durationInSeconds = 60;
        element.gameId = '000000';

        document.body.appendChild(element);

        return flushPromises()
            .then(() => {
                jest.advanceTimersByTime(10 * 1000);
            })
            .then(() => {
                element.resetTimer();
            })
            .then(() => {
                let timeEl =
                    element.shadowRoot.querySelector('.base-timer__label');
                expect(timeEl.textContent).toBe('1:00');
            });
    });
});
