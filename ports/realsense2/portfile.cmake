vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IntelRealSense/librealsense
    REF 0adceb9dc6fce63c348346e1aef1b63c052a1db9 #v2.38.1
    SHA512 bbbbf1afd4227d7cd46cb47c5cd71bc430c439ee1d8a54b3d1732017e2d34d9d696ced12c4d2449ce153b3deed422f6b3d2f561b44ca373ec9c69d5d3a766090
    HEAD_REF master
    PATCHES
        fix_openni2.patch
        fix-dependency-glfw3.patch
)

file(COPY ${SOURCE_PATH}/src/win7/drivers/IntelRealSense_D400_series_win7.inf DESTINATION ${SOURCE_PATH})
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_CRT_LINKAGE)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tm2   BUILD_WITH_TM2
)

set(BUILD_TOOLS OFF)
if("tools" IN_LIST FEATURES)
    set(BUILD_TOOLS ON)
endif()

set(BUILD_OPENNI2_BINDINGS OFF)
if(("openni2" IN_LIST FEATURES) AND (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic"))
  set(BUILD_OPENNI2_BINDINGS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DENFORCE_METADATA=ON
        -DBUILD_WITH_OPENMP=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_WITH_STATIC_CRT=${BUILD_CRT_LINKAGE}
        -DBUILD_OPENNI2_BINDINGS=${BUILD_OPENNI2_BINDINGS}
        -DOPENNI2_DIR=${CURRENT_INSTALLED_DIR}/include/openni2
    OPTIONS_RELEASE
        -DBUILD_EXAMPLES=${BUILD_TOOLS}
        -DBUILD_GRAPHICAL_EXAMPLES=${BUILD_TOOLS}
    OPTIONS_DEBUG
        -DBUILD_EXAMPLES=OFF
        -DBUILD_GRAPHICAL_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/realsense2)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(BUILD_TOOLS)
    file(GLOB EXEFILES_RELEASE 
        ${CURRENT_PACKAGES_DIR}/bin/rs-* 
        ${CURRENT_PACKAGES_DIR}/bin/realsense-*
    )

    if (EXEFILES_RELEASE)
        file(COPY ${EXEFILES_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/realsense2)
        file(REMOVE ${EXEFILES_RELEASE})
    endif()

    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/realsense2)

    file(GLOB BINS ${CURRENT_PACKAGES_DIR}/bin/*)
    if(NOT BINS)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
    
    # Issue#7109, remove mismatched dlls and libs when build with tools, this workaround should be removed when the post-build checks related feature implemented.
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/realsense2-gl.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/realsense2-gl.dll)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/realsense2-gl.pdb)
endif()

if(BUILD_OPENNI2_BINDINGS)
    file(GLOB RS2DRIVER ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/_out/rs2driver*)
    if(RS2DRIVER)
        file(COPY ${RS2DRIVER} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/openni2/OpenNI2/Drivers)
    endif()
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
