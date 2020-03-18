
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF v2020.1
    SHA512 edd434e06cba44c402900684b8fea16c394f80951ff993b3962617a21630d2d8ff9be9a5203bc8eb9b402e9cafe8c68f13099cbc1eaf66a546df08cb43668c46
    PATCHES
        comment-distutils.patch
        cmake-install.patch
        install-config-typo.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPIRV-Headers_SOURCE_DIR=${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}
        -DSPIRV_WERROR=OFF
        -DENABLE_SPIRV_TOOLS_INSTALL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/SPIRV-Tools-link TARGET_PATH share/SPIRV-Tools-link)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/SPIRV-Tools-opt TARGET_PATH share/SPIRV-Tools-opt)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/SPIRV-Tools-reduce TARGET_PATH share/SPIRV-Tools-reduce)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin") # only static linkage, i.e. no need to preserve .dll/.so files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
