# AzureOrphanResourceMonitor

This peace of code will draw a HTML page with a report of detached resources from Azure cloud with the az-cli command for removal and send it to your e-mail.


## Crontab configuration

```
0 10 * * * cat /var/www/html/azuremon/index.html  | mailx -a "Content-type: text/html;charset=utf-8" -s "Azure orphan resources alert" -r sender@maildomain recipient@maildomain
```
