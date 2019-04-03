include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IntelRealSense/librealsense
    REF v2.16.1
    SHA512 e030f7b1833db787b8976ead734535fb2209a19317d74d4f68bd8f8cae38abe2343d584e88131a1a66bf6f9f1c0a17bc2c64540841a74cf6300fecf3e69f9dff
    HEAD_REF development
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_LIBRARY_LINKAGE)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_CRT_LINKAGE)

set(BUILD_EXAMPLES OFF)
set(BUILD_GRAPHICAL_EXAMPLES OFF)
if("tools" IN_LIST FEATURES)
  set(BUILD_EXAMPLES ON)
  set(BUILD_GRAPHICAL_EXAMPLES ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        #Ungrouped Entries
        -DENFORCE_METADATA=ON
        # BUILD
        -DBUILD_EXAMPLES=${BUILD_EXAMPLES}
        -DBUILD_GRAPHICAL_EXAMPLES=${BUILD_GRAPHICAL_EXAMPLES}
        -DBUILD_SHARED_LIBS=${BUILD_LIBRARY_LINKAGE}
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_WITH_OPENMP=OFF
        -DBUILD_WITH_STATIC_CRT=${BUILD_CRT_LINKAGE}
    OPTIONS_DEBUG
        # BUILD
        -DBUILD_EXAMPLES=OFF
        -DBUILD_GRAPHICAL_EXAMPLES=OFF
        # CMAKE
        -DCMAKE_PDB_OUTPUT_DIRECTORY=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        -DCMAKE_DEBUG_POSTFIX=_d
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/realsense2)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(BUILD_EXAMPLES)
    file(GLOB EXEFILES_RELEASE ${CURRENT_PACKAGES_DIR}/bin/rs-* ${CURRENT_PACKAGES_DIR}/bin/realsense-*)
    if (EXEFILES_RELEASE)
        file(COPY ${EXEFILES_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/realsense2)
        file(REMOVE ${EXEFILES_RELEASE})
    endif()
    file(GLOB EXEFILES_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*)
    if (EXEFILES_DEBUG)
        file(REMOVE ${EXEFILES_RELEASE} ${EXEFILES_DEBUG})
    endif()
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/realsense2)

    file(GLOB BINS ${CURRENT_PACKAGES_DIR}/bin/*)
    if(NOT BINS)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/realsense2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/realsense2/COPYING ${CURRENT_PACKAGES_DIR}/share/realsense2/copyright)
