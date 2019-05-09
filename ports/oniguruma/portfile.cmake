include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kkos/oniguruma
    REF 502b1f416746ed8700498229bbfceb180e400fbc
    SHA512 0faf12f415de59716d8faa4d3dc026874c3bd6a3624f75f2a184843025294eb885d57164ae6dcb916cba5c7d1a4da4bcb0dc23fce3ceae5b34b7320e8f0e2c02
    HEAD_REF master
)

if("non-posix" IN_LIST FEATURES)
    set(ENABLE_POSIX_API OFF)
else()
    set(ENABLE_POSIX_API ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_POSIX_API=${ENABLE_POSIX_API}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/oniguruma.h
        "#if defined(ONIGURUMA_EXPORT)"
        "#if 0 // defined(ONIGURUMA_EXPORT)"
    )
else()
    # oniguruma.h uses `\n` as line break.
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/oniguruma.h
        "#ifndef ONIG_EXTERN\n#if defined(_WIN32) && !defined(__GNUC__)"
        "#if 0\n#if defined(_WIN32) && !defined(__GNUC__)"
    )
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
#vcpkg_test_cmake(PACKAGE_NAME ${PORT})
