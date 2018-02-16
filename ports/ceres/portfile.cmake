set(MSVC_USE_STATIC_CRT_VALUE OFF)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
	if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
	    message(FATAL_ERROR "Ceres does not currently support mixing static CRT and dynamic library linkage")
	endif()
	set(MSVC_USE_STATIC_CRT_VALUE ON)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ceres-solver/ceres-solver
    REF 1.13.0
    SHA512 b548a303d1d4eeb75545551c381624879e363a2eba13cdd998fb3bea9bd51f6b9215b579d59d6133117b70d8bf35e18b983400c3d6200403210c18fcb1886ebb
    HEAD_REF master
)

# Ninja crash compiler with error:
# "fatal error C1001: An internal error has occurred in the compiler. (compiler file 'f:\dd\vctools\compiler\utc\src\p2\main.c', line 255)"

set(SUITESPARSE OFF)
if("suitesparse" IN_LIST FEATURES)
    set(SUITESPARSE ON)
endif()

set(CXSPARSE OFF)
if("cxsparse" IN_LIST FEATURES)
    set(CXSPARSE ON)
endif()

set(LAPACK OFF)
if("lapack" IN_LIST FEATURES)
    set(LAPACK ON)
endif()

set(EIGENSPARSE OFF)
if("eigensparse" IN_LIST FEATURES)
    set(EIGENSPARSE ON)
endif()

set(GFLAGS OFF)
if("tools" IN_LIST FEATURES)
    set(GFLAGS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DEXPORT_BUILD_DIR=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DGFLAGS=${GFLAGS}
        -DCXSPARSE=${CXSPARSE}
        -DEIGENSPARSE=${EIGENSPARSE}
        -DLAPACK=${LAPACK}
        -DSUITESPARSE=${SUITESPARSE}
        -DGFLAGS_PREFER_EXPORTED_GFLAGS_CMAKE_CONFIGURATION=OFF # TheiaSfm doesn't work well with this
        -DGLOG_PREFER_EXPORTED_GLOG_CMAKE_CONFIGURATION=OFF # TheiaSfm doesn't work well with this
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT_VALUE}
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
