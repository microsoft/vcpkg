# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH 
    REPO openMVG/openMVG
    REF v1.4
    SHA512 949cf3680375c87b06db0f4713c846422c98d1979d49e9db65761f63f6f3212f0fcd8425f23c6112f04fbbb90b241638c2fd9329bb6b8b612c1d073aac55759a
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR} fixcmake.patch)


# remove some deps to prevent conflict
file(REMOVE_RECURSE ${SOURCE_PATH}/src/third_party/ceres-solver)
file(REMOVE_RECURSE ${SOURCE_PATH}/src/third_party/cxsparse)
file(REMOVE_RECURSE ${SOURCE_PATH}/src/third_party/eigen)
file(REMOVE_RECURSE ${SOURCE_PATH}/src/third_party/flann)
file(REMOVE_RECURSE ${SOURCE_PATH}/src/third_party/jpeg)
file(REMOVE_RECURSE ${SOURCE_PATH}/src/third_party/lemon)
file(REMOVE_RECURSE ${SOURCE_PATH}/src/third_party/png)
file(REMOVE_RECURSE ${SOURCE_PATH}/src/third_party/tiff)
file(REMOVE_RECURSE ${SOURCE_PATH}/src/third_party/zlib)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OpenMVG_BUILD_SHARED ON)
else()
    set(OpenMVG_BUILD_SHARED OFF)
endif()


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    # PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    OPTIONS
        -DOpenMVG_BUILD_SHARED=${OpenMVG_BUILD_SHARED}
        -DOpenMVG_BUILD_DOC=OFF
        -DOpenMVG_BUILD_EXAMPLES=OFF
        -DOpenMVG_BUILD_SOFTWARES=OFF
        -DOpenMVG_BUILD_GUI_SOFTWARES=OFF
        # TODO, use packgeconfig.cmake file instead
        -DEIGEN_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include/
        -DCERES_DIR_HINTS=${CURRENT_INSTALLED_DIR}/ceres
        -DFLANN_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/flann
        -DLEMON_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include/lemon
        -DCOINUTILS_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include/coin
        -DCLP_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include/coin
        -DOSI_INCLUDE_DIR_HINTS=${CURRENT_INSTALLED_DIR}/include/coin
        -DOpenMVG_USE_INTERNAL_CLP=OFF
        -DOpenMVG_USE_INTERNAL_COINUTILS=OFF
        -DOpenMVG_USE_INTERNAL_OSI=OFF
        -DOpenMVG_USE_INTERNAL_EIGEN=OFF
        -DOpenMVG_USE_INTERNAL_CEREAL=OFF
        -DOpenMVG_USE_INTERNAL_CERES=OFF
        -DOpenMVG_USE_INTERNAL_FLANN=OFF
        -DTARGET_ARCHITECTURE=core # disable instruction like avx
    # OPTIONS_RELEASE -DOPTIMIZE=1
    OPTIONS_RELEASE
        -DFLANN_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/flann_cpp.lib
    OPTIONS_DEBUG 
        -DFLANN_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/flann_cpp-gd.lib
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "share/openMVG/cmake")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/openMVG/image/image_test)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/openMVG/exif/image_data)
file(GLOB REMOVE_CMAKE ${CURRENT_PACKAGES_DIR}/lib/*.cmake)
file(REMOVE_RECURSE ${REMOVE_CMAKE})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
if(OpenMVG_BUILD_SHARED)
    # release
    file(GLOB DLL_FILES  ${CURRENT_PACKAGES_DIR}/lib/*.dll)
    file(COPY ${DLL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${DLL_FILES})
    # debug
    file(GLOB DLL_FILES  ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
    file(COPY ${DLL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${DLL_FILES})
endif()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmvg RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME openmvg)
