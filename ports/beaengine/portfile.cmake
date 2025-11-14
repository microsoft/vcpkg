vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BeaEngine/beaengine
    REF "v${VERSION}"
    SHA512 df3e1b937cce8dd79e41ce0fd6dbb263b71ec0bff27bc1b9329e12bce401e42567d4b5bb4e22a5880cfcc43d0615e6e49669993e6797def47011748ed9cdfdb4
    HEAD_REF master
    PATCHES
        0001-CMakeLists.patch
        0002-support-install.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/beaengine-config.cmake.in" DESTINATION "${SOURCE_PATH}/src")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic"   BEAENGINE_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DoptBUILD_DLL=${BEAENGINE_BUILD_SHARED}
        -DVERSION=${VERSION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/src/COPYING.txt" "${SOURCE_PATH}/src/COPYING.LESSER.txt")
