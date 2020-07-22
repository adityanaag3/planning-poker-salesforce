sfdx force:org:delete -u planningpoker
sfdx force:org:create -a planningpoker -s -f config/project-scratch-def.json -d 7
sfdx force:source:push
sfdx force:user:permset:assign -n Planning_Poker_Host
sfdx force:apex:execute -f scripts/apex/createPushTopics.apex
sfdx force:org:open -p /lightning/o/Game__c/home
echo "Org is set up"