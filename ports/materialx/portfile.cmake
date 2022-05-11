vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/MaterialX
    REF b1ba83b312576fc58f02a6a7db40b18ddbe4f87f # 1.38.4
    SHA512 3988c42d487e391f9f0f3ab5f34eaa26c7f450079695d96954b871e078eecfe692daa9917279560ba3f10bf771685df3da6e26273d575a23a11c3d17fb897c62
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OPTION_BUILD_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DMATERIALX_BUILD_SHARED_LIBS:BOOL=${OPTION_BUILD_SHARED_LIB}

        -DMATERIALX_BUILD_JS:BOOL=NO
        -DMATERIALX_BUILD_PYTHON:BOOL=NO
        -DMATERIALX_BUILD_VIEWER:BOOL=NO
        -DMATERIALX_BUILD_DOCS:BOOL=NO
        -DMATERIALX_BUILD_GEN_GLSL:BOOL=NO
        -DMATERIALX_BUILD_GEN_OSL:BOOL=NO
        -DMATERIALX_BUILD_GEN_MDL:BOOL=NO
        -DMATERIALX_BUILD_RENDER:BOOL=NO
        -DMATERIALX_BUILD_OIIO:BOOL=NO
        -DMATERIALX_BUILD_TESTS:BOOL=NO

        -DMATERIALX_PYTHON_LTO:BOOL=NO
        -DMATERIALX_INSTALL_PYTHON:BOOL=NO
        -DMATERIALX_TEST_RENDER:BOOL=NO
        -DMATERIALX_WARNINGS_AS_ERRORS:BOOL=NO
    MAYBE_UNUSED_VARIABLES
        MATERIALX_PYTHON_LTO # Used when MATERIALX_BUILD_PYTHON=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME MaterialX CONFIG_PATH lib/cmake/MaterialX)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/CHANGELOG.md
    ${CURRENT_PACKAGES_DIR}/LICENSE
    ${CURRENT_PACKAGES_DIR}/README.md
    ${CURRENT_PACKAGES_DIR}/THIRD-PARTY.md
    ${CURRENT_PACKAGES_DIR}/debug/CHANGELOG.md
    ${CURRENT_PACKAGES_DIR}/debug/LICENSE
    ${CURRENT_PACKAGES_DIR}/debug/README.md
    ${CURRENT_PACKAGES_DIR}/debug/THIRD-PARTY.md
    ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
