<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SetupUILanguage>
                <UILanguage>en-US</UILanguage>
            </SetupUILanguage>
            <InputLocale>en-US</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
        </component>
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DiskConfiguration>
                <Disk wcm:action="add">
					<DiskID>0</DiskID>
					<WillWipeDisk>true</WillWipeDisk>
					<CreatePartitions>
						<CreatePartition wcm:action="add">
							<Order>1</Order>
							<Type>EFI</Type>
							<Size>100</Size>
						</CreatePartition>
						<CreatePartition wcm:action="add">
							<Order>2</Order>
							<Type>MSR</Type>
							<Size>4096</Size>
						</CreatePartition>
						<CreatePartition wcm:action="add">
							<Order>3</Order>
							<Type>Primary</Type>
							<Extend>true</Extend>
						</CreatePartition>
					</CreatePartitions>
					<ModifyPartitions>
						<ModifyPartition wcm:action="add">
							<Order>1</Order>
							<PartitionID>1</PartitionID>
							<Label>System</Label>
							<Format>FAT32</Format>
						</ModifyPartition>
						<ModifyPartition wcm:action="add">
							<Order>2</Order>
							<PartitionID>3</PartitionID>
							<Label>Windows</Label>
							<Letter>C</Letter>
							<Format>NTFS</Format>
						</ModifyPartition>
					</ModifyPartitions>
				</Disk>
                <WillShowUI>OnError</WillShowUI>
            </DiskConfiguration>
            <UserData>
                <AcceptEula>true</AcceptEula>
                <ProductKey>
                    <WillShowUI>Never</WillShowUI>
                    <Key>W269N-WFGWX-YVC9B-4J6C9-T83GX</Key>
                </ProductKey>
            </UserData>
            <ImageInstall>
                <OSImage>
					<WillShowUI>OnError</WillShowUI>
					<InstallTo>
						<DiskID>0</DiskID>
						<PartitionID>3</PartitionID>
					</InstallTo>
					<InstallFrom>
						<Path>install.wim</Path>
						<MetaData>
							<Key>/IMAGE/NAME</Key>
							<Value>Windows 10 Pro</Value>
						</MetaData>
					</InstallFrom>
				</OSImage>
            </ImageInstall>
        </component>
    </settings>
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <TimeZone>Mountain Standard Time</TimeZone>
        </component>
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Description>disable product key request</Description>
                    <Order>1</Order>
                    <Path>reg add &quot;HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE&quot; /v SetupDisplayedProductKey /t REG_DWORD /d 1 /f</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
        <component name="Microsoft-Windows-TerminalServices-LocalSessionManager" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <fDenyTSConnections>false</fDenyTSConnections>
        </component>
        <component name="Networking-MPSSVC-Svc" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <FirewallGroups>
                <FirewallGroup wcm:action="add" wcm:keyValue="RemoteDesktop">
                    <Active>true</Active>
                    <Group>Remote Desktop</Group>
                    <Profile>all</Profile>
                </FirewallGroup>
            </FirewallGroups>
        </component>
        <component name="Microsoft-Windows-TerminalServices-RDP-WinStationExtensions" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SecurityLayer>2</SecurityLayer>
            <UserAuthentication>1</UserAuthentication>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <CommandLine>powershell -ExecutionPolicy Bypass -File a:\setup.ps1</CommandLine>
                    <Description>Enable WinRM service</Description>
                    <RequiresUserInput>true</RequiresUserInput>
                </SynchronousCommand>
            </FirstLogonCommands>
            <AutoLogon>
                <Password>
                    <Value>${winadmin_password}</Value>
                    <PlainText>false</PlainText>
                </Password>
                <Username>Administrator</Username>
                <Enabled>true</Enabled>
                <LogonCount>1</LogonCount>
            </AutoLogon>
            <UserAccounts>
                <AdministratorPassword>
                    <Value>${winadmin_password}</Value>
                    <PlainText>false</PlainText>
                </AdministratorPassword>
            </UserAccounts>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
            </OOBE>
        </component>
    </settings>
</unattend>