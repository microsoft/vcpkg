vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO shibatch/sleef
    REF ${VERSION}
    SHA512 218b4e7e2eeb1f9b45e56c2fbb46062480480c55f49b6b0d138d910374e7791c7dd909b964fbf9e2e984a896a3b162eb5aabaaa770692e1db440627e7ad07945
    HEAD_REF master
    PATCHES
        0001-Add-missing-exe-suffix-for-host-executables.patch
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

