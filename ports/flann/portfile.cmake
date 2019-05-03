include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariusmuja/flann
    REF  aa40936816f4feaa714d3a09f92a495da017d95c
    SHA512 f6f2e75f4ce4bc4bc4cc1feab27fe683b8a5f9f5dcea35de4df5136a683b5dff5e68776008821a16ccf1a52a9807cb053c0062deba4fe121948248acd52864ef
    HEAD_REF master
    PATCHES
        use_lz4_targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_DOC=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DBUILD_MATLAB_BINDINGS=OFF
        -DCMAKE_DEBUG_POSTFIX=d
        -DHDF5_NO_FIND_PACKAGE_CONFIG_FILE=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/flann)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/flann/COPYING ${CURRENT_PACKAGES_DIR}/share/flann/copyright)
