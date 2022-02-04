vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/cauthflow
    REF             44581e272f9b55023639abb4a1fa154bb4ee74ce
    SHA512          814071d9d419033d7c8abe78bf1b4427454c94b6e0f937f27d9d61faf7c299d2f4405aa5636c3e2fdf0c36972f435c541f967f57991a224b06c30758ccc652ca
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
