# Windows Packer
The scripts in this repo use Packer (open source, licensed under Mozilla Public License 2.0) to build a set of Windows templates in vSphere.  Each template has an individual sub directory.   It uses the build-all.ps1 script to build the variable files and Autounattend.xml files for each image.  The templates are built simultaneously using the Autounattend.xml files along with some setup scripts to install VMware Tools, OS updates, harden for security, and install Cloudbase-init.  Cloudbase-init is used for customization and the templates are intended to be deployed with Aria Automation.

---

## Third-Party Dependencies

This project uses the following third-party tools:

- **Packer** (Mozilla Public License 2.0) - Machine image creation tool by HashiCorp
- **VMware Tools** - VMware-provided utilities (proprietary, included with VMware products)
- **Cloudbase-init** (Apache-2.0 License) - Cloud initialization tool for Windows

### Third-Party Scripts

- **updateAndHarden.ps1** - SSL/TLS hardening script by Alexander Hass (Copyright 2019, Alexander Hass)
  - Source: https://www.hass.de/content/setup-microsoft-windows-or-iis-ssl-perfect-forward-secrecy-and-tls-12
  - This script is included in `common/scripts/updateAndHarden.ps1` with the original copyright notice preserved.

Please refer to each tool's license for specific terms and conditions.

Also see the below wiki for more details.
[Documentation link - update with your organization's wiki]

## Prerequisites
Powershell 7.5 or 
Packer 1.14.1 or Greater
vCenter Server 8.0 or Greater
.ISO files for all Windows images


## Local Setup for Testing Instructions
1. Grab Packer install file from https://developer.hashicorp.com/packer/install
2. Add the executable to your PATH environment variable
3. Clone the GitHub Repo
```
git clone https://github.com/andrewtamagni/windows-packer.git
```

## Packer Build Instructions
1. Create a .env file with all the required variables based on .env.example
	- `iso_path_winserv2025stan`
	- `iso_path_winserv2022stan`
	- `iso_path_win10pro22h2`
	- `iso_path_win11pro24h2`
	- `desk_cpu_num`
	- `desk_disk_size`
	- `desk_mem_size`
	- `serv_cpu_num`
	- `serv_disk_size`
	- `serv_mem_size`
	- `vsphere_compute_cluster`
	- `vsphere_datastore`
	- `vsphere_dc_name`
	- `vsphere_folder`
	- `vsphere_server`
	- `vsphere_portgroup_name`
	- `vsphere_user`
	- `vsphere_password`
	- `winadmin_password`
	- `vm_disk_controller_type`
2. Run the build command
	- Build all templates at the same time from windows-packer directory.
	```
	.\build-all.ps1
	```
	- Build one at a time from a single template directory
	```
	..\env-to-vars.ps1
	packer init .
	packer build -var-file="packer.auto.pkrvars.hcl" "win11pro24h2.pkr.hcl"
	```

## Example Output
The output will only show one build at a time initially, but will show all builds upon completion.
```
PS C:\Users\andrewta\Documents\Github\windows-packer> .\build-all.ps1

==== Output from Win11Pro24H2 ====

[C:\Users\andrewta\Documents\Github\windows-packer\Win11Pro24H2] Starting build...
[C:\Users\andrewta\Documents\Github\windows-packer\Win11Pro24H2] Removed existing packer.auto.pkrvars.hcl
Reading variables from ..\.env...
Generated vsphere_template_name = win11pro24h2-20250806
Added os_iso_path = [nwsc_vm_install] Aria Images/Windows/SW_DVD9_Win_Pro_11_24H2.9_64BIT_English_Pro_Ent_EDU_N_MLF_X24-08654.ISO
Writing to .\packer.auto.pkrvars.hcl...
packer build -var-file=packer.auto.pkrvars.hcl .
[C:\Users\andrewta\Documents\Github\windows-packer\Win11Pro24H2] Rendered Autounattend.xml
[C:\Users\andrewta\Documents\Github\windows-packer\Win11Pro24H2] Starting packer build...
vsphere-iso.win11pro24h2: output will be in this color.

==> vsphere-iso.win11pro24h2: Creating virtual machine...
==> vsphere-iso.win11pro24h2: Customizing hardware...
==> vsphere-iso.win11pro24h2: Mounting ISO images...
==> vsphere-iso.win11pro24h2: Adding configuration parameters...
==> vsphere-iso.win11pro24h2: Creating floppy disk...
==> vsphere-iso.win11pro24h2: Copying files flatly from floppy_files
==> vsphere-iso.win11pro24h2: Copying file: ./Autounattend.xml
==> vsphere-iso.win11pro24h2: Copying file: ./../common/scripts/setup.ps1
==> vsphere-iso.win11pro24h2: Done copying files from floppy_files
==> vsphere-iso.win11pro24h2: Collecting paths from floppy_dirs
==> vsphere-iso.win11pro24h2: Resulting paths from floppy_dirs : []
==> vsphere-iso.win11pro24h2: Done copying paths from floppy_dirs
==> vsphere-iso.win11pro24h2: Copying files from floppy_content
==> vsphere-iso.win11pro24h2: Done copying files from floppy_content
==> vsphere-iso.win11pro24h2: Uploading floppy image...
==> vsphere-iso.win11pro24h2: Adding generated floppy image...
==> vsphere-iso.win11pro24h2: Setting temporary boot order...
==> vsphere-iso.win11pro24h2: Powering on virtual machine...
==> vsphere-iso.win11pro24h2: Waiting 3s for boot...
==> vsphere-iso.win11pro24h2: Typing boot command...
==> vsphere-iso.win11pro24h2: Waiting for IP...
==> vsphere-iso.win11pro24h2: IP address: xx.xx.xx.xx
==> vsphere-iso.win11pro24h2: Using WinRM communicator to connect: xx.xx.xx.xx
==> vsphere-iso.win11pro24h2: Waiting for WinRM to become available...
==> vsphere-iso.win11pro24h2: WinRM connected.
==> vsphere-iso.win11pro24h2: Connected to WinRM!
==> vsphere-iso.win11pro24h2: Restarting Machine
==> vsphere-iso.win11pro24h2: Waiting for machine to restart...
==> vsphere-iso.win11pro24h2: A system shutdown is in progress.(1115)
==> vsphere-iso.win11pro24h2: DESKTOP-RP48JRB restarted.
==> vsphere-iso.win11pro24h2: Machine successfully restarted, moving on
==> vsphere-iso.win11pro24h2: Uploading ../common/scripts/updateAndHarden.ps1 => C:/Windows/Temp/updateAndHarden.ps1
==> vsphere-iso.win11pro24h2: Uploading ../common/scripts/installCloudbaseInit.ps1 => C:/Windows/Temp/installCloudbaseInit.ps1
==> vsphere-iso.win11pro24h2: Provisioning with Powershell...
==> vsphere-iso.win11pro24h2: Provisioning with powershell script: C:\Users\andrewta\AppData\Local\Temp\powershell-provisioner254534292
==> vsphere-iso.win11pro24h2: Configuring IIS with SSL/TLS Deployment Best Practices...
==> vsphere-iso.win11pro24h2: --------------------------------------------------------------------------------
==> vsphere-iso.win11pro24h2: Multi-Protocol Unified Hello has been disabled.
==> vsphere-iso.win11pro24h2: PCT 1.0 has been disabled.
==> vsphere-iso.win11pro24h2: SSL 2.0 has been disabled.
==> vsphere-iso.win11pro24h2: SSL 3.0 has been disabled.
==> vsphere-iso.win11pro24h2: TLS 1.0 has been disabled.
==> vsphere-iso.win11pro24h2: TLS 1.1 has been disabled.
==> vsphere-iso.win11pro24h2: TLS 1.2 has been enabled.
==> vsphere-iso.win11pro24h2: Weak cipher DES 56/56 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher NULL has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC2 128/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC2 40/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC2 56/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 40/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 56/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 64/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 128/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher Triple DES 168 has been disabled.
==> vsphere-iso.win11pro24h2: Strong cipher AES 128/128 has been enabled.
==> vsphere-iso.win11pro24h2: Strong cipher AES 256/256 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA256 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA384 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA512 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA has been disabled.
==> vsphere-iso.win11pro24h2: Hash MD5 has been disabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm Diffie-Hellman has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm ECDH has been enabled.
==> vsphere-iso.win11pro24h2: TLS 1.0 has been disabled.
==> vsphere-iso.win11pro24h2: TLS 1.1 has been disabled.
==> vsphere-iso.win11pro24h2: TLS 1.2 has been enabled.
==> vsphere-iso.win11pro24h2: Weak cipher DES 56/56 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher NULL has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC2 128/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC2 40/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC2 56/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 40/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 56/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 64/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 128/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher Triple DES 168 has been disabled.
==> vsphere-iso.win11pro24h2: Strong cipher AES 128/128 has been enabled.
==> vsphere-iso.win11pro24h2: Strong cipher AES 256/256 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA256 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA384 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA512 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA has been disabled.
==> vsphere-iso.win11pro24h2: Hash MD5 has been disabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm Diffie-Hellman has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm ECDH has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm PKCS has been enabled.
==> vsphere-iso.win11pro24h2: Weak cipher DES 56/56 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher NULL has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC2 128/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC2 40/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC2 56/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 40/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 56/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 64/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 128/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher Triple DES 168 has been disabled.
==> vsphere-iso.win11pro24h2: Strong cipher AES 128/128 has been enabled.
==> vsphere-iso.win11pro24h2: Strong cipher AES 256/256 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA256 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA384 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA512 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA has been disabled.
==> vsphere-iso.win11pro24h2: Hash MD5 has been disabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm Diffie-Hellman has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm ECDH has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm PKCS has been enabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC2 40/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC2 56/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 40/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 56/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 64/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher RC4 128/128 has been disabled.
==> vsphere-iso.win11pro24h2: Weak cipher Triple DES 168 has been disabled.
==> vsphere-iso.win11pro24h2: Strong cipher AES 128/128 has been enabled.
==> vsphere-iso.win11pro24h2: Strong cipher AES 256/256 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA256 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA384 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA512 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA has been disabled.
==> vsphere-iso.win11pro24h2: Hash MD5 has been disabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm Diffie-Hellman has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm ECDH has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm PKCS has been enabled.
==> vsphere-iso.win11pro24h2: Strong cipher AES 128/128 has been enabled.
==> vsphere-iso.win11pro24h2: Strong cipher AES 256/256 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA256 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA384 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA512 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA has been disabled.
==> vsphere-iso.win11pro24h2: Hash MD5 has been disabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm Diffie-Hellman has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm ECDH has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm PKCS has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA384 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA512 has been enabled.
==> vsphere-iso.win11pro24h2: Hash SHA has been disabled.
==> vsphere-iso.win11pro24h2: Hash MD5 has been disabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm Diffie-Hellman has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm ECDH has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm PKCS has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm Diffie-Hellman has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm ECDH has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm PKCS has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm ECDH has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm PKCS has been enabled.
==> vsphere-iso.win11pro24h2: KeyExchangeAlgorithm PKCS has been enabled.
==> vsphere-iso.win11pro24h2: Configure longer DHE key shares for TLS servers.
==> vsphere-iso.win11pro24h2: SMB Secure Client Signing has been enabled.
==> vsphere-iso.win11pro24h2: SMB Secure Server Signing has been enabled
==> vsphere-iso.win11pro24h2: Enable TLS 1.2 for .NET 3.5 and .NET 4.x
==> vsphere-iso.win11pro24h2: $defaultSecureProtocolsSum =  2048
==> vsphere-iso.win11pro24h2: Enable NLA for Remote Desktop connections
==> vsphere-iso.win11pro24h2: Require high level encryption for Remote Desktop sessions
==> vsphere-iso.win11pro24h2: A computer restart is required to apply settings. Will restart after OS updates.
==> vsphere-iso.win11pro24h2:
==> vsphere-iso.win11pro24h2: Name                     Version          DynamicOptions
==> vsphere-iso.win11pro24h2: ----                     -------          --------------
==> vsphere-iso.win11pro24h2: NuGet                    2.8.5.208        Destination, ExcludeVersion, Scope, SkipDependencies, Headers, FilterOnTag...
==> vsphere-iso.win11pro24h2: Installing Windows updates...
==> vsphere-iso.win11pro24h2: Reboot is required, but do it manually.
==> vsphere-iso.win11pro24h2:
==> vsphere-iso.win11pro24h2:
==> vsphere-iso.win11pro24h2:
==> vsphere-iso.win11pro24h2: Restarting Machine
==> vsphere-iso.win11pro24h2: Waiting for machine to restart...
==> vsphere-iso.win11pro24h2: A system shutdown is in progress.(1115)
==> vsphere-iso.win11pro24h2: A system shutdown is in progress.(1115)
==> vsphere-iso.win11pro24h2: DESKTOP-RP48JRB restarted.
==> vsphere-iso.win11pro24h2: Machine successfully restarted, moving on
==> vsphere-iso.win11pro24h2: Provisioning with Powershell...
==> vsphere-iso.win11pro24h2: Provisioning with powershell script: C:\Users\andrewta\AppData\Local\Temp\powershell-provisioner858723074
==> vsphere-iso.win11pro24h2: Downloaded Cloudbase-Init.
==> vsphere-iso.win11pro24h2: Installed Cloudbase-Init.
==> vsphere-iso.win11pro24h2: Added to cloudbase-init.conf: first_logon_behaviour=no
==> vsphere-iso.win11pro24h2: Added to cloudbase-init.conf: metadata_services=cloudbaseinit.metadata.services.ovfservice.OvfService
==> vsphere-iso.win11pro24h2: Added to cloudbase-init.conf: plugins=cloudbaseinit.plugins.windows.createuser.CreateUserPlugin,cloudbaseinit.plugins.windows.setuserpassword.SetUserPasswordPlugin,cloudbaseinit.plugins.common.sshpublickeys.SetUserSSHPublicKeysPlugin,cloudbaseinit.plugins.common.userdata.UserDataPlugin,cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin
==> vsphere-iso.win11pro24h2: Replaced or added metadata_services in cloudbase-init-unattend.conf
==> vsphere-iso.win11pro24h2:
==> vsphere-iso.win11pro24h2: Uploading ../common/Unattend.xml => C:/Windows/System32/Sysprep/Unattend.xml
==> vsphere-iso.win11pro24h2: Provisioning with Powershell...
==> vsphere-iso.win11pro24h2: Provisioning with powershell script: C:\Users\andrewta\AppData\Local\Temp\powershell-provisioner3078241737
==> vsphere-iso.win11pro24h2:
==> vsphere-iso.win11pro24h2: Shutting down virtual machine...
==> vsphere-iso.win11pro24h2: Deleting floppy drives...
==> vsphere-iso.win11pro24h2: Deleting floppy image...
==> vsphere-iso.win11pro24h2: Ejecting CD-ROM media...
==> vsphere-iso.win11pro24h2: Converting virtual machine to template...
==> vsphere-iso.win11pro24h2: Clearing boot order...
==> vsphere-iso.win11pro24h2: Closing sessions ....
Build 'vsphere-iso.win11pro24h2' finished after 49 minutes 20 seconds.

==> Wait completed after 49 minutes 20 seconds

==> Builds finished. The artifacts of successful builds are:
--> vsphere-iso.win11pro24h2: win11pro24h2-20250806

==== Output from WinServ2022Stan ====

[C:\Users\andrewta\Documents\Github\windows-packer\WinServ2022Stan] Starting build...
[C:\Users\andrewta\Documents\Github\windows-packer\WinServ2022Stan] Removed existing packer.auto.pkrvars.hcl
Reading variables from ..\.env...
Generated vsphere_template_name = winserv2022stan-20250806
Added os_iso_path = [nwsc_vm_install] Aria Images/Windows/SW_DVD9_Win_Server_STD_CORE_2022_2108.39_64Bit_English_DC_STD_MLF_X23-89848.ISO
Writing to .\packer.auto.pkrvars.hcl...
packer build -var-file=packer.auto.pkrvars.hcl .
[C:\Users\andrewta\Documents\Github\windows-packer\WinServ2022Stan] Rendered Autounattend.xml
[C:\Users\andrewta\Documents\Github\windows-packer\WinServ2022Stan] Starting packer build...
vsphere-iso.winserv2022stan: output will be in this color.

==> vsphere-iso.winserv2022stan: Creating virtual machine...
==> vsphere-iso.winserv2022stan: Customizing hardware...
==> vsphere-iso.winserv2022stan: Mounting ISO images...
==> vsphere-iso.winserv2022stan: Adding configuration parameters...
==> vsphere-iso.winserv2022stan: Creating floppy disk...
==> vsphere-iso.winserv2022stan: Copying files flatly from floppy_files
==> vsphere-iso.winserv2022stan: Copying file: ./Autounattend.xml
==> vsphere-iso.winserv2022stan: Copying file: ./../common/scripts/setup.ps1
==> vsphere-iso.winserv2022stan: Done copying files from floppy_files
==> vsphere-iso.winserv2022stan: Collecting paths from floppy_dirs
==> vsphere-iso.winserv2022stan: Resulting paths from floppy_dirs : []
==> vsphere-iso.winserv2022stan: Done copying paths from floppy_dirs
==> vsphere-iso.winserv2022stan: Copying files from floppy_content
==> vsphere-iso.winserv2022stan: Done copying files from floppy_content
==> vsphere-iso.winserv2022stan: Uploading floppy image...
==> vsphere-iso.winserv2022stan: Adding generated floppy image...
==> vsphere-iso.winserv2022stan: Setting temporary boot order...
==> vsphere-iso.winserv2022stan: Powering on virtual machine...
==> vsphere-iso.winserv2022stan: Waiting 3s for boot...
==> vsphere-iso.winserv2022stan: Typing boot command...
==> vsphere-iso.winserv2022stan: Waiting for IP...
==> vsphere-iso.winserv2022stan: IP address: xx.xx.xx.xx
==> vsphere-iso.winserv2022stan: Using WinRM communicator to connect: xx.xx.xx.xx
==> vsphere-iso.winserv2022stan: Waiting for WinRM to become available...
==> vsphere-iso.winserv2022stan: WinRM connected.
==> vsphere-iso.winserv2022stan: Connected to WinRM!
==> vsphere-iso.winserv2022stan: Restarting Machine
==> vsphere-iso.winserv2022stan: Waiting for machine to restart...
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: WIN-UK7U4JJ6HP4 restarted.
==> vsphere-iso.winserv2022stan: Machine successfully restarted, moving on
==> vsphere-iso.winserv2022stan: Uploading ../common/scripts/updateAndHarden.ps1 => C:/Windows/Temp/updateAndHarden.ps1
==> vsphere-iso.winserv2022stan: Uploading ../common/scripts/installCloudbaseInit.ps1 => C:/Windows/Temp/installCloudbaseInit.ps1
==> vsphere-iso.winserv2022stan: Provisioning with Powershell...
==> vsphere-iso.winserv2022stan: Provisioning with powershell script: C:\Users\andrewta\AppData\Local\Temp\powershell-provisioner2417927220
==> vsphere-iso.winserv2022stan: Configuring IIS with SSL/TLS Deployment Best Practices...
==> vsphere-iso.winserv2022stan: --------------------------------------------------------------------------------
==> vsphere-iso.winserv2022stan: Multi-Protocol Unified Hello has been disabled.
==> vsphere-iso.winserv2022stan: PCT 1.0 has been disabled.
==> vsphere-iso.winserv2022stan: SSL 2.0 has been disabled.
==> vsphere-iso.winserv2022stan: SSL 3.0 has been disabled.
==> vsphere-iso.winserv2022stan: TLS 1.0 has been disabled.
==> vsphere-iso.winserv2022stan: TLS 1.1 has been disabled.
==> vsphere-iso.winserv2022stan: TLS 1.2 has been enabled.
==> vsphere-iso.winserv2022stan: Weak cipher DES 56/56 has been disabled.
==> vsphere-iso.winserv2022stan: Weak cipher NULL has been disabled.
==> vsphere-iso.winserv2022stan: Weak cipher RC2 128/128 has been disabled.
==> vsphere-iso.winserv2022stan: Weak cipher RC2 40/128 has been disabled.
==> vsphere-iso.winserv2022stan: Weak cipher RC2 56/128 has been disabled.
==> vsphere-iso.winserv2022stan: Weak cipher RC4 40/128 has been disabled.
==> vsphere-iso.winserv2022stan: Weak cipher RC4 56/128 has been disabled.
==> vsphere-iso.winserv2022stan: Weak cipher RC4 64/128 has been disabled.
==> vsphere-iso.winserv2022stan: Weak cipher RC4 128/128 has been disabled.
==> vsphere-iso.winserv2022stan: Weak cipher Triple DES 168 has been disabled.
==> vsphere-iso.winserv2022stan: Strong cipher AES 128/128 has been enabled.
==> vsphere-iso.winserv2022stan: Strong cipher AES 256/256 has been enabled.
==> vsphere-iso.winserv2022stan: Hash SHA256 has been enabled.
==> vsphere-iso.winserv2022stan: Hash SHA384 has been enabled.
==> vsphere-iso.winserv2022stan: Hash SHA512 has been enabled.
==> vsphere-iso.winserv2022stan: Hash SHA has been disabled.
==> vsphere-iso.winserv2022stan: Hash MD5 has been disabled.
==> vsphere-iso.winserv2022stan: KeyExchangeAlgorithm Diffie-Hellman has been enabled.
==> vsphere-iso.winserv2022stan: KeyExchangeAlgorithm ECDH has been enabled.
==> vsphere-iso.winserv2022stan: KeyExchangeAlgorithm PKCS has been enabled.
==> vsphere-iso.winserv2022stan: Configure longer DHE key shares for TLS servers.
==> vsphere-iso.winserv2022stan: SMB Secure Client Signing has been enabled.
==> vsphere-iso.winserv2022stan: SMB Secure Server Signing has been enabled
==> vsphere-iso.winserv2022stan: Enable TLS 1.2 for .NET 3.5 and .NET 4.x
==> vsphere-iso.winserv2022stan: $defaultSecureProtocolsSum =  2048
==> vsphere-iso.winserv2022stan: Enable NLA for Remote Desktop connections
==> vsphere-iso.winserv2022stan: Require high level encryption for Remote Desktop sessions
==> vsphere-iso.winserv2022stan: A computer restart is required to apply settings. Will restart after OS updates.
==> vsphere-iso.winserv2022stan:
==> vsphere-iso.winserv2022stan: Name                     Version          DynamicOptions
==> vsphere-iso.winserv2022stan: ----                     -------          --------------
==> vsphere-iso.winserv2022stan: NuGet                    2.8.5.208        Destination, ExcludeVersion, Scope, SkipDependencies, Headers, FilterOnTag...
==> vsphere-iso.winserv2022stan: Installing Windows updates...
==> vsphere-iso.winserv2022stan: Reboot is required, but do it manually.
==> vsphere-iso.winserv2022stan:
==> vsphere-iso.winserv2022stan:
==> vsphere-iso.winserv2022stan:
==> vsphere-iso.winserv2022stan: Restarting Machine
==> vsphere-iso.winserv2022stan: Waiting for machine to restart...
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2022stan: WIN-UK7U4JJ6HP4 restarted.
==> vsphere-iso.winserv2022stan: Machine successfully restarted, moving on
==> vsphere-iso.winserv2022stan: Provisioning with Powershell...
==> vsphere-iso.winserv2022stan: Provisioning with powershell script: C:\Users\andrewta\AppData\Local\Temp\powershell-provisioner1607971576
==> vsphere-iso.winserv2022stan: Downloaded Cloudbase-Init.
==> vsphere-iso.winserv2022stan: Installed Cloudbase-Init.
==> vsphere-iso.winserv2022stan: Added to cloudbase-init.conf: first_logon_behaviour=no
==> vsphere-iso.winserv2022stan: Added to cloudbase-init.conf: metadata_services=cloudbaseinit.metadata.services.ovfservice.OvfService
==> vsphere-iso.winserv2022stan: Added to cloudbase-init.conf: plugins=cloudbaseinit.plugins.windows.createuser.CreateUserPlugin,cloudbaseinit.plugins.windows.setuserpassword.SetUserPasswordPlugin,cloudbaseinit.plugins.common.sshpublickeys.SetUserSSHPublicKeysPlugin,cloudbaseinit.plugins.common.userdata.UserDataPlugin,cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin
==> vsphere-iso.winserv2022stan: Replaced or added metadata_services in cloudbase-init-unattend.conf
==> vsphere-iso.winserv2022stan:
==> vsphere-iso.winserv2022stan: Uploading ../common/Unattend.xml => C:/Windows/System32/Sysprep/Unattend.xml
==> vsphere-iso.winserv2022stan: Provisioning with Powershell...
==> vsphere-iso.winserv2022stan: Provisioning with powershell script: C:\Users\andrewta\AppData\Local\Temp\powershell-provisioner27299154
==> vsphere-iso.winserv2022stan: Virtual machine is already powered off.
==> vsphere-iso.winserv2022stan: Deleting floppy drives...
==> vsphere-iso.winserv2022stan: Deleting floppy image...
==> vsphere-iso.winserv2022stan: Ejecting CD-ROM media...
==> vsphere-iso.winserv2022stan: Converting virtual machine to template...
==> vsphere-iso.winserv2022stan: Clearing boot order...
==> vsphere-iso.winserv2022stan: Closing sessions ....
Build 'vsphere-iso.winserv2022stan' finished after 1 hour 2 minutes.

==> Wait completed after 1 hour 2 minutes

==> Builds finished. The artifacts of successful builds are:
--> vsphere-iso.winserv2022stan: winserv2022stan-20250806

==== Output from WinServ2025Stan ====

[C:\Users\andrewta\Documents\Github\windows-packer\WinServ2025Stan] Starting build...
[C:\Users\andrewta\Documents\Github\windows-packer\WinServ2025Stan] Removed existing packer.auto.pkrvars.hcl
Reading variables from ..\.env...
Generated vsphere_template_name = winserv2025stan-20250806
Added os_iso_path = [nwsc_vm_install] Aria Images/Windows/SW_DVD9_Win_Server_STD_CORE_2025_24H2_64Bit_English_DC_STD_MLF_X23-81891.ISO
Writing to .\packer.auto.pkrvars.hcl...
packer build -var-file=packer.auto.pkrvars.hcl .
[C:\Users\andrewta\Documents\Github\windows-packer\WinServ2025Stan] Rendered Autounattend.xml
[C:\Users\andrewta\Documents\Github\windows-packer\WinServ2025Stan] Starting packer build...
vsphere-iso.winserv2025stan: output will be in this color.

==> vsphere-iso.winserv2025stan: Creating virtual machine...
==> vsphere-iso.winserv2025stan: Customizing hardware...
==> vsphere-iso.winserv2025stan: Mounting ISO images...
==> vsphere-iso.winserv2025stan: Adding configuration parameters...
==> vsphere-iso.winserv2025stan: Creating floppy disk...
==> vsphere-iso.winserv2025stan: Copying files flatly from floppy_files
==> vsphere-iso.winserv2025stan: Copying file: ./Autounattend.xml
==> vsphere-iso.winserv2025stan: Copying file: ./../common/scripts/setup.ps1
==> vsphere-iso.winserv2025stan: Done copying files from floppy_files
==> vsphere-iso.winserv2025stan: Collecting paths from floppy_dirs
==> vsphere-iso.winserv2025stan: Resulting paths from floppy_dirs : []
==> vsphere-iso.winserv2025stan: Done copying paths from floppy_dirs
==> vsphere-iso.winserv2025stan: Copying files from floppy_content
==> vsphere-iso.winserv2025stan: Done copying files from floppy_content
==> vsphere-iso.winserv2025stan: Uploading floppy image...
==> vsphere-iso.winserv2025stan: Adding generated floppy image...
==> vsphere-iso.winserv2025stan: Setting temporary boot order...
==> vsphere-iso.winserv2025stan: Powering on virtual machine...
==> vsphere-iso.winserv2025stan: Waiting 3s for boot...
==> vsphere-iso.winserv2025stan: Typing boot command...
==> vsphere-iso.winserv2025stan: Waiting for IP...
==> vsphere-iso.winserv2025stan: IP address: xx.xx.xx.xx
==> vsphere-iso.winserv2025stan: Using WinRM communicator to connect: xx.xx.xx.xx
==> vsphere-iso.winserv2025stan: Waiting for WinRM to become available...
==> vsphere-iso.winserv2025stan: WinRM connected.
==> vsphere-iso.winserv2025stan: Connected to WinRM!
==> vsphere-iso.winserv2025stan: Restarting Machine
==> vsphere-iso.winserv2025stan: Waiting for machine to restart...
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: WIN-B6V6JVTH4QI restarted.
==> vsphere-iso.winserv2025stan: Machine successfully restarted, moving on
==> vsphere-iso.winserv2025stan: Uploading ../common/scripts/updateAndHarden.ps1 => C:/Windows/Temp/updateAndHarden.ps1
==> vsphere-iso.winserv2025stan: Uploading ../common/scripts/installCloudbaseInit.ps1 => C:/Windows/Temp/installCloudbaseInit.ps1
==> vsphere-iso.winserv2025stan: Provisioning with Powershell...
==> vsphere-iso.winserv2025stan: Provisioning with powershell script: C:\Users\andrewta\AppData\Local\Temp\powershell-provisioner1237331664
==> vsphere-iso.winserv2025stan: Configuring IIS with SSL/TLS Deployment Best Practices...
==> vsphere-iso.winserv2025stan: --------------------------------------------------------------------------------
==> vsphere-iso.winserv2025stan: Multi-Protocol Unified Hello has been disabled.
==> vsphere-iso.winserv2025stan: PCT 1.0 has been disabled.
==> vsphere-iso.winserv2025stan: SSL 2.0 has been disabled.
==> vsphere-iso.winserv2025stan: SSL 3.0 has been disabled.
==> vsphere-iso.winserv2025stan: TLS 1.0 has been disabled.
==> vsphere-iso.winserv2025stan: TLS 1.1 has been disabled.
==> vsphere-iso.winserv2025stan: TLS 1.2 has been enabled.
==> vsphere-iso.winserv2025stan: Weak cipher DES 56/56 has been disabled.
==> vsphere-iso.winserv2025stan: Weak cipher NULL has been disabled.
==> vsphere-iso.winserv2025stan: Weak cipher RC2 128/128 has been disabled.
==> vsphere-iso.winserv2025stan: Weak cipher RC2 40/128 has been disabled.
==> vsphere-iso.winserv2025stan: Weak cipher RC2 56/128 has been disabled.
==> vsphere-iso.winserv2025stan: Weak cipher RC4 40/128 has been disabled.
==> vsphere-iso.winserv2025stan: Weak cipher RC4 56/128 has been disabled.
==> vsphere-iso.winserv2025stan: Weak cipher RC4 64/128 has been disabled.
==> vsphere-iso.winserv2025stan: Weak cipher RC4 128/128 has been disabled.
==> vsphere-iso.winserv2025stan: Weak cipher Triple DES 168 has been disabled.
==> vsphere-iso.winserv2025stan: Strong cipher AES 128/128 has been enabled.
==> vsphere-iso.winserv2025stan: Strong cipher AES 256/256 has been enabled.
==> vsphere-iso.winserv2025stan: Hash SHA256 has been enabled.
==> vsphere-iso.winserv2025stan: Hash SHA384 has been enabled.
==> vsphere-iso.winserv2025stan: Hash SHA512 has been enabled.
==> vsphere-iso.winserv2025stan: Hash SHA has been disabled.
==> vsphere-iso.winserv2025stan: Hash MD5 has been disabled.
==> vsphere-iso.winserv2025stan: KeyExchangeAlgorithm Diffie-Hellman has been enabled.
==> vsphere-iso.winserv2025stan: KeyExchangeAlgorithm ECDH has been enabled.
==> vsphere-iso.winserv2025stan: KeyExchangeAlgorithm PKCS has been enabled.
==> vsphere-iso.winserv2025stan: Configure longer DHE key shares for TLS servers.
==> vsphere-iso.winserv2025stan: SMB Secure Client Signing has been enabled.
==> vsphere-iso.winserv2025stan: SMB Secure Server Signing has been enabled
==> vsphere-iso.winserv2025stan: Enable TLS 1.2 for .NET 3.5 and .NET 4.x
==> vsphere-iso.winserv2025stan: $defaultSecureProtocolsSum =  2048
==> vsphere-iso.winserv2025stan: Enable NLA for Remote Desktop connections
==> vsphere-iso.winserv2025stan: Require high level encryption for Remote Desktop sessions
==> vsphere-iso.winserv2025stan: A computer restart is required to apply settings. Will restart after OS updates.
==> vsphere-iso.winserv2025stan:
==> vsphere-iso.winserv2025stan: Name                     Version          DynamicOptions
==> vsphere-iso.winserv2025stan: ----                     -------          --------------
==> vsphere-iso.winserv2025stan: NuGet                    2.8.5.208        Destination, ExcludeVersion, Scope, SkipDependencies, Headers, FilterOnTag...
==> vsphere-iso.winserv2025stan: Installing Windows updates...
==> vsphere-iso.winserv2025stan: Reboot is required, but do it manually.
==> vsphere-iso.winserv2025stan:
==> vsphere-iso.winserv2025stan:
==> vsphere-iso.winserv2025stan:
==> vsphere-iso.winserv2025stan: Restarting Machine
==> vsphere-iso.winserv2025stan: Waiting for machine to restart...
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: A system shutdown is in progress.(1115)
==> vsphere-iso.winserv2025stan: WIN-B6V6JVTH4QI restarted.
==> vsphere-iso.winserv2025stan: Machine successfully restarted, moving on
==> vsphere-iso.winserv2025stan: Provisioning with Powershell...
==> vsphere-iso.winserv2025stan: Provisioning with powershell script: C:\Users\andrewta\AppData\Local\Temp\powershell-provisioner1080890094
==> vsphere-iso.winserv2025stan: Downloaded Cloudbase-Init.
==> vsphere-iso.winserv2025stan: Installed Cloudbase-Init.
==> vsphere-iso.winserv2025stan: Added to cloudbase-init.conf: first_logon_behaviour=no
==> vsphere-iso.winserv2025stan: Added to cloudbase-init.conf: metadata_services=cloudbaseinit.metadata.services.ovfservice.OvfService
==> vsphere-iso.winserv2025stan: Added to cloudbase-init.conf: plugins=cloudbaseinit.plugins.windows.createuser.CreateUserPlugin,cloudbaseinit.plugins.windows.setuserpassword.SetUserPasswordPlugin,cloudbaseinit.plugins.common.sshpublickeys.SetUserSSHPublicKeysPlugin,cloudbaseinit.plugins.common.userdata.UserDataPlugin,cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin
==> vsphere-iso.winserv2025stan: Replaced or added metadata_services in cloudbase-init-unattend.conf
==> vsphere-iso.winserv2025stan:
==> vsphere-iso.winserv2025stan: Uploading ../common/Unattend.xml => C:/Windows/System32/Sysprep/Unattend.xml
==> vsphere-iso.winserv2025stan: Provisioning with Powershell...
==> vsphere-iso.winserv2025stan: Provisioning with powershell script: C:\Users\andrewta\AppData\Local\Temp\powershell-provisioner2753688979
==> vsphere-iso.winserv2025stan: Virtual machine is already powered off.
==> vsphere-iso.winserv2025stan: Deleting floppy drives...
==> vsphere-iso.winserv2025stan: Deleting floppy image...
==> vsphere-iso.winserv2025stan: Ejecting CD-ROM media...
==> vsphere-iso.winserv2025stan: Converting virtual machine to template...
==> vsphere-iso.winserv2025stan: Clearing boot order...
==> vsphere-iso.winserv2025stan: Closing sessions ....
Build 'vsphere-iso.winserv2025stan' finished after 1 hour 14 minutes.

==> Wait completed after 1 hour 14 minutes

==> Builds finished. The artifacts of successful builds are:
--> vsphere-iso.winserv2025stan: winserv2025stan-20250806
```