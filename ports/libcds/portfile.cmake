include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO khizmax/libcds
    REF v2.3.2
    SHA512 f8313f85ae2950a008245603296b63bdbb2f58ead1a453fb287a8ecb96b79edc5b2f8fe33d6027dbc7ead6ccd1bb7ca8dd830091a86760358bb812a39b4ba83f
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/cmake-install.patch
        ${CMAKE_CURRENT_LIST_DIR}/lib-suffix-option.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DISABLE_INSTALL_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DISABLE_INSTALL_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_UNIT_TEST=OFF
        -DENABLE_STRESS_TEST=OFF
        -DDISABLE_INSTALL_STATIC=${DISABLE_INSTALL_STATIC}
        -DDISABLE_INSTALL_SHARED=${DISABLE_INSTALL_SHARED}
        "-DLIB_SUFFIX="
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/LibCDS)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcds RENAME copyright)

vcpkg_copy_pdbs()
