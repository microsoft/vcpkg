vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Coin3D/coin
    REF Coin-4.0.0
    SHA512 8a0289cab3e02a7417022fe659ec30a2dd705b9bacb254e0269ada9155c76c6aea0285c475cd6e663f5d7f2b49e60244b16baac7188d57e3d7f8ab08d228f21f
    HEAD_REF master
    PATCHES
        disable-cpackd.patch
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Coin-4.0.0)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Coin/profiler")

vcpkg_fixup_pkgconfig()
