vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knik0/faac
    REF 78d8e0141600ac006a94ac6fd5601f # 1_30
    SHA512 bf206165dea9ac1f005a8880570e5e93499a2a1f880867ed861303f3954a392e61f640dddfd45585d1a9e054fab463ca195fb38989a273d5f56d984c282ff02a
    HEAD_REF master
    PATCHES
        fix-dll-export.patch
        fix-gcc-build.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cli   FAAC_BUILD_BINARIES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if("cli" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES faac_cli AUTO_CLEAN)
endif()

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/Makefile.am")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
