vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IfcOpenShell/IfcOpenShell
    REF "v${VERSION}"
    SHA512 7edd84dcdad5ecf6413824dd28ce65884ab1e422fb708be3297e83f984c0a9ba633d6013d046543bf645f6fc43d80f4fa07c5558e3a152c087b213ba01603801
    HEAD_REF master
    PATCHES fix-build.patch
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
        "opencascade" WITH_OPENCASCADE
        "cgal" WITH_CGAL
        "hdf5" HDF5_SUPPORT
        "proj" WITH_PROJ
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
        -DCITYJSON_SUPPORT=OFF
        -DGLTF_SUPPORT=OFF
        -DCOLLADA_SUPPORT=OFF
        -DBUILD_IFCMAX=OFF
        -DWITH_RELATIONSHIP_VALIDATION=OFF
        -DUSERSPACE_PYTHON_PREFIX=OFF
        -DADD_COMMIT_SHA=OFF
        -DVERSION_OVERRIDE=OFF
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
