vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             00936013ede328d39eb181c350c461e577ae42b0
    SHA512          be9d0f639ffeeb2712bdf81f08eda2a7eac85643ba71abf3d0a2e87b3097cc61ea323fa8d6246dd2753ccc27ab9e3624e81d4d8eca2cf6ac2a9e90e53200f040
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
