if(VCPKG_CRT_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "Ceres does not currently support static CRT linkage")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ceres-solver/ceres-solver
    REF 1.13.0
    SHA512 b548a303d1d4eeb75545551c381624879e363a2eba13cdd998fb3bea9bd51f6b9215b579d59d6133117b70d8bf35e18b983400c3d6200403210c18fcb1886ebb
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-find-packages.patch
)

# Ninja crash compiler with error:
# "fatal error C1001: An internal error has occurred in the compiler. (compiler file 'f:\dd\vctools\compiler\utc\src\p2\main.c', line 255)"

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DEXPORT_BUILD_DIR=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DCXSPARSE=ON
        -DEIGENSPARSE=ON
        -DSUITESPARSE=ON
        -DGFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION=OFF # TheiaSfm doesn't work well with this
        -DGLOG_PREFER_EXPORTED_GLOG_CMAKE_CONFIGURATION=OFF # TheiaSfm doesn't work well with this
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake")

vcpkg_copy_pdbs()

# Changes target search path
file(READ ${CURRENT_PACKAGES_DIR}/share/ceres/CeresConfig.cmake CERES_TARGETS)
string(REPLACE "get_filename_component(CURRENT_ROOT_INSTALL_DIR\n    \${CERES_CURRENT_CONFIG_DIR}/../"
               "get_filename_component(CURRENT_ROOT_INSTALL_DIR\n    \${CERES_CURRENT_CONFIG_DIR}/../../" CERES_TARGETS "${CERES_TARGETS}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/ceres/CeresConfig.cmake "${CERES_TARGETS}")

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright of suitesparse and metis
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ceres)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ceres/LICENSE ${CURRENT_PACKAGES_DIR}/share/ceres/copyright)
