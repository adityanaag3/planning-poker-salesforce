#!/bin/bash

# Set parameters
ORG_ALIAS="planningpoker"

if [ "$#" -eq 1 ]; then
  ORG_ALIAS=$1
fi

echo ""
echo "Installing Planning Poker on Salesforce org:"
echo "- Org alias:      $ORG_ALIAS"
echo ""

# Install script
echo "Cleaning previous scratch org..."
sfdx force:org:delete -p -u $ORG_ALIAS &> /dev/null
echo ""

echo "Creating scratch org..." && \
sfdx force:org:create -s -f config/project-scratch-def.json -a $ORG_ALIAS -d 7 && \
echo "" && \

echo "Pushing source..." && \
sfdx force:source:push -f -u $ORG_ALIAS && \
echo "" && \

echo "Assigning permissions..." && \
sfdx force:user:permset:assign -n Planning_Poker_Host -u $ORG_ALIAS && \
echo "" && \

echo "Creating Push Topics..." && \
sfdx force:apex:execute -f scripts/apex/createPushTopics.apex -u $ORG_ALIAS && \
echo ""

EXIT_CODE="$?"

# Check exit code
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Installation completed."
  echo ""
  sfdx force:org:open -p /lightning/o/Game__c/home -u $ORG_ALIAS
else
    echo "Installation failed."
fi

exit $EXIT_CODE
