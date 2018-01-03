# AzureOrphanResourceMonitor


0 10 * * * cat /var/www/html/azuremon/index.html  | mailx -a "Content-type: text/html;charset=utf-8" -s "Azure orphan resources alert" -r sender@maildomain recipient@maildomain
