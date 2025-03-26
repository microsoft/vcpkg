vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO shibatch/sleef
    REF ${VERSION}
    SHA512 9b47667b33a685308aa65f848b7ee620e9e8783ca4851fd57e873f34310b486fb351813f573f2a7a71b6bdc5c8b2c5ef4eb4f66c890ddfbfada7bb9d74626c0b
    HEAD_REF master
)

set(CROSSCOMP_OPTIONS "")
if(VCPKG_CROSSCOMPILING)
    set(CROSSCOMP_OPTIONS "-DNATIVE_BUILD_DIR=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSLEEF_BUILD_LIBM=ON
        -DSLEEF_BUILD_DFT=ON
        -DSLEEF_BUILD_QUAD=ON
        -DSLEEF_BUILD_GNUABI_LIBS=${VCPKG_TARGET_IS_LINUX}
        -DSLEEF_BUILD_TESTS=OFF
        -DSLEEF_ENABLE_TLFLOAT=OFF
        -DSLEEF_ENABLE_TESTER4=OFF
        -DSLEEF_DISABLE_MPFR=ON
        ${CROSSCOMP_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
if(NOT VCPKG_CROSSCOMPILING)
    vcpkg_copy_tools(
        TOOL_NAMES mkrename qmkrename mkalias mkdispatch mkdisp qmkdisp mkunroll 
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/bin"
        AUTO_CLEAN)
endif()    
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sleef)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

