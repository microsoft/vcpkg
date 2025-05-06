vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IfcOpenShell/IfcOpenShell
    REF "v${VERSION}"
    SHA512 4ae5f3f007de0f1bce34fb2d51bca53bad80e83243f9702f4bf5c5878eb9bf16d8d6b3954a5c361fa82800c85384ea97000188afbbb2fb3f5c1a5878a57fa705
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        fix-boost.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "minimal" MINIMAL_BUILD
        "wasm" WASM_BUILD
        "optimizations" ENABLE_BUILD_OPTIMIZATIONS
        "parallel" MSVC_PARALLEL_BUILD
        "vld" USE_VLD
        "mmap" USE_MMAP
        "package" BUILD_PACKAGE
        "hdf5" HDF5_SUPPORT
        "ifcxml" IFCXML_SUPPORT
        "usd" USD_SUPPORT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_EXAMPLES=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_IFCGEOM=OFF
        -DBUILD_CONVERT=OFF
        -DBUILD_GEOMSERVER=OFF
        -DBUILD_IFCPYTHON=OFF
        -DBUILD_QTVIEWER=OFF
        -DGLTF_SUPPORT=OFF
        -DCOLLADA_SUPPORT=OFF
        -DBUILD_IFCMAX=OFF
        -DUSERSPACE_PYTHON_PREFIX=OFF
        -DADD_COMMIT_SHA=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# set(TOOL_NAMES_LIST idyntree-model-info)
# if ("assimp" IN_LIST FEATURES)
#     list(APPEND TOOL_NAMES_LIST idyntree-model-simplify-shapes)
# endif()
# if ("irrlicht" IN_LIST FEATURES)
#     list(APPEND TOOL_NAMES_LIST idyntree-model-view)
# endif()
# vcpkg_copy_tools(
#     TOOL_NAMES ${TOOL_NAMES_LIST}
#     AUTO_CLEAN
# )

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
