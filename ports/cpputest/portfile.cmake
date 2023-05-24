vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cpputest/cpputest
    REF 4699da9942a1bdcc33e2a8c8a48e863b0f18188e
    SHA512 6f588691f1b4092b3be8167ab09f3a4a64c34715ac9397210724121d161024a43b12a88198b02b0cc8da7d72406670daaf375bb64cc4cf92c8bd2479e7a881bc
    HEAD_REF master
    PATCHES
        fix-arm-build-error.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/CppUTest/cmake )
if (EXISTS "${CURRENT_PACKAGES_DIR}/lib/CppUTest")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/CppUTest")
endif()

if (EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/CppUTest")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/CppUTest")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
    file(GLOB CPPUTEST_LIBS "${CURRENT_PACKAGES_DIR}/lib/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    file(COPY ${CPPUTEST_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib/manual-link")
    file(REMOVE ${CPPUTEST_LIBS})
    
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/CppUTestTargets-release.cmake" "\${_IMPORT_PREFIX}/lib/" "\${_IMPORT_PREFIX}/lib/manual-link/")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
    file(GLOB CPPUTEST_LIBS "${CURRENT_PACKAGES_DIR}/debug/lib/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    file(COPY ${CPPUTEST_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
    file(REMOVE ${CPPUTEST_LIBS})

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/CppUTestTargets-debug.cmake" "\${_IMPORT_PREFIX}/debug/lib/" "\${_IMPORT_PREFIX}/debug/lib/manual-link/")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
