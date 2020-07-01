# Planning Poker App built on Salesforce

1. [About](#about)
1. [Installation](#installation)
1. [Building and contributing](#building-and-contributing)


## About

Planning poker is a consensus-based, gamified technique for estimating user stories in Scrum. 

## Installation

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
<p>Tip: you can also download the files from the website if you don't want to install git.</p>
    </li>
    <li><p>Run the installation script. The script deploys the Planning Poker App on a scratch org with a <code>planningpoker</code> alias.</p>
    <p>MacOS or Linux</p>
    <pre>sh scripts/setup/orgInit.sh </pre>
    <p>Windows</p>
    <pre>scripts/setup/orgInit-windows.bat</pre>
    <p>Once the script completes, it will open your new scratch org in a browser tab. If you close the tab or get disconnected, run this command to reopen the org <code>sfdx force:org:open -u planningpoker</code></p>
    </li>
    

## Building and contributing

If you want to build the project from sources and contribute, run `npm install` to install the project build tools.

