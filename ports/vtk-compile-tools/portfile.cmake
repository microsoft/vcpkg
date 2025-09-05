set(VCPKG_BUILD_TYPE release)  # tools
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

set(SHORT_VERSION 9.3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/VTK
    REF 09a76bc55b37caad94d0d8ebe865caaed1b438af # v9.3.x used by ParaView 5.12.0
    SHA512 396ee901fafacae8aef860b9c9c17cb92ae8b4969527fd271ad8dd9f6a9e0dc8e3dc807c8d43cc585608ad101a64edcd7aff49e1580c7a61a817c2ea8e2655f5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVTK_BUILD_COMPILE_TOOLS_ONLY=ON
        -DVTK_ENABLE_LOGGING=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Not adjusting the directory name: The package location is meant to be passed explicitly.
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/vtkcompiletools-${SHORT_VERSION})

vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES vtkParseJava-${SHORT_VERSION} vtkWrapHierarchy-${SHORT_VERSION} vtkWrapJava-${SHORT_VERSION} vtkWrapPython-${SHORT_VERSION} vtkWrapPythonInit-${SHORT_VERSION})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")  # owned by port vtk

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright.txt")
