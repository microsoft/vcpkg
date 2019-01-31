include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ome/ome-common-cpp
    REF 385584990bb8a47d39d85b688d119d710d50d2b2
    SHA512 d749f726a25751cebe10a4cede5ed984eca55714bd8c022e4caab9ff4534a204fc725ae97161e20ef81981722191f8b07de01140b41f7115b7303750220d33f4
    HEAD_REF master
    PATCHES
      checks.patch
      cmakelists.patch
      platform.patch
      variant.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
       -Dtest:BOOL=OFF
       -Dextended-tests:BOOL=OFF
       -Drelocatable-install:BOOL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/OMECommon TARGET_PATH share/OMECommon)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/omecommon)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/omecommon/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/omecommon/copyright)
