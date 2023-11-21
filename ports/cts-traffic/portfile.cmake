vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/ctsTraffic
    REF 4fe77d045fd69573d7f4056fe7ac73182b802fb1
    SHA512 179f6ad744063581f57b2a473f04e30a7db32a9c199ee9caad4616dbb2c28c9652adc110a8de915c946713bd7659d29e8d5732d0d9d0516934bcba5403e8c50c
    HEAD_REF master
)

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

vcpkg_copy_pdbs()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")