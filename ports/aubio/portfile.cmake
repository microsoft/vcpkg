vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aubio/aubio
    REF 8a05420e5dd8c7b8b2447f82dc919765876511b3
    SHA512 080775d7b972d31d88671b4a2917e926bc933b7bdc50fc56a4a8e3174b4544fd6fd416c06b064488cea777cbdd4eea63d0b35eca0025f53ab71da0ba8b64824f
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools WITH_DEPENDENCIES
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${FEATURE_OPTIONS}
  OPTIONS_RELEASE
    -DTOOLS_INSTALLDIR=tools/aubio
    -DBUILD_TOOLS=ON
  OPTIONS_DEBUG
    -DBUILD_TOOLS=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES aubiomfcc aubionotes aubioonset aubiopitch aubioquiet aubiotrack
        SEARCH_DIR ${CURRENT_PACKAGES_DIR}/tools/aubio
        AUTO_CLEAN)
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
