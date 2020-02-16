include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
	message(FATAL_ERROR "Cross-compiling is not supported")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ampl/mp
    REF 67875b71ef68511277ec2dc8224f613487cefce9
    SHA512 fad2496c10b843ddad7c4dba1eea1b4cd22e90be12dec2ad598fbd1ed5e1c492d92c5130490c7045ea608bc9ea2af191661c39b3bee3bc5159663f306ce50950
    HEAD_REF master
    PATCHES
    disable-matlab-mex.patch
    workaround-msvc-optimizer-ice.patch
    install-targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DBUILD=asl
    -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(
    CONFIG_PATH share/unofficial-mp
    TARGET_PATH share/unofficial-mp
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share/mp)

configure_file(${SOURCE_PATH}/LICENSE.rst
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
vcpkg_test_cmake(PACKAGE_NAME unofficial-mp)
