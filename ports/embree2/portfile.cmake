vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO embree/embree
    REF v2.17.7
    SHA512 3ea548e5ed85f68dc1f9dfe864711f9b731e0df8a2258257f77db08bbdbe3a9014a626313e3ff41174f3b26f09dc8ff523900119ff4c8465bfff53f621052873
    HEAD_REF devel2
    PATCHES
        cmake_policy.patch
)

file(REMOVE "${SOURCE_PATH}/common/cmake/FindTBB.cmake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" EMBREE_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" EMBREE_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DEMBREE_ISPC_SUPPORT=OFF
        -DEMBREE_TUTORIALS=OFF
        -DEMBREE_STATIC_LIB=${EMBREE_STATIC_LIB}
        -DEMBREE_STATIC_RUNTIME=${EMBREE_STATIC_RUNTIME}
        "-DTBB_LIBRARIES=TBB::tbb"
        "-DTBB_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include"
)

# just wait, the release build of embree is insanely slow in MSVC
# a single file will took about 2-10 min
vcpkg_cmake_install()
vcpkg_copy_pdbs()

# these cmake files do not seem to contain helpful configuration for find libs, just remove them
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/embree-config.cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/embree-config-version.cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/embree-config.cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/embree-config-version.cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake" "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/uninstall.command" "${CURRENT_PACKAGES_DIR}/debug/uninstall.command")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/models")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/models")

if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/embree2")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/doc" "${CURRENT_PACKAGES_DIR}/share/embree2/doc")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
