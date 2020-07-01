sfdx force:org:delete -u planningpokersalesforce
sfdx force:org:create -a planningpokersalesforce -s -f config/project-scratch-def.json -d 7
sfdx force:source:push
sfdx force:user:permset:assign -n Planning_Poker_Host
sfdx force:org:open -p /lightning/page/home
echo "Org is set up"