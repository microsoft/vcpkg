set(VCPKG_BUILD_TYPE release)  # tools
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

set(SHORT_VERSION 9.6)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kitware/VTK
    REF v${VERSION}
    SHA512 29931d44fcb44f9e9d34f0c5cbb698e93d1bb8fff92b7bdcf832ece7d1cdb47bb192b7ddd060d7227983554f1b38b49724c7dee0b1916725c5a3a863341ff928
    HEAD_REF master
    PATCHES
        name-suffix.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_INSTALL_INCLUDEDIR=install/${PORT}
        -DVTK_BUILD_COMPILE_TOOLS_ONLY=ON
        -DVTK_ENABLE_LOGGING=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Not adjusting the directory name: The package is meant to be
# selected either explicitly, or transitively via package vtk.
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/vtkcompiletools-${SHORT_VERSION})
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/vtkcompiletools-config-version.cmake" "set(PACKAGE_VERSION_UNSUITABLE TRUE)" "# host tools for any arch")

vcpkg_copy_tools(
    AUTO_CLEAN
    TOOL_NAMES
        vtkParseJava-${SHORT_VERSION}
        vtkWrapHierarchy-${SHORT_VERSION}
        vtkWrapJava-${SHORT_VERSION}
        vtkWrapJavaScript-${SHORT_VERSION}
        vtkWrapPython-${SHORT_VERSION}
        vtkWrapPythonInit-${SHORT_VERSION}
        vtkWrapSerDes-${SHORT_VERSION}
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright.txt")
