vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aubio/aubio
    REF 152d6819b360c2e7b379ee3f373d444ab3df0895
    SHA512 923529eb27e460293bd2b8b8c53d5eb96553e3e1ece7071904808d8f20f86b7af70bde97d271da9a07ee1898d0840190f265e326e67f48c6f5cadefa034abf0f
    HEAD_REF master
    PATCHES
        0001-ffmpeg-deprecated.patch
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
