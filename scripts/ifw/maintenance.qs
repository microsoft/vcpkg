// constructor
function Component()
{
    installer.installationStarted.connect(this, Component.prototype.onInstallationStarted);
}

Component.prototype.onInstallationStarted = function()
{
    if (component.updateRequested() || component.installationRequested()) {
        if (installer.value("os") == "win")
            component.installerbaseBinaryPath = "@TargetDir@/tempmaintenancetool.exe";
        installer.setInstallerBaseBinary(component.installerbaseBinaryPath);
    }
}

Component.prototype.createOperations = function()
{
    // call the base createOperations
    component.createOperations();

    // only for windows online installer
    if ( installer.value("os") == "win" && !installer.isOfflineOnly() )
    {
        // shortcut to add or remove packages
        component.addOperation( "CreateShortcut",
                                "@TargetDir@/maintenancetool.exe",
                                "@StartMenuDir@/Manage vcpkg.lnk",
                                " --manage-packages");
        // shortcut to update packages
        component.addOperation( "CreateShortcut",
                                "@TargetDir@/maintenancetool.exe",
                                "@StartMenuDir@/Update vcpkg.lnk",
                                " --updater");
    }

    // create uninstall link only for windows
    if (installer.value("os") == "win")
    {
        // shortcut to uninstaller
        component.addOperation( "CreateShortcut",
                                "@TargetDir@/maintenancetool.exe",
                                "@StartMenuDir@/Uninstall vcpkg.lnk",
                                " --uninstall");
    }
}

