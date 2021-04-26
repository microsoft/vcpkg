set(OATPP_VERSION "1.2.5")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp
    REF 9899786b235b2d987c8b131cdb01909727b98d4f  # 1.2.5
    SHA512 b5d1d6e2e2927f929aa3c7ac7fbc8afd491c28391d54d77647700982217ed17a00b96886cd314058003e103d3d7992f30fd0ab26f6cfce4ed26e12e0b6c9fd4c
    HEAD_REF master
    PATCHES
        fix-identifier-not-found.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
        "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"       
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
