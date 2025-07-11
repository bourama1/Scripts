@echo off
chcp 65001 > nul
TIMEOUT /T 10
start "" "D:\Aktuální SW\OPC Clienti\OPC_PLC0_Orezavacka_BezKepware\ToorsPLCClient.exe"
TIMEOUT /T 1
start "" "D:\Aktuální SW\OPC Clienti\OPC_PLC1_Plechy\ToorsOPCClient.exe"
TIMEOUT /T 1
start "" "D:\Aktuální SW\OPC Clienti\OPC_PLC1_Vstup\ToorsOPCClient.exe"
TIMEOUT /T 1
start "" "D:\Aktuální SW\OPC Clienti\OPC_PLC2_Vrtacka\ToorsOPCClient.exe"
TIMEOUT /T 1
start "" "D:\Aktuální SW\OPC Clienti\OPC_PLC3_Okna\ToorsOPCClient.exe"
TIMEOUT /T 1
start "" "D:\Aktuální SW\OPC Clienti\OPC_PLC3_vstup_CNC\ToorsOPCClient.exe"
TIMEOUT /T 1
start "" "D:\Aktuální SW\OPC Clienti\OPC_PLC4_Balirna\ToorsOPCClient.exe"
TIMEOUT /T 1
start "" "D:\Aktuální SW\OPC Clienti\OPC_PLC4_Balirna_Okna\ToorsOPCClient.exe"
TIMEOUT /T 1
start "" "D:\Aktuální SW\OPC Clienti\OPC_PLC4_Tesneni\ToorsOPCClient.exe"
TIMEOUT /T 1
powershell.exe -File "C:\Program Files\start_excel.ps1"