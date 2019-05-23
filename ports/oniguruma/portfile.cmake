include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kkos/oniguruma
    REF v6.9.2
    SHA512 b5578560f469c2e123280159a23a0e59045bf2452fd3efe09393c5e99ecc6323f965d2189a4e7e6e3a108c1d02b9b041f3fe991cd8ab64f7289003a5a07b4434
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

vcpkg_copy_pdbs()

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
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
