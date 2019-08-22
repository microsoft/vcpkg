include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO embree/embree
    REF v3.5.2
    SHA512 f00403c8bc76428088a38990117245b5b11ac90a2df21fa12c2d5c2e8af45fb3708abb705c612e0d9d7b0cfe4edb51c8b9630b60081b39fcb4370f31ee37acc7
    HEAD_REF master
	PATCHES
		fix-InstallPath.patch
)

file(REMOVE ${SOURCE_PATH}/common/cmake/FindTBB.cmake)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(EMBREE_STATIC_RUNTIME ON)
else()
    set(EMBREE_STATIC_RUNTIME OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DEMBREE_ISPC_SUPPORT=OFF
        -DEMBREE_TUTORIALS=OFF
        -DEMBREE_STATIC_RUNTIME=${EMBREE_STATIC_RUNTIME}
        "-DTBB_LIBRARIES=TBB::tbb"
        "-DTBB_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include"
)

# just wait, the release build of embree is insanely slow in MSVC
# a single file will took about 2-10 min
vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
	vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/doc ${CURRENT_PACKAGES_DIR}/share/embree3/doc)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/embree3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/embree3/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/embree3/copyright)
