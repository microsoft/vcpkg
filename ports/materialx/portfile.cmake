vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/MaterialX
    REF "v${VERSION}"
    SHA512 ca743e619f51bddd67419c79a31e9fb92dd7883e8c182897c1d8cea2e5dc51cddf13ac8cc798cfa0f022dacf4fd77881aefc24f3184f8b7273651ba55c7df400
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        glsl-generator MATERIALX_BUILD_GEN_GLSL
        mdl-generator  MATERIALX_BUILD_GEN_MDL
        osl-generator  MATERIALX_BUILD_GEN_OSL
        render         MATERIALX_BUILD_RENDER
)
if ((VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_LINUX) AND MATERIALX_BUILD_RENDER)
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n    libx11-dev\n\nThese can be installed on Ubuntu systems via apt-get install libx11-dev.")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OPTION_BUILD_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        "-DMATERIALX_BUILD_SHARED_LIBS:BOOL=${OPTION_BUILD_SHARED_LIB}"
        "-DMATERIALX_BUILD_JS:BOOL=NO"
        "-DMATERIALX_BUILD_PYTHON:BOOL=NO"
        "-DMATERIALX_BUILD_VIEWER:BOOL=NO"
        "-DMATERIALX_BUILD_DOCS:BOOL=NO"
        "-DMATERIALX_BUILD_OIIO:BOOL=NO"
        "-DMATERIALX_BUILD_TESTS:BOOL=NO"
        "-DMATERIALX_PYTHON_LTO:BOOL=NO"
        "-DMATERIALX_INSTALL_PYTHON:BOOL=NO"
        "-DMATERIALX_TEST_RENDER:BOOL=NO"
        "-DMATERIALX_WARNINGS_AS_ERRORS:BOOL=NO"
    MAYBE_UNUSED_VARIABLES
        MATERIALX_PYTHON_LTO # Used when MATERIALX_BUILD_PYTHON=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME MaterialX CONFIG_PATH lib/cmake/MaterialX)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/CHANGELOG.md"
    "${CURRENT_PACKAGES_DIR}/LICENSE"
    "${CURRENT_PACKAGES_DIR}/README.md"
    "${CURRENT_PACKAGES_DIR}/THIRD-PARTY.md"
    "${CURRENT_PACKAGES_DIR}/debug/CHANGELOG.md"
    "${CURRENT_PACKAGES_DIR}/debug/LICENSE"
    "${CURRENT_PACKAGES_DIR}/debug/README.md"
    "${CURRENT_PACKAGES_DIR}/debug/THIRD-PARTY.md"
    "${CURRENT_PACKAGES_DIR}/debug/include"

    # MaterialXGenShader explicitely install resources
    "${CURRENT_PACKAGES_DIR}/include/MaterialXRender/External/OpenImageIO" 

    # Based on how OSL does it, it could be that those `.mdl` source would be better located inside `libraries/pbrlib/genmdl/**`
    # But it seems that they are instead installed into `libraries/mdl`
    "${CURRENT_PACKAGES_DIR}/include/MaterialXGenMdl/mdl"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
