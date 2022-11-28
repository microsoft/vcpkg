vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/${PORT}
    REF             23e1ba0e7d4cc69762e3a98b72de057bf0cbc309
    SHA512          6e9a83558510c5506b59ac4df08e0c7be771ae98541284d11feaf1af0c5655e7b7eba0e94eca781c11734e274d21ca866c578186b46d78dabed7155c76396afd
    HEAD_REF        cmake
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/cmake/License.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
