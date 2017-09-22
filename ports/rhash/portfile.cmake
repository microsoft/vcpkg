if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "UWP builds not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rhash/RHash
    REF v1.3.5
    SHA512 e8450aab0c16bfb975bf4aeee218740fb4d86d5514e426b70c3edb84e4d63865cd4051939aa95c24a87a78baaedc49e40bb509b2610e89ca3745930808b3ef6c
    HEAD_REF master)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/librhash)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/librhash
    PREFER_NINJA
    OPTIONS_DEBUG
        -DRHASH_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/rhash)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rhash/COPYING ${CURRENT_PACKAGES_DIR}/share/rhash/copyright)
