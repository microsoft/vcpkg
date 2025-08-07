vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/ctsTraffic
    REF 88a415197951912fc70e440b31cad8d4ff4ea68a
    SHA512 152ee25d1ba70c68c5bae61ee08d1d2905efd28a10c48672de852c8ee9d0964a9202814cdcc40bca712ef69f952630509810827226861dad16516f5e0827d879
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # Windows port only includes tools.

include("${CURRENT_PORT_DIR}/prepare_for_build.cmake")
prepare_for_build("${SOURCE_PATH}")

vcpkg_list(SET MSBUILD_OPTIONS
    "/p:UseVcpkg=yes"
)

vcpkg_msbuild_install(
  SOURCE_PATH "${SOURCE_PATH}"
  PROJECT_SUBPATH ctsTraffic/ctsTraffic.vcxproj
  OPTIONS 
    ${MSBUILD_OPTIONS}
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
