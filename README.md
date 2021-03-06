# JEA-AdmComm
JEA-AdmComm is a tool that allows certain users to start some specific programs with administrative privileges in Microsoft Windows.

Selected users will be able to start those programs in privileged mode just by clicking on a link, without entering any password.

It's a PowerShell module that leverages [JEA](https://docs.microsoft.com/en-us/powershell/jea/overview) and [PsExec](https://docs.microsoft.com/en-us/sysinternals/downloads/psexec) to let certain unprivileged users run specific processes with full administrative privileges.

Technically, it uses JEA to run PsExec with administrative rights, which in turn runs the specific process with the privileges of the System account.

## SAQ (Should-Ask Questions)
*Isn't JEA sufficient in itself for this?*

Not always: for example, at the time of writing, JEA does not handle the GUI of the processes that it runs, while JEA-AdmComm does (through the combined use of JEA and PsExec).

*Is JEA-AdmComm super-secure?*

Of course not! It is a "best-effort tool" that shares the limitations of all the programs of its kind.

For instance, you may think that letting a user run Paint with administrative rights does not represent a security threat...

But, in fact, it does!

For example, after opening Paint with administrative rights, a user can select File -> Open, opening a File Explorer instance with full system privileges.

*So, why should I use it?*

You should prefer it over other 3rd party solutions for four reasons:
- it is just a PowerShell module, using Microsoft-only software to get the job done
- for the users, it is as easy as clicking on a link (no passwords to type!)
- it does not store any password (neither in plaintext nor encrypted)
- it is free and open source (but, of course, leverages Microsoft components such as PowerShell and PsExec, that come with their own licenses)

*Who are you?*

Marco Bellaccini - marco.bellaccini[at!]gmail.com

## Installation
In order to install the module, you should first check that your PowerShell version is >= 5.1.

If your are running at least Windows Server 2016 or an up-to-date Windows 10 you should be fine, otherwise you should [update PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-windows-powershell?view=powershell-6#upgrading-existing-windows-powershell).

After this, you should [download PsExec](https://docs.microsoft.com/en-us/sysinternals/downloads/psexec), and extract the archive in some appropriate location (e.g.: C:\LocalAdministration\PSTools).

Then, open a PowerShell **as Administrator**.

In order to setup WinRM (used by JEA), you have to type:

```
Set-Service -Name winrm -StartupType Automatic
Set-Service -Name winrm -Status Running
```

(this shouldn't be needed on Windows Server since WinRM is enabled by default).

When enabling WinRM, please remember to implement appropriate firewalling (for instance, if you're using WinRM only for JEA, you can configure Windows Firewall to drop WinRM connections from hosts other than localhost).

Then, to install the module, type:

```
powershell -ExecutionPolicy Bypass [PATH_TO_INSTALL.ps1] [PATH_TO_PSEXEC64] [DOMAIN\GROUP] [PATH_TO_TGTEXE1(,PATH_TO_TGTEXE2...)]
```

where:
- PATH_TO_INSTALL.ps1 is the full path of the INSTALL.ps1 script bundled with JEA-AdmComm
- PATH_TO_PSEXEC64 is the full path of the PsExec64 executable (32 bit systems are not supported!)
- DOMAIN\GROUP is the group of the users that will be granted permission to run the program with administrative privileges (**in the form DOMAIN\GROUP** - you can use .\GROUP for local groups)
- PATH_TO_TGTEXE1(,PATH_TO_TGTEXE2...) is a comma-separated list of the full paths of the executables to launch with administrative rights
- *when passing the arguments, if a path contains spaces, it must be enclosed in double (")* **AND** *single (') quotation marks like this: "'path with spaces'"*

This will install the PowerShell module, configure JEA in the right way and create some nice links (with name beginning with "ADM_") in the *Links* folder (that will be created in the same folder where INSTALL.ps1 is located).

Please make sure that permissions on PsExec64 and target programs paths are set to prevent users from writing/modifying files (in order to block executable swapping attacks).

You can use the links generated by *INSTALL.ps1* to let users launch the programs with administrative rights (so, you'll probably need to copy the links somewhere - e.g. on target users' desktops).

## Uninstallation
Open a command prompt (or a PowerShell) **as Administrator** and run:

```
powershell -ExecutionPolicy Bypass [PATH_TO_INSTALL.ps1] [PATH_TO_PSEXEC64] [DOMAIN\GROUP] [PATH_TO_TGTEXE1(,PATH_TO_TGTEXE2...)] -uninstall
```

