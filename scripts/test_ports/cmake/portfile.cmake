set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.kitware.com/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmake/cmake
    REF v${VERSION}
    SHA512 ac67fe802179f6cd9ed290f905976923ffa3843e63e0e680a971a1019a88b813e281bd912e71a02af5df101eb1dd1692f140e34466ba4fa1b822a03097d2467b
    HEAD_REF master
    PATCHES
        fix-dependency-libuv.patch
)
set(OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS "-DBUILD_CursesDialog=OFF")
else()
    list(APPEND OPTIONS "-DBUILD_CursesDialog=ON")
endif()

if(VCPKG_CROSSCOMPILING)
    list(APPEND OPTIONS "-DQt6CoreTools_DIR=${CURRENT_HOST_INSTALLED_DIR}/share/Qt6CoreTools")
    list(APPEND OPTIONS "-DQt6WidgetsTools_DIR=${CURRENT_HOST_INSTALLED_DIR}/share/Qt6WidgetsTools")
    list(APPEND OPTIONS "-DQt6GuiTools_DIR=${CURRENT_HOST_INSTALLED_DIR}/share/Qt6GuiTools")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(VCPKG_CXX_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_CXX_FLAGS}")
    set(VCPKG_C_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_C_FLAGS}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -DBUILD_TESTING=OFF
        -DCMAKE_USE_SYSTEM_LIBRARIES=ON
        -DBUILD_QtDialog=ON # Just to test Qt with CMake
        -DCMake_QT_MAJOR_VERSION:STRING=6
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_OSX)
    # On OSX everything is within a CMake.app folder
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
    file(RENAME "${CURRENT_PACKAGES_DIR}/CMake.app" "${CURRENT_PACKAGES_DIR}/tools/CMake.app")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/CMake.app")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/CMake.app" "${CURRENT_PACKAGES_DIR}/tools/debug/CMake.app")
    endif()
else()
    set(tool_names cmake cmake-gui ctest cpack)
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND tool_names cmcldeps)
    else()
        list(APPEND tool_names ccmake)
    endif()
    vcpkg_copy_tools(TOOL_NAMES ${tool_names} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.rst")
