include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO embree/embree
    REF v2.16.4
    SHA512 235f7273044c8971eb7f7ecca5f4556d2e75ec958fc10d8861792fdd889a0e1c115bcf45bf6de7c2c44117032af96cd49a252399a2454627dcb82fd943222a01
    HEAD_REF devel2
)

file(REMOVE ${SOURCE_PATH}/common/cmake/FindTBB.cmake)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(EMBREE_STATIC_RUNTIME ON)
else()
    set(EMBREE_STATIC_RUNTIME OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
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

# these cmake files do not seem to contain helpful configuration for find libs, just remove them
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/embree-config.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/embree-config-version.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/embree-config.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/embree-config-version.cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/models)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/models)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/embree2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/doc ${CURRENT_PACKAGES_DIR}/share/embree2/doc)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/embree2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/embree2/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/embree2/copyright)
