vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             73e969074e20dbe91b0148ec96024bb7e9a40840
    SHA512          4b2addbef89516b55ab7f5ab905b9c0faf3a12aff7ad405751b17d577eea8f987d72c19246ed49fe11a148b7a0a862dcfc5e845c0eabea8bcc7d8184e4d1c23d
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
