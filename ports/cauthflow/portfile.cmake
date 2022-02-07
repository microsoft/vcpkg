vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             5b9329398105572fcacdcca06d2ef02b4e68412d
    SHA512          fd57d5af80dc777373f07c10f6d43c100eb4849e345a66071a807d9f4da0fb92337c9bda8e0f3f4bbff0bda03d0bfbd17d4af62019e7dd39059b3d580923a87d
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
