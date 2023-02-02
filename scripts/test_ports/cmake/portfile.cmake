set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.kitware.com/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmake/cmake
    REF
        8428e39ed9cddb3b7f1a6f7a58cb8617503183d2
    SHA512
        4a40656efe5854bd6b893d0b2b86eed5df42992d080edb9c0cb2da2c55ad8dd489a85072b138947933d94ef5ba90c7a59f0a4460e3722d0f898ceefbbf74d226 
    HEAD_REF master
    PATCHES fix-dependency-libuv.patch
)
set(OPTIONS)
if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS "-DBUILD_CursesDialog=ON")
else()
    list(APPEND OPTIONS "-DBUILD_CursesDialog=OFF")
endif()

if(VCPKG_CROSSCOMPILING)
    list(APPEND OPTIONS "-DQt6CoreTools_DIR=${CURRENT_HOST_INSTALLED_DIR}/share/Qt6CoreTools")
    list(APPEND OPTIONS "-DQt6WidgetsTools_DIR=${CURRENT_HOST_INSTALLED_DIR}/share/Qt6WidgetsTools")
    list(APPEND OPTIONS "-DQt6GuiTools_DIR=${CURRENT_HOST_INSTALLED_DIR}/share/Qt6GuiTools")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64 AND VCPKG_TARGET_IS_WINDOWS) # Remove if PR #16111 is merged
        list(APPEND OPTIONS -DCMAKE_CROSSCOMPILING=ON -DCMAKE_SYSTEM_PROCESSOR:STRING=ARM64 -DCMAKE_SYSTEM_NAME:STRING=Windows)
    endif()
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
        #-DCMAKE_USE_SYSTEM_LIBRARIES=ON
        -DCMAKE_USE_SYSTEM_LIBARCHIVE=ON
        -DCMAKE_USE_SYSTEM_CURL=ON
        -DCMAKE_USE_SYSTEM_EXPAT=ON
        -DCMAKE_USE_SYSTEM_ZLIB=ON
        -DCMAKE_USE_SYSTEM_BZIP2=ON
        -DCMAKE_USE_SYSTEM_ZSTD=ON
        -DCMAKE_USE_SYSTEM_FORM=ON
        -DCMAKE_USE_SYSTEM_JSONCPP=ON
        -DCMAKE_USE_SYSTEM_LIBRHASH=OFF # not yet in VCPKG
        -DCMAKE_USE_SYSTEM_LIBUV=ON
        -DBUILD_QtDialog=ON # Just to test Qt with CMake
        -DCMake_QT_MAJOR_VERSION:STRING=6
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_copy_pdbs()

if(NOT VCPKG_TARGET_IS_OSX)
    set(_tools cmake cmake-gui ctest cpack)
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND _tools cmcldeps)
    endif()
    if(BUILD_CURSES_DIALOG)
        list(APPEND _tools ccmake)
    endif()
    vcpkg_copy_tools(TOOL_NAMES ${_tools} AUTO_CLEAN)
else()
    # On OSX everything is within a CMake.app folder
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
    file(RENAME "${CURRENT_PACKAGES_DIR}/CMake.app" "${CURRENT_PACKAGES_DIR}/tools/CMake.app")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/CMake.app")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/CMake.app" "${CURRENT_PACKAGES_DIR}/tools/debug/CMake.app")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
configure_file("${SOURCE_PATH}/Copyright.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
