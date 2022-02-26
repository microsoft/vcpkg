vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             7fda52d6c26146e0be6bb6c7e194bfbaf64fc249
    SHA512          606871d8c83143802c014ee1551ecc922d810499e922c2e552776c17aa2ed4ddf8c1ff80b7ce30dc7c0bade9f602bef4b2e7c0f53b68918598954d81c67905d3
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
