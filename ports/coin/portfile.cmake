vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Coin3D/coin
    REF v${VERSION}
    SHA512 f913f1b1ec5819d72e054dc94702effe9ee2a28547fc9bebc2f6b2e55d8a67c6cfa05e43239461e806cbead0a7548f82b31d5b86181eed4ffc5c801d3b94aa67
    HEAD_REF master
    PATCHES
        remove-default-config.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(COIN_BUILD_SHARED_LIBS OFF)
else()
    set(COIN_BUILD_SHARED_LIBS ON)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(COIN_BUILD_MSVC_STATIC_RUNTIME OFF)
elseif(VCPKG_CRT_LINKAGE STREQUAL static)
    set(COIN_BUILD_MSVC_STATIC_RUNTIME ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOIN_BUILD_DOCUMENTATION=OFF
        -DCOIN_BUILD_MSVC_STATIC_RUNTIME=${COIN_BUILD_MSVC_STATIC_RUNTIME}
        -DCOIN_BUILD_SHARED_LIBS=${COIN_BUILD_SHARED_LIBS}
        -DCOIN_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Coin-${VERSION})

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Coin/profiler")

vcpkg_fixup_pkgconfig()
