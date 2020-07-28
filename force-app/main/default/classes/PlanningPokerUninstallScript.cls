global class PlanningPokerUninstallScript implements UninstallHandler {
    global void onUninstall(UninstallContext ctx) {
        delete ([
            SELECT Id
            FROM PushTopic
            WHERE Name = 'GamePlayers' OR Name = 'PlayerResponses'
        ]);
    }
}
