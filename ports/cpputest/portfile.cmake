vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cpputest/cpputest
    REF "v${VERSION}"
    SHA512 5f7d6f9e34a462b35a0161a7486fd56074f5b07f92d029a3c57741c72df7bbc6ea4f98b1e57e9c500ad6d57c303d222afe523d59ec943f4461f67ce5be74dd77
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTESTS=OFF
        -DTESTS_DETALED=OFF
        -DTESTS_BUILD_DISCOVER=OFF
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
