vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mfontanini/libtins
    REF v4.3
    SHA512 29d606004fe9a440c9a53eede42fd5c6dbd049677d2cca2c5cfd26311ee2ca4c64ca3e665fbc81efd5bfab5577a5181ed0754c617e139317d9ae0cabba05aff7
    HEAD_REF master
    PATCHES
        fix-source-writes.patch
        find-pcap_static.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBTINS_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBTINS_BUILD_SHARED=${LIBTINS_BUILD_SHARED}
        -DLIBTINS_ENABLE_CXX11=1
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=1
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libtins)
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/libtins/libtinsConfig.cmake" "set(LIBTINS_INCLUDE_DIRS \"${SOURCE_PATH}/include\")" [[
get_filename_component(LIBTINS_CMAKE_DIR "${LIBTINS_CMAKE_DIR}" PATH)
get_filename_component(LIBTINS_CMAKE_DIR "${LIBTINS_CMAKE_DIR}" PATH)
set(LIBTINS_INCLUDE_DIRS "${LIBTINS_CMAKE_DIR}/include")
]])

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/libtins/libtinsConfig.cmake" "\${LIBTINS_CMAKE_DIR}/libtinsTargets.cmake" "\${CMAKE_CURRENT_LIST_DIR}/libtinsTargets.cmake")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/tins/macros.h" "!defined(TINS_STATIC)" "1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/tins/macros.h" "!defined(TINS_STATIC)" "0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libtins" RENAME copyright)
