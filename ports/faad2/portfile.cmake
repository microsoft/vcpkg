vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knik0/faad2
    REF "${VERSION}"
    SHA512 8df69278350c68dd770c4bc482e42bc95eb04cd784eeea3f3fc58d615833c8b07dc3c72029bb7e5bfed612b7c1b8daefc9cb57be9789befb587120ef115e55b3
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    build-decoder   FAAD_BUILD_BINARIES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()

if("build-decoder" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES faad_decoder AUTO_CLEAN)
endif()

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
