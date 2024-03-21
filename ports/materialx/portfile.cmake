vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/MaterialX
    REF "v${VERSION}"
    SHA512 e527c2d160502b79edc33e801351d2d40b6419b853aa6b3e8c4a54787006baed236829ec8e4db32469daffec8bc1aa1ba35588a49d414fb38feee36fac7e3fb7
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
        "-DMATERIALX_BUILD_GEN_GLSL:BOOL=NO"
        "-DMATERIALX_BUILD_GEN_OSL:BOOL=NO"
        "-DMATERIALX_BUILD_GEN_MDL:BOOL=NO"
        "-DMATERIALX_BUILD_RENDER:BOOL=NO"
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
    "${CURRENT_PACKAGES_DIR}/resources"
    "${CURRENT_PACKAGES_DIR}/debug/resources"
    "${CURRENT_PACKAGES_DIR}/include/MaterialXRender/External/OpenImageIO" 

    # Based on how OSL does it, it could be that those `.mdl` source would be better located inside `libraries/pbrlib/genmdl/**`
    # But it seems that they are instead installed into `libraries/mdl`
    "${CURRENT_PACKAGES_DIR}/include/MaterialXGenMdl/mdl"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
