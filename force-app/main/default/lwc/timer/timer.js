import { LightningElement, api } from 'lwc';

export default class Timer extends LightningElement {
    @api durationInSeconds;

    secondsPassed = 0;
    secondsLeft;

    timerId;

    get timeLeft() {
        return this.formatTime(this.secondsLeft);
    }

    get strokeDashArray() {
        const rawTimeFraction = this.secondsLeft / this.durationInSeconds;
        const adjustedTimeFraction =
            rawTimeFraction -
            (1 / this.durationInSeconds) * (1 - rawTimeFraction);
        const dashWidth = (adjustedTimeFraction * 283).toFixed(0);
        return `${dashWidth} 283`;
    }

    get remainingPathColor() {
        const progressPercent = this.secondsPassed / this.durationInSeconds;
        return this.getColor(progressPercent);
    }

    connectedCallback() {
        this.secondsLeft = this.durationInSeconds;
        this.startTimer();
    }

    getColor(percent) {
        const hue = ((1 - percent) * 120).toString(10);
        return `hsl(${hue}, 100%, 50%)`;
    }

    formatTime(timeInSeconds) {
        const minutes = Math.floor(timeInSeconds / 60);

        let seconds = timeInSeconds % 60;
        if (seconds < 10) {
            seconds = `0${seconds}`;
        }

        return `${minutes}:${seconds}`;
    }

    startCountdown() {
        if (!this.timerId) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.timerId = setInterval(() => {
                this.secondsPassed = this.secondsPassed + 1;
                this.secondsLeft = this.durationInSeconds - this.secondsPassed;
                if (this.secondsLeft === 0) {
                    clearInterval(this.timerId);
                    this.timerId = undefined;
                    this.dispatchEvent(new CustomEvent('timeup'));
                }
            }, 1000);
        }
    }

    @api
    resetTimer() {
        this.secondsPassed = 0;
        this.secondsLeft = this.durationInSeconds;
        this.startTimer();
    }

    @api
    startTimer() {
        this.startCountdown();
    }
}
