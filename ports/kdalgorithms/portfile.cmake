# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDAlgorithms
    REF ${VERSION}
    SHA512 5d877b8aa16aae870276a542554aa1b39ae2daa863e77ebaa248ca1427a92179611dd7c7cd98e88fc6a406905f404f052f9c891b8a49d64582dfc2ba857118f6
)

file(INSTALL "${SOURCE_PATH}/src/kdalgorithms.h" "${SOURCE_PATH}/src/kdalgorithms_bits"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
