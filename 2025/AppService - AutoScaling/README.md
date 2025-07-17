# Auto-Scaling-Regeln als Code

Früher hab ich Ressourcen „für den Worst Case“ ausgelegt.

Heute schreibe ich lieber Terraform-Module, die Autoscaling in Azure sauber und mit echten Nutzungsdaten konfigurieren.

Beispiel: App Services, die nachts „schlafen“, weil’s keiner merkt, aber das Konto freut’s.

Was meine ich damit: je nach AppService Plan können die Ressourcen am Wochenende oder eben Nachts auf ein Minimum reduziert werden.

Zu bestimmten Zeiten werden diese wieder erweitert und können automatisch für Lastspitzen angepasst werden.

Das ganze funktioniert mit der Terraform azurerm_monitor_autoscale_setting Ressource.

Hier ein komplettes Beispiel, mit allem was nötig ist.
