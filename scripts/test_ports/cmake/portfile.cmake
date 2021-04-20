set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.kitware.com/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmake/cmake
    REF
        b7b0fb430397bafae4a7bd80b41d474c91a3b7f3
    SHA512
        3b0de26910bceaf4bc6546255bada4c502cd0fd32f44bc28b067f347c09d028c175a3243551bbe4bb64bcf312df9ff827e8fdbcb0b34a12e1ce4a26ba0799ee2 
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
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
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)
vcpkg_copy_pdbs()

if(NOT VCPKG_TARGET_IS_OSX)
    set(_tools cmake cmake-gui ctest cpack)
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND _tools cmcldeps)
    endif()
    vcpkg_copy_tools(TOOL_NAMES ${_tools} AUTO_CLEAN)
else()
    # On OSX everything is within a CMake.app folder
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
    file(RENAME "${CURRENT_PACKAGES_DIR}/CMake.app" "${CURRENT_PACKAGES_DIR}/tools/CMake.app")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/CMake.app")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/debug)
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/CMake.app" "${CURRENT_PACKAGES_DIR}/tools/debug/CMake.app")
    endif()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
configure_file(${SOURCE_PATH}/Copyright.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
