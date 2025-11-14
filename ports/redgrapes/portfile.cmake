vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ComputationalRadiationPhysics/redGrapes
    REF "ad87442"
    SHA512 9cd6f2331c804eaf7ceb871127e0c9bcf03fec82ba18a61c61ccbdafb05c816ed1b325f5b3866e6459a281f2b4554b866162c5a880f504896e6f76e0ba7e0173
    HEAD_REF dev
    PATCHES
        0001-change-moodycamel-concurrentqueue.h-to-include-concu.patch
)

file(INSTALL "${SOURCE_PATH}/redGrapes/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/redGrapes")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${SOURCE_PATH}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
