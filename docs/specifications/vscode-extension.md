# Vcpkg Support in the VS Code C++ extension 
This proposal aims to add MVP vcpkg support into the VS Code C++ extension. Some features of the VS Code CMake extension will also be changed.

## Current Experience in the C++ extension 
### Lightbulb Feature 
The lightbulb feature activates if both of the following conditions are met:
* You include a header file that is a known header file in Vcpkg library (such as #include <zlib.h>, which is a header shipped with the zlib library). 
* VSCode is unable to find the header. 
After these conditions are met, the user can click the light bulb and see the option `Copy vcpkg command to install zlib to your clipboard` which will add `vcpkg install zlib` to your clipboard. 

### Command Palette 
You can also access Vcpkg via the command palette, and there are two commands:  
* Copy vcpkg command to clipboard 
* Visit the Vcpkg help page 

### Extension Settings 
There is a Vcpkg boolean setting enable/disabled based on whether you want to enable the vcpkg features described above.

## Proposed Experience in the C++ Extension

### Tree View 
We will add a TreeView, which will allow users to manage their libraries via a UI interface. There will be 2 sections: 
* See list of currently installed libraries (users can toggle the settings such as which features of a library to use, triplet, version)
* See list of available libraries (including a search for libraries) 

### Lightbulb Feature 
In addition to the current experience, we will add: 
* Add the option `Install library via Vcpkg` 
* Add the option `Install all libraries via Vcpkg` 

### Command Palette 
We will deprecate the previous commands, in place of these new commands: 
Users can run the command `vcpkg install library_name`, `vcpkg remove library_name` (and other vcpkg commands such as update, search and export) 

### Extension Settings:
We will add two new settings:

setting: `vcpkg.vcpkgPath`, 
description: `Path to directory where the vcpkg executable is located`
  
setting: `vcpkg.targetTriplet`,
description: `Target vcpkg triplet` 

## Other considerations
### Compiler and buildsystem support 
We want to make sure we are using the tools/compiler that the user intends. In VS Code, you can specify these options by creating a `tasks.json`. We will detect which compiler/standard library you are using from this and pass this info to your vcpkg instance.

### CMake Extension Support
This will require modifying the CMake extension (making sure the right variables are populated and configured). IntelliSense support (for autocompletion of target names) will also be added. 
### Debugging support 
Depending on whether debugging in VS Code is used, it might make sense to add debugging support so users can navigate the sources of libraries they have installed. 
