@echo OFF

rem set parameters
if [%1]==[] (
  set ORG_ALIAS=planningpoker
) else (
  set ORG_ALIAS=%1
)

@echo:
echo Installing Planning Poker on Salesforce org:
echo - Org alias:      %ORG_ALIAS%
@echo:

rem Install script
echo Cleaning previous scratch org...
cmd.exe /c sfdx force:org:delete -p -u %ORG_ALIAS% 2>NUL
@echo:

echo Creating scratch org...
cmd.exe /c sfdx force:org:create -s -f config/project-scratch-def.json -a %ORG_ALIAS% -d 30
call :checkForError
@echo:

echo Pushing source...
cmd.exe /c sfdx force:source:push -f -u %ORG_ALIAS%
call :checkForError
@echo:

echo Assigning permissions...
cmd.exe /c sfdx force:user:permset:assign -n Planning_Poker_Host -u %ORG_ALIAS%
call :checkForError
@echo:

echo Creating Push Topics...
cmd.exe /c sfdx force:apex:execute -f scripts/apex/createPushTopics.apex -u %ORG_ALIAS%
call :checkForError
@echo:

rem Check exit code
@echo:
if ["%errorlevel%"]==["0"] (
  echo Installation completed.
  @echo:
  cmd.exe /c sfdx force:org:open -p /lightning/o/Game__c/home -u %ORG_ALIAS%
)

:: ======== FN ======
GOTO :EOF

rem if the app has failed
:checkForError
if NOT ["%errorlevel%"]==["0"] (
    echo Installation failed.
    exit /b %errorlevel%
)