<p align="center">
  <img src="https://github.com/adityanaag3/planning-poker-heroku/raw/master/src/client/resources/logo.png" alt="Planning Poker Icon" width="150"/>
</p>

# Planning Poker App built on Salesforce

[![Github Workflow](https://github.com/adityanaag3/planning-poker-salesforce/workflows/Scratch%20Org/badge.svg?branch=master)](https://github.com/adityanaag3/planning-poker-salesforce/actions?query=workflow%3A%22Scratch+Org%22+branch%3Amaster) [![Github Workflow](https://github.com/adityanaag3/planning-poker-salesforce/workflows/Packaging/badge.svg)](https://github.com/adityanaag3/planning-poker-salesforce/actions?query=workflow%3A%22Packaging%22) [![codecov](https://codecov.io/gh/adityanaag3/planning-poker-salesforce/branch/master/graph/badge.svg)](https://codecov.io/gh/adityanaag3/planning-poker-salesforce)

1. [About](#about)
1. [Features](#features)
1. [Technology Stack](#technology-stack)
1. [Installation](#installation)
    1. [Host and Player app for Salesforce Users](#host-and-player-app-for-salesforce-users)
        1. [Using a package](#using-a-package)
        1. [Using SFDX Commands](#using-sfdx-commands)
    1. [Player app for Guests](#player-app-for-guests)
1. [Game Setup](#game-setup)
    1. [Creating a game](#creating-a-game)
    1. [Hosting a game](#hosting-a-game)
    1. [Playing a game on Salesforce](#playing-a-game-on-salesforce)
    1. [Playing a game on Heroku](#playing-a-game-on-heroku)
1. [Roadmap](#roadmap)
1. [Building and contributing](#building-and-contributing)

## About

Planning poker is a consensus-based, gamified technique for estimating user stories in Scrum. This app allows you to utilize this technique for your planning and is completely built on Salesforce.

This Planning Poker app offers 2 custom apps on Salesforce: The Host App and the Player App. Both of these apps can only be accessed by licensed users on Salesforce.

You can optionally also install the guest version of the player app on Heroku to allow players without Salesforce Licenses to paricipate. You'll need a free [Heroku account](https://signup.heroku.com) to set it up. A free account lets you run the game with a small group of players. If you run the game with a larger group, consider upgrading to a [Hobby Dyno](https://www.heroku.com/dynos).

## Features

<ol>
    <li><b>Choose your own User Story Source</b> Before starting a game, you can select any Salesforce object to be the source of the list of user stories, and save the consensus (Story points) directly to the user story records.&nbsp;</li>
    <li><b>Use pre-defined card sets or create your own</b> This app comes with pre-defined card sets like Fibonacci and multiples of two. You can also create your own custom card sets.</li>
    <li><b>Hidden Cards</b> All player's responses are hidden until the timer runs out or until the host chooses to reveal them.</li>
    <li><b>Host Controls</b> The host has options to show a timer, hide or reveal cards, reset votes and more. The host can also play the game if they choose to.</li>
</ol>

## Technology Stack

-   The Host App and Player App on Salesforce are built using Lightning Web Components.
-   The app relies on Application Events, Platform Events and Push Topics to publish game state changes.
    -   The Lightning web components use the empApi and Lightning Message service to send and receive these events.
-   A combination of Salesforce data and HTML 5 Local Storage is used to maintain game state across page refreshes.
-   The Guest Player App is built using Lightning Web Components Open Source and uses Node.js as its backend.
-   It communicates with Salesforce using Custom Apex REST APIs.
-   It uses the OAuth JWT Bearer flow to connect with Salesforce.
-   The Node.js server uses Server Sent Events to deliver notifications to the HTML client.

## Installation

### Host and Player app for Salesforce Users

#### Using a package

<ol>
    <li>
        Click the button below to install on Developer Edition, Trailhead Playgroud or Production orgs<br/>
            <p>
                <a href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0o000003jP1oAAE">
                    <img src="/assets/install-production.png" alt="Install in Production">
                </a>
            </p>
    </li>
    <li>
        Click the button below to install on Sandboxes or Scratch Orgs<br/>
            <p>
                <a href="https://test.salesforce.com/packaging/installPackage.apexp?p0=04t0o000003jP1oAAE">
                    <img src="/assets/install-sandbox.png" alt="Install in Sandbox">
                </a>
            </p>
    </li>
    <li>Once the installation is successful, Open the Developer Console and go to Debug -> Execute Anonymous Window. </li>
    <li>Paste the following code, and click <b>Execute</b>
<pre>
planningpokersf.PlanningPokerPostInstallScript.insertPushTopics();</pre>
    </li>
    <li>To make a Salesforce user the host of a game, assign the <code>Planning Poker Host</code> permission set to them.</li>
    <li>Assign the <code>Planning Poker Player</code> permission set to any users who want to participate as players.</li>
</ol>

#### Using SFDX Commands

<ol>
    <li>Set up your Salesforce DX environment (see this <a href="https://trailhead.salesforce.com/en/content/learn/modules/sfdx_app_dev/sfdx_app_dev_setup_dx">Trailhead project</a> for guided steps):
        <ul>
            <li><a href="https://developer.salesforce.com/tools/sfdxcli">Install Salesforce CLI</a></li>
            <li>Enable <a href="https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_enable_devhub.htm">Dev Hub</a> on a Salesforce org. You can do that on a <a href="https://developer.salesforce.com/signup">free Developer Edition</a>.</li>
            <li>Authenticate with your Dev Hub org and provide it with an alias (<b>myhuborg</b> in the command below): 
            <pre>sfdx force:auth:web:login -d -a myhuborg</pre>
            </li>
        </ul>
    </li>
    <li>Open a Terminal and clone the git repository: 
        <pre>git clone https://github.com/adityanaag3/planning-poker-salesforce.git
cd planning-poker-salesforce</pre>
Tip: you can also download the files from the website if you don't want to install git.
    </li>
    <li>Run the installation script. The script deploys the Planning Poker App on a scratch org with a <code>planningpoker</code> alias.
        <p>MacOS or Linux</p>
<pre>sh scripts/setup/orgInit.sh</pre>
        <p>Windows</p>
<pre>scripts/setup/orgInit.bat</pre>
Once the script completes, it will open your new scratch org in a browser tab. If you close the tab or get disconnected, run this command to reopen the org 
<pre>sfdx force:org:open -u planningpoker</pre>
    </li>
    <li>To make a Salesforce user the host of a game, assign the <code>Planning Poker Host</code> permission set to them. The above installations script automatically assigns this permission set to the user who runs the script.</li>
    <li>Assign the <code>Planning Poker Player</code> permission set to any users who want to participate as players.</li>
</ol>

### Player app for Guests

Guests are players without Salesforce Licenses. Here are a few additional steps you need to follow

<ol>
    <li>Create a self signed certificate using the command
    <pre>openssl req  -nodes -new -x509  -keyout private.pem -out server.cert</pre>
    </li>
    <li>Create a Connected App in Salesforce with the below configuration
        <ol>
            <li>Select <b>Enable OAuth Settings</b></li>
            <li>Use <code>http://localhost:3001</code> as the Callback URL</li>
            <li>Select <b>Use digital signatures</b></li>
            <li>Upload the Certificate generated in the previous step</li>
            <li>Select <code>api</code> and <code>refresh_token, offline_access</code> in OAuth Scopes</li>
        </ol>
    </li>
    <li>Click on <b>Manage</b> and then click <b>Edit Policies</b></li>
    <li>Select <b>Admin approved users are pre authorized</b> in <b>Permitted Users</b> and <b>Save</b></li>
    <li>Select <b>Planning Poker Player</b> in the list of permission sets for the policy</li>
    <li>Deploy to Heroku using the button below<br/>
        <p>
            <a href="https://heroku.com/deploy?template=https://github.com/adityanaag3/planning-poker-heroku/master">
                <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy">
            </a>
        </p>
    </li>
    <li>
        Set the enviroment variables as follows
        <table>
        <tr>
          <th>Variable</th>
          <th>Description</th>
        </tr>
        <tr>
          <td>SF_CONSUMER_KEY</td>
          <td>Consumer Key of the Connected App</td>
        </tr>
        <tr>
          <td>SF_USERNAME</td>
          <td>Username of the integration user who has been assigned the <b>Planning Poker Player</b> permission set.</td>
        </tr>
        <tr>
          <td>SF_LOGIN_URL</td>
          <td>The login URL of your Salesforce org:<br/>
          <code>https://test.salesforce.com/</code> for scratch orgs and sandboxes<br/>
          <code>https://login.salesforce.com/</code> for Developer Edition and production</td>
        </tr>
        <tr>
          <td>PRIVATE_KEY</td>
          <td>Contents of the private.pem file generated from the certificate creation step</td>
        </tr>
        <td>SF_NAMESPACE</td>
          <td>Use <code>planningpokersf</code> if you have installed the host app using the packages listed <a href="https://github.com/adityanaag3/planning-poker-salesforce#using-a-package">here</a>. Else, use the namespace from <a href="https://github.com/adityanaag3/planning-poker-salesforce/blob/master/sfdx-project.json">sfdx-project.json</a> file.</td>
      </table>
    </li>
    <li>Update the <code>Heroku App URL</code> record in the Custom Metadata Type <code>Game Settings</code> with the Heroku App's URL generated in the previous step.</li>
    <li>Optionally checkout the source code for the app <a href="https://github.com/adityanaag3/planning-poker-heroku">here</a> to make modifications or test locally.</li>
</ol>

## Game Setup

### Creating a game

1. Create your own Card sets (if needed) by creating new records in the <b>Card Set</b> custom metadata type.
1. Enter the card values separated by a comma. Optionally you can add <code>?</code> and <code>Pass</code>.
1. Navigate to the Planning Poker Host App, and click on the Games tab.
1. Create a new Game by entering a name and optional description
1. In the "Game Data Sources" section on the Game detail page, select the source of your user stories. If you don't have an existing object where you store the user stories, you can use the "Backlog Item" object that is provided in this app. Here are the values you need to enter if you choose the "Backlog Item" object
    1. Name Field: User Story
    1. Description Field: Notes
    1. Consensus Stored In? : Consensus
    1. List View: All

### Hosting a game

1. To start hosting the app, navigate to the Host Planning Poker Tab
2. Select a Game, and click Launch
3. Share the Game Pin shown with the players and Wait for them to join.
4. Once they have joined, click on Start.
5. When the cards are hidden, Players who havent voted are shown in gray color. Whenever a player gives a response, the card's color changes. Once the cards are revealed, the responses are shown.
6. The Host Controls has the following buttons
    1. <b>Save Consensus</b> to save the consensus
    2. <b>Next Story</b> naviagtes to the next story from the list, and also refreshes the players screen with this story.
    3. <b>Reset Cards</b> deletes all the responses for the current story and forces the players to resubmit their vote.
    4. <b>End Game</b> ends the current game for the host and all participants. Once a game ends, it cannot be started again.

### Playing a game on Salesforce

1. Navigate to the Play Planning Poker app.
2. Enter the Game Key that the host gives you.
3. Once a user story is shown, click on a Card to cast your vote.
4. Once the host navigates to the next story, your screen refreshes automatically. If not, refresh your screen.

### Playing a game on Heroku

1. Navigate to the unique Game URL shared by the host.
2. Enter your name.
3. Once a user story is shown, click on a Card to cast your vote.
4. Once the host navigates to the next story, your screen refreshes automatically. If not, refresh your screen.

## Roadmap

-   Additional LWC Tests

## Building and contributing

If you want to build the project from sources and contribute, run `npm install` to install the project build tools.
