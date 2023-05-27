vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libglui/glui
    REF 093edc777c02118282910bdee59f8db1bd46a84d
    SHA512 650e169a6a55cd7d599176ac0767cd95b511fbc0a9b27aab2fa4f94a6395fa1a5762b6c23f5f1a9fc5ac9ce70c44fee4e4cbb6d6afd2307130cedfb80aae877a
    HEAD_REF master
    PATCHES
        install-one-flavor.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/GL/glui.h"
        "ifdef GLUIDLL"
        "if 1 //ifdef GLUIDLL"
    )
endif()

file(INSTALL "${SOURCE_PATH}/license.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
