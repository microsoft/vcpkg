vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IntelRealSense/librealsense
    REF 842ee1e1e5c4bb96d63582a7fde061dbc1bebf69#v2.33.1
    SHA512 70f6f9c2f1c5925532b2ff22779579b3610a7f616d66ac92e8e85c6f30df334bf8fb125355a0706bacef0be8370acc62bb7623f3f200326e71fe53e07726fa6a
    HEAD_REF master
    PATCHES
        fix_openni2.patch
        fix-dependency-glfw3.patch
        fix-tools-compile-on-vs2019.patch
)

file(COPY ${SOURCE_PATH}/src/win7/drivers/IntelRealSense_D400_series_win7.inf DESTINATION ${SOURCE_PATH})
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_CRT_LINKAGE)

set(BUILD_TOOLS OFF)
if("tools" IN_LIST FEATURES)
    set(BUILD_TOOLS ON)
endif()

set(BUILD_OPENNI2_BINDINGS OFF)
if(("openni2" IN_LIST FEATURES) AND (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic"))
  set(BUILD_OPENNI2_BINDINGS ON)
endif()

set(BUILD_WITH_TM2 OFF)
if("tm2" IN_LIST FEATURES)
    set(BUILD_WITH_TM2 ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENFORCE_METADATA=ON
        -DBUILD_WITH_TM2=${BUILD_WITH_TM2}
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
