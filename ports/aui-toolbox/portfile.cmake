set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aui-framework/aui
    REF "v${VERSION}"
    SHA512 decac6cebb6003791896e8d7a9fd7334351aa30205eac787cdbb51d1da657cda140178e0b8f5d236b42a4c1f37633141fb869784e5fc5c9718b5396e077afe7d
    HEAD_REF master
    PATCHES
        debundle.patch
        disable-tests.patch
        disable-auib.patch
        fix-fmt12.patch
        fix-arm64.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/aui.audio/3rdparty" "${SOURCE_PATH}/aui.core/3rdparty" "${SOURCE_PATH}/aui.image/3rdparty" "${SOURCE_PATH}/aui.sqlite/3rdparty")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAUIB_COMPONENTS=toolbox
        -DAUI_INSTALL_RUNTIME_DEPENDENCIES=OFF
        -DAUIB_NO_PRECOMPILED=TRUE
        -DAUIB_DISABLE=ON
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/aui.toolbox${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    vcpkg_copy_tools(TOOL_NAMES aui.toolbox AUTO_CLEAN)
endif()
file(GLOB _aui_toolbox_leftovers "${CURRENT_PACKAGES_DIR}/*")
foreach(_entry IN LISTS _aui_toolbox_leftovers)
    if(NOT _entry STREQUAL "${CURRENT_PACKAGES_DIR}/tools" AND NOT _entry STREQUAL "${CURRENT_PACKAGES_DIR}/share")
        file(REMOVE_RECURSE "${_entry}")
    endif()
endforeach()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/aui-toolbox")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/aui-toolbox/aui-toolbox-config.cmake"
[=[
get_filename_component(_aui_toolbox_root "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
find_program(AUI_TOOLBOX_EXE NAMES aui.toolbox
    HINTS
        "${_aui_toolbox_root}/tools/aui-toolbox"
        "${_aui_toolbox_root}/tools/aui"
        "${_aui_toolbox_root}/bin"
    NO_DEFAULT_PATH
)
if(AUI_TOOLBOX_EXE)
    set(aui-toolbox_FOUND TRUE)
else()
    set(aui-toolbox_FOUND FALSE)
endif()
]=])

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
