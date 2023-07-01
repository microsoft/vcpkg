vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/freebsd-getopt-portable
    REF             ee3cd0359cc50ec5ce30b4ce924cc23cdca0817b
    SHA512          2227932b82f2bbb5ad1f839787f49875fcbef8ca7a22cab66ec5975d05fd3a5707d24ca72085c293363c94c5c80d2cffeee10ca625a0e599bd2a3dc7665b1cec
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS "enabled")

