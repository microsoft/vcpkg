# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_colony
    REF abb0aa6525a3dae56aacf50899517f47e7036016
    SHA512 6a854827b29f4c7fd6d7bae2b62d0b86064cb56ca5484fb262dfe7402a0da3a29834ebc075693bc5d3f9d348ee5b7dc5ae974b7b477bd3409c0927ce15961bd9
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/plf_colony.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
