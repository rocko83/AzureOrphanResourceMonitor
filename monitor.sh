#!/bin/bash -x
az login --service-principal  -u http://xxxxxxxxx -t xxxxxxxxxxxxxxxxxxxxxxx -p xxxxxxxxxxxxxxxxxxx 2>/dev/null > /dev/null
export PATHSCRIPT=/var/www/html
export CONTAINERREDIRECT=$PATHSCRIPT/container.html
export INDEXREDIRECT=$PATHSCRIPT/index.html
function Tempfunc() {
	case $1 in
	criar)
		mktemp -p /tmp --suffix azuremon
		;;
	apagar)
		rm  -f $2
		;;
	*)
		echo erro
		exit 1
		;;
	esac
}
function MON_NICS() {
  export TEMPFILE=$(Tempfunc criar)
  echo \<table class="GreenTable"\>
  echo \<thead\>
  echo \<tr\>
  echo \<th\>NIC Name\</th\>
  echo \<th\>NIC ID\</th\>
  echo \</tr\>
  echo \</thead\>
  echo \<tbody\>
  az network nic list --query "[?virtualMachine==null].[name,id]" -o tsv > $TEMPFILE
  while read NICNAME ID
  do
    echo \<tr\>
    echo \<td\>$NICNAME\</td\>
    echo \<td\>$ID\</td\>
    echo \</tr\>
  done < $TEMPFILE
  echo \</tbody\>
  echo \</table\>
  echo \<table class="RedTable"\>
  echo \<thead\>
  echo \<tr\>
  echo \<th\>NIC Name\</th\>
  echo \<th\>Comando para Deleção da NIC\</th\>
  echo \</tr\>
  echo \</thead\>
  echo \<tbody\>
  while read NICNAME ID
  do
    echo \<tr\>
    echo \<td\>$NICNAME\</td\>
    echo \<td\>az network nic delete --ids $ID -y \</td\>
    echo \</tr\>
  done < $TEMPFILE
  echo \</tbody\>
  echo \</table\>
  Tempfunc apagar $TEMPFILE
}
function MON_DISKS() {
  export TEMPFILE=$(Tempfunc criar)
  echo \<table class="YellowTable"\>
  echo \<thead\>
  echo \<tr\>
  echo \<th\>DiskName\</th\>
	echo \<th\>Disk Size GB\</th\>
	echo \<th\>ResourceGroup\</th\>
	echo \<th\>TimeCreated\</th\>
	echo \<th\>Disk ID\</th\>
  echo \</tr\>
  echo \</thead\>
  echo \<tbody\>
  az disk list --query "[?managedBy==null].[name,id,diskSizeGb,resourceGroup,timeCreated]" -o tsv > $TEMPFILE
  while read DISKNAME ID DISKSIZEGB RESOURCEGROUP TIMECREATED
  do
    echo \<tr\>
    echo \<td\>$DISKNAME\</td\>
		echo \<td\>$DISKSIZEGB\</td\>
		echo \<td\>$RESOURCEGROUP\</td\>
		echo \<td\>$TIMECREATED\</td\>
		echo \<td\>$ID\</td\>
    echo \</tr\>
  done < $TEMPFILE
  echo \</tbody\>
  echo \</table\>
  echo \<table class="RedTable"\>
  echo \<thead\>
  echo \<tr\>
  echo \<th\>DiskName\</th\>
  echo \<th\>Comando para Deleção do Disco\</th\>
  echo \</tr\>
  echo \</thead\>
  echo \<tbody\>
  while read DISKNAME ID DISKSIZEGB RESOURCEGROUP TIMECREATED
  do
    echo \<tr\>
    echo \<td\>$DISKNAME\</td\>
    echo \<td\>az disk delete --ids $ID -y \</td\>
    echo \</tr\>
  done < $TEMPFILE
  echo \</tbody\>
  echo \</table\>
  Tempfunc apagar $TEMPFILE
}
function MON_DISKS_SNAPSHOTS() {
	export TEMPFILE=$(Tempfunc criar)
	echo \<table class="blueTable"\>
	echo \<thead\>
	echo \<tr\>
	echo \<th\>SnapShot Name\</th\>
	echo \<th\>SnapShot ID\</th\>
	echo \<th\>diskSizeGb\</th\>
	echo \<th\>location\</th\>
	echo \<th\>resourceGroup\</th\>
	echo \</tr\>
	echo \</thead\>
	echo \<tbody\>
	az snapshot list  --query "[].[name,id,diskSizeGb,location,resourceGroup]" -o tsv > $TEMPFILE
	while read NAME ID DISKSIZE LOCATION RESORUCEGROUP
	do
		echo \<tr\>
		echo \<td\>$NAME\</td\>
		echo \<td\>$ID\</td\>
		echo \<td\>$DISKSIZE\</td\>
		echo \<td\>$LOCATION\</td\>
		echo \<td\>$RESORUCEGROUP\</td\>
		echo \</tr\>
	done < $TEMPFILE
	echo \</tbody\>
	echo \</table\>
	echo \<table class="RedTable"\>
	echo \<thead\>
	echo \<tr\>
	echo \<th\>SnapShot Name\</th\>
	echo \<th\>Comando para apagar SnapShot\</th\>
	echo \</tr\>
	echo \</thead\>
	echo \<tbody\>
	while read NAME ID DISKSIZE LOCATION RESORUCEGROUP
	do
		echo \<tr\>
		echo \<td\>$NAME\</td\>
		echo \<td\>az snapshot delete --ids $ID\</td\>
		echo \</tr\>
	done < $TEMPFILE
	echo \</tbody\>
	echo \</table\>
	Tempfunc apagar $TEMPFILE
}
function MON_VMS_OFF() {
	export TEMPFILE=$(Tempfunc criar)

  az vm list -d --query "[?powerState=='VM stopped'].[name,id,hardwareProfile.vmSize,resourceGroup,location,powerState]" -o tsv > $TEMPFILE
	RETORNO=$(wc -l $TEMPFILE | awk '{print $1}')
	if [ $RETORNO -ne 0 ]
	then
		echo \<table class="blueTable"\>
	  echo \<thead\>
	  echo \<tr\>
	  echo \<th\>VMNAME Name\</th\>
	  echo \<th\>VMNAME ID\</th\>
		echo \<th\>VMSIZE\</th\>
		echo \<th\>RESOURCEGROUP\</th\>
		echo \<th\>LOCATION\</th\>
		echo \<th\>POWERSTATE\</th\>
	  echo \</tr\>
	  echo \</thead\>
	  echo \<tbody\>
	  while read VMNAME ID VMSIZE RESOURCEGROUP LOCATION POWERSTATE
	  do
	    echo \<tr\>
	    echo \<td\>$VMNAME\</td\>
	    echo \<td\>$ID\</td\>
			echo \<td\>$VMSIZE\</td\>
			echo \<td\>$RESOURCEGROUP\</td\>
			echo \<td\>$LOCATION\</td\>
			echo \<td\>$POWERSTATE\</td\>
	    echo \</tr\>
	  done < $TEMPFILE
	  echo \</tbody\>
	  echo \</table\>

	else
		echo $TAG_CENTER Não há VMs desligadas e não desalocadas. $TAG_CENTERF
	fi
	az vm list -d --query "length([?powerState=='VM deallocated'])" -o tsv > $TEMPFILE
	echo \<table class="RedTable"\>
	echo \<thead\>
	echo \<tr\>
	echo \<th\>Quantidade de VMs desligas e desalocadas\</th\>
	echo \</tr\>
	echo \</thead\>
	echo \<tbody\>
  while read QUANTIDADE
  do
    echo \<tr\>
    echo \<td\>$QUANTIDADE\</td\>
    echo \</tr\>
  done < $TEMPFILE
  echo \</tbody\>
  echo \</table\>
  Tempfunc apagar $TEMPFILE
}
function MON_CONTAINERS() {
	export TEMPFILE=$(Tempfunc criar)
	export TOPICO="Monitor de Recursos Ociosos<br>$(date)"
	HTML_OPEN > $CONTAINERREDIRECT
	export TOPICO="StorageContainers"
	export MENSAGEM="Recursos alocados em StorageContainers"
	HTML_TOPICO >> $CONTAINERREDIRECT
  echo \<table class="GreenTable"\> >> $CONTAINERREDIRECT
  echo \<thead\> >> $CONTAINERREDIRECT
  echo \<tr\> >> $CONTAINERREDIRECT
  echo \<th\>Storage Name\</th\> >> $CONTAINERREDIRECT
  echo \<th\>Container Name\</th\> >> $CONTAINERREDIRECT
	echo \<th\>Blob Name\</th\> >> $CONTAINERREDIRECT
	echo \<th\>Blob Lenght\</th\> >> $CONTAINERREDIRECT
	echo \<th\>Blob Type\</th\> >> $CONTAINERREDIRECT
	echo \<th\>Blob LastModified\</th\> >> $CONTAINERREDIRECT
	echo \<th\>Storage Location\</th\> >> $CONTAINERREDIRECT
	echo \<th\>Storage ResourceGroup\</th\> >> $CONTAINERREDIRECT
  echo \</tr\> >> $CONTAINERREDIRECT
  echo \</thead\> >> $CONTAINERREDIRECT
  echo \<tbody\> >> $CONTAINERREDIRECT
	az storage account list --query "[][id,name,location,resourceGroup]" -o tsv | \
	while read STORID STORNAME STORLOCATION STORRG
	do
		az storage account show-connection-string --ids "$STORID" -o tsv | \
		while read STORCS
		do
			az storage container list --connection-string "$STORCS" --query "[].name" -o tsv | \
			while read ACCOUNTNAME
			do

				az storage blob list -c $ACCOUNTNAME --connection-string "$STORCS" --query "[].[name,properties.contentLength,properties.lastModified,properties.contentSettings.contentType]" -o tsv | \
				while read BLOBNAME BLOBCL BLOBLASTMODIFIED BLOBTYPE
				do
					echo \<tr\> >> $CONTAINERREDIRECT
			    echo \<td\>$STORNAME\</td\> >> $CONTAINERREDIRECT
			    echo \<td\>$ACCOUNTNAME\</td\> >> $CONTAINERREDIRECT
					echo \<td\>$BLOBNAME\</td\> >> $CONTAINERREDIRECT
					echo \<td\>$BLOBCL\</td\> >> $CONTAINERREDIRECT
					echo \<td\>$BLOBTYPE\</td\> >> $CONTAINERREDIRECT
					echo \<td\>$BLOBLASTMODIFIED\</td\> >> $CONTAINERREDIRECT
					echo \<td\>$STORLOCATION\</td\> >> $CONTAINERREDIRECT
					echo \<td\>$STORRG\</td\> >> $CONTAINERREDIRECT
			    echo \</tr\> >> $CONTAINERREDIRECT
					echo $STORNAME $ACCOUNTNAME $BLOBCL >> $TEMPFILE
				done
			done
		done
	done
  echo \</tbody\> >> $CONTAINERREDIRECT
  echo \</table\> >> $CONTAINERREDIRECT
	HTML_CLOSE >> $CONTAINERREDIRECT
	echo \<table class="YellowTable"\>  >> $INDEXREDIRECT
  echo \<thead\> >> $INDEXREDIRECT
  echo \<tr\> >> $INDEXREDIRECT
  echo \<th\>Storage Name\</th\> >> $INDEXREDIRECT
  echo \<th\>Container Name\</th\> >> $INDEXREDIRECT
	echo \<th\>Size \(GBytes\)\</th\> >> $INDEXREDIRECT
  echo \</tr\> >> $INDEXREDIRECT
  echo \</thead\> >> $INDEXREDIRECT
  echo \<tbody\> >> $INDEXREDIRECT
	cat $TEMPFILE | \
	awk '{print $1}' | \
	sort -u | \
	while read STORNAME
	do
		grep ^$STORNAME  $TEMPFILE | \
		awk '{print $2}' | \
		sort -u | \
		while read ACCOUNTNAME
		do
			echo \<tr\> >> $INDEXREDIRECT
			echo \<td\>$STORNAME\</td\> \<td\>$ACCOUNTNAME\</td\>\<td\>$(grep "^$STORNAME $ACCOUNTNAME" $TEMPFILE | awk '{s = s + $3} END {print s/1024^3}')\</td\> >> $INDEXREDIRECT
			echo \</tr\> >> $INDEXREDIRECT
		done
	done
	echo \</tbody\> >> $INDEXREDIRECT
  echo \</table\> >> $INDEXREDIRECT
  Tempfunc apagar $TEMPFILE
	#echo $TEMPFILE
}
function HTML_OPEN() {
  echo \<!DOCTYPE html\>
  echo \<html\>
  echo \<head\>
  echo \<style media="screen" type="text/css"\>
  #cat /var/www/html/azuremon/resourceMonitor.css
  cat $PATHSCRIPT/resourceMonitor.css
  echo \</style\>
  echo \<meta\>
  echo \<meta http-equiv="refresh" content="900" \>
  echo \<title\>$TOPICO\</title\>
  echo \<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /\>
  echo \</meta\>
  echo \</head\>
  echo \<body\>
  echo \<center\>\<h1\>$TOPICO\</h1\>\</center\>
}
function HTML_CLOSE() {
  echo \</body\>
  echo \</html\>
}
function HTML_TOPICO() {
  echo $TAG_CENTER $TAG_H2 $TOPICO $TAG_H2F $TAG_CENTERF
  echo $MENSAGEM
}
function MAIL_SEND() {
  echo $0
}
########TAGS HTML ##################
export TAG_CENTER=\<center\>
export TAG_CENTERF=\<center\>
export TAG_H2=\<h2\>
export TAG_H2F=\</h2\>
#######EXECUCAO PRINCIPAL DO CODIGO#############
export TOPICO="Monitor de Recursos Ociosos<br>$(date)"
HTML_OPEN > $INDEXREDIRECT
export TOPICO="Monitor de Disco"
export MENSAGEM="Relação de discos criados e não alocados na Azure."
HTML_TOPICO >> $INDEXREDIRECT
#MON_DISKS >> $INDEXREDIRECT
export TOPICO="Monitor de Snapshot"
export MENSAGEM="Lista de snapshots criados"
HTML_TOPICO >> $INDEXREDIRECT
#MON_DISKS_SNAPSHOTS >> $INDEXREDIRECT
export TOPICO="Monitor de NetworkInterface"
export MENSAGEM="Lista de interfaces de rede criadas e não alocadas"
HTML_TOPICO >> $INDEXREDIRECT
#MON_NICS >> $INDEXREDIRECT
export TOPICO="StorageContainers"
export MENSAGEM="Recursos alocados em StorageContainers.<br>Para acessar a lista completa de objetos clique <a href=container.html>aqui</a>."
HTML_TOPICO >> $INDEXREDIRECT
MON_CONTAINERS
export TOPICO="Monitor de VirtualMachine"
export MENSAGEM="Relação de virtual machines desligadas e não desalocadas"
HTML_TOPICO >> $INDEXREDIRECT
#MON_VMS_OFF >> $INDEXREDIRECT
export TOPICO=""
export MENSAGEM="Última coleta em:$(date)"
HTML_TOPICO >> $INDEXREDIRECT
HTML_CLOSE >> $INDEXREDIRECT
