vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/${PORT}
    REF             75942e15122c199b36c1468f8ce8e5b93d83cebc
    SHA512          45502c76a3960b43fe1e84bf58bf818bfa15d120a7cce5cd2d21e2ba34961498166226544ab01ab665765e6e7d095d48610e42110506856880b0de5d224c3575
    HEAD_REF        cmake
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/cmake/License.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
