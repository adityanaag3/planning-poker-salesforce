/* eslint-disable no-console */
import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableCardSets from '@salesforce/apex/PlanningPokerCtrl.getAvailableCardSets';
import getCustomObjects from '@salesforce/apex/PlanningPokerCtrl.getCustomObjects';
import getListViewsOfObject from '@salesforce/apex/PlanningPokerCtrl.getListViewsOfObject';
import GAME_SETTINGS_FIELD from '@salesforce/schema/Game__c.Config__c';
import ID_FIELD from '@salesforce/schema/Game__c.Id';
import getGameSettings from '@salesforce/apex/PlanningPokerCtrl.getGameSettings';

export default class GameSettings extends LightningElement {
    selectedObject;
    selectedCardSet;
    selectedNameField;
    selectedDescriptionField;
    selectedConsensusField;
    selectedListViewId;

    objectInfoFromWire;

    textFieldsFromObject;
    longTextFieldsFromObject;
    consensusEligibleFieldsFromObject;

    error;

    @api recordId;

    @wire(getAvailableCardSets)
    cardSets;

    @wire(getCustomObjects)
    customObjects;

    @wire(getObjectInfo, { objectApiName: '$selectedObject' })
    selectedObjectInfo({ error, data }) {
        if (data) {
            this.objectInfoFromWire = data;
            this.textFieldsFromObject = this.getFieldsFromObjectInfo(
                data,
                'String'
            );
            this.longTextFieldsFromObject = this.getFieldsFromObjectInfo(
                data,
                'TextArea'
            );
            this.consensusEligibleFieldsFromObject =
                this.getFieldsFromObjectInfo(data, ['String', 'Double']);
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getListViewsOfObject, { objName: '$selectedObject' })
    listViews;

    connectedCallback() {
        getGameSettings({ gameId: this.recordId })
            .then((result) => {
                if (result) {
                    this.selectedCardSet = result.cardSet;
                    this.selectedNameField = result.nameField;
                    this.selectedDescriptionField = result.descriptionField;
                    this.selectedListViewId = result.listViewId;
                    this.selectedConsensusField = result.consensusField;
                    this.selectedObject = result.objectApiName;
                }
            })
            .catch((error) => {
                console.error(error);
            });
    }

    renderedCallback() {
        this.setUIValues();
    }

    setUIValues() {
        this.template.querySelector('[name=cardSet]').value =
            this.selectedCardSet;
        this.template.querySelector('[name=storySource]').value =
            this.selectedObject;
        this.template.querySelector('[name=nameField]').value =
            this.selectedNameField;
        this.template.querySelector('[name=descriptionField]').value =
            this.selectedDescriptionField;
        this.template.querySelector('[name=consensusField]').value =
            this.selectedConsensusField;
        this.template.querySelector('[name=filterField]').value =
            this.selectedListViewId;
    }

    getFieldsFromObjectInfo(obj, datatype) {
        if (!Array.isArray(datatype)) {
            datatype = [datatype];
        }
        let selectedFields = [];
        if (obj && obj.fields) {
            let allFields = obj.fields;
            // eslint-disable-next-line guard-for-in
            for (let prop in allFields) {
                let field = allFields[prop];
                if (datatype.includes(field.dataType)) {
                    selectedFields.push({
                        apiName: field.apiName,
                        label: field.label
                    });
                }
            }
        }
        return selectedFields;
    }

    getDataType(fieldname) {
        let obj = this.objectInfoFromWire;
        if (obj && obj.fields) {
            let allFields = obj.fields;
            // eslint-disable-next-line guard-for-in
            for (let prop in allFields) {
                let field = allFields[prop];
                if (field.apiName === fieldname) {
                    return field.dataType;
                }
            }
        }
        return 'String';
    }

    handleConfigChange(event) {
        let targetName = event.target.name;
        let value = event.target.value;
        if (targetName === 'cardSet') {
            this.selectedCardSet = value;
        } else if (targetName === 'storySource') {
            this.selectedObject = value;
        } else if (targetName === 'nameField') {
            this.selectedNameField = value;
        } else if (targetName === 'descriptionField') {
            this.selectedDescriptionField = value;
        } else if (targetName === 'consensusField') {
            this.selectedConsensusField = value;
        } else if (targetName === 'filterField') {
            this.selectedListViewId = value;
        }
    }

    saveSettings() {
        let fields = {};
        let gameSettings = {
            cardSet: this.selectedCardSet,
            object: this.selectedObject,
            name: this.selectedNameField,
            description: this.selectedDescriptionField,
            consensus: this.selectedConsensusField,
            listView: this.selectedListViewId,
            consensusFieldType: this.getDataType(this.selectedConsensusField)
        };

        if (Object.keys(gameSettings).every((key) => gameSettings[key])) {
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[GAME_SETTINGS_FIELD.fieldApiName] =
                JSON.stringify(gameSettings);
            const recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Game Settings Updated',
                            variant: 'success'
                        })
                    );
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'An error occurred when updating the game settings',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'All fields are requried',
                    message: 'Please fill out all the fields in the form',
                    variant: 'error'
                })
            );
        }
    }
}
