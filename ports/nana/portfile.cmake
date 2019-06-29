include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(WARNING "You will need to install Xorg dependencies to use nana:\napt install libx11-dev libxft-dev\n")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnjinhao/nana
    REF v1.7.1
    SHA512 43bd6f6321557184431935b4fdd636427458e79333879f6310685a70ee25f4344851910e67c52145382c38a3cea9d1761b40c8edbc072a7cc9c62406ed402549
    HEAD_REF develop
    PATCHES
        fix-build-error.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNANA_ENABLE_PNG=ON
        -DNANA_ENABLE_JPEG=ON
    OPTIONS_DEBUG
        -DNANA_INSTALL_HEADERS=OFF)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-nana TARGET_PATH share/unofficial-nana)

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nana)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nana/LICENSE ${CURRENT_PACKAGES_DIR}/share/nana/copyright)
