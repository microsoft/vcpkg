vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/curl-simple-https
    REF             985f2e0ff4e0bb50423a2c1319eb4981d957f146
    SHA512          96319bfdcfed363522828f6036c14477499ed2132aaded34539050cd8c6a217a08f8ce6aee06d4ace0e882169897522bbad806df7e7c52b57b5da3454d15b7b1
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_CLI=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
