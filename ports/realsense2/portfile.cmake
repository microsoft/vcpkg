vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IntelRealSense/librealsense
    REF "v${VERSION}"
    SHA512 20561294da571e0e1f5f8c9ac1039828512f3361a4241e5ad320bbb684626c1e78cd18e6a6344ec80fcd86dc699742c51069bc2b6895aec1dcbd9f394d2c9998
    HEAD_REF master
    PATCHES
        fix_openni2.patch
        fix-osx.patch # from https://github.com/IntelRealSense/librealsense/pull/11997
)

file(COPY "${SOURCE_PATH}/src/win7/drivers/IntelRealSense_D400_series_win7.inf" DESTINATION "${SOURCE_PATH}")
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_CRT_LINKAGE)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

set(BUILD_OPENNI2_BINDINGS OFF)
if(("openni2" IN_LIST FEATURES) AND (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic"))
  set(BUILD_OPENNI2_BINDINGS ON)
endif()

set(PLATFORM_OPTIONS)
if (VCPKG_TARGET_IS_ANDROID)
    list(APPEND PLATFORM_OPTIONS -DFORCE_RSUSB_BACKEND=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DENFORCE_METADATA=ON
        -DBUILD_WITH_OPENMP=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_WITH_STATIC_CRT=${BUILD_CRT_LINKAGE}
        -DBUILD_OPENNI2_BINDINGS=${BUILD_OPENNI2_BINDINGS}
        -DOPENNI2_DIR=${CURRENT_INSTALLED_DIR}/include/openni2
        ${PLATFORM_OPTIONS}
        -DBUILD_EXAMPLES=OFF
        -DBUILD_GRAPHICAL_EXAMPLES=OFF
    MAYBE_UNUSED_VARIABLES
        OPENNI2_DIR
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/realsense2)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/realsense2/realsense2Targets.cmake" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" "\${_IMPORT_PREFIX}")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/realsense2/realsense2Targets.cmake" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg" "\${_IMPORT_PREFIX}")
	
	file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/common/fw")
	file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/common/fw/fw.res" DESTINATION "${CURRENT_PACKAGES_DIR}/common/fw")
endif()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(BUILD_TOOLS)
    set(TOOL_NAMES rs-convert rs-embed rs-enumerate-devices rs-fw-logger rs-fw-update rs-record rs-terminal)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

if(BUILD_OPENNI2_BINDINGS)
    file(GLOB RS2DRIVER "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/_out/rs2driver*")
    if(RS2DRIVER)
        file(COPY ${RS2DRIVER} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/openni2/OpenNI2/Drivers")
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_fixup_pkgconfig()
