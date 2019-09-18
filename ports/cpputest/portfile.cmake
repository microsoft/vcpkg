include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cpputest/cpputest
    REF 4699da9942a1bdcc33e2a8c8a48e863b0f18188e
    SHA512 6f588691f1b4092b3be8167ab09f3a4a64c34715ac9397210724121d161024a43b12a88198b02b0cc8da7d72406670daaf375bb64cc4cf92c8bd2479e7a881bc
    HEAD_REF master
    PATCHES fix-arm-build-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/CppUTest/cmake TARGET_PATH share/CppUTest)
if (EXISTS ${CURRENT_PACKAGES_DIR}/lib/CppUTest)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/CppUTest)
endif()

if (EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/CppUTest)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/CppUTest)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
