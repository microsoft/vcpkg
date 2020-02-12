include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO embree/embree
    REF 539d4eec716085484f957d7b0d697b1891dafec4 # v3.8.0
    SHA512 77ab07cc7283f1a0c50d7cec07d1cbe4a24a41482b8b043f79a045953fccfa41a854bbc29a76beb67385d1bbb6d43097287ccfd3e1d2c84c1a5d55a2696d0815
    HEAD_REF master
    PATCHES
        fix-InstallPath.patch
        fix-cmake-path.patch
        fix-embree-path.patch
)

file(REMOVE ${SOURCE_PATH}/common/cmake/FindTBB.cmake)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(EMBREE_STATIC_RUNTIME ON)
else()
    set(EMBREE_STATIC_RUNTIME OFF)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(EMBREE_STATIC_LIB ON)
else()
    set(EMBREE_STATIC_LIB OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DEMBREE_ISPC_SUPPORT=OFF
        -DEMBREE_TUTORIALS=OFF
        -DEMBREE_STATIC_RUNTIME=${EMBREE_STATIC_RUNTIME}
        -DEMBREE_STATIC_LIB=${EMBREE_STATIC_LIB}
        "-DTBB_LIBRARIES=TBB::tbb"
        "-DTBB_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include"
)

# just wait, the release build of embree is insanely slow in MSVC
# a single file will took about 2-10 min
vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/embree3 TARGET_PATH share/embree)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
if (EXISTS ${CURRENT_PACKAGES_DIR}/uninstall.command)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/uninstall.command)
endif()
if (EXISTS ${CURRENT_PACKAGES_DIR}/debug/uninstall.command)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/uninstall.command)
endif()

file(RENAME ${CURRENT_PACKAGES_DIR}/share/doc ${CURRENT_PACKAGES_DIR}/share/embree/doc)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
