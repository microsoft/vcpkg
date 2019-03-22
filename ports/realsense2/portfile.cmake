include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IntelRealSense/librealsense
    REF v2.19.0
    SHA512 c1fcb2b11827a5518b1e5196b7d1d2406447c6b2301809d3c66aaf69363a36f9789fd33595f581846809eba2c2540d3add964da03ecd96c804c7ca2b2df85180
    HEAD_REF development
    PATCHES
        libtm.patch
        windowsconfig.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_CRT_LINKAGE)

set(BUILD_EXAMPLES OFF)
set(BUILD_GRAPHICAL_EXAMPLES OFF)
if("tools" IN_LIST FEATURES)
    set(BUILD_EXAMPLES ON)
    set(BUILD_GRAPHICAL_EXAMPLES ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        # Ungrouped Entries
        -DENFORCE_METADATA=ON
        # BUILD
        -DBUILD_WITH_STATIC_CRT=${BUILD_CRT_LINKAGE}
        -DBUILD_WITH_TM2=OFF
    OPTIONS_RELEASE
        # BUILD
        -DBUILD_EXAMPLES=${BUILD_EXAMPLES}
        -DBUILD_GRAPHICAL_EXAMPLES=${BUILD_GRAPHICAL_EXAMPLES}
    OPTIONS_DEBUG
        # BUILD
        -DBUILD_EXAMPLES=OFF
        -DBUILD_GRAPHICAL_EXAMPLES=OFF
        # CMAKE
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/realsense2)
vcpkg_copy_pdbs()

file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libtm_util.exe)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/libtm_util.exe)

if(BUILD_EXAMPLES)
    file(GLOB EXEFILES_RELEASE ${CURRENT_PACKAGES_DIR}/bin/rs-* ${CURRENT_PACKAGES_DIR}/bin/realsense-*)
    if (EXEFILES_RELEASE)
        file(COPY ${EXEFILES_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/realsense2)
        file(REMOVE ${EXEFILES_RELEASE})
    endif()

    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/realsense2)

    file(GLOB BINS ${CURRENT_PACKAGES_DIR}/bin/*)
    if(NOT BINS)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/realsense2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/realsense2/LICENSE ${CURRENT_PACKAGES_DIR}/share/realsense2/copyright)
