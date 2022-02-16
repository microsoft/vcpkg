vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/curl-simple-https
    REF             285ebd918e55f8bfd2291773f3f0611554ddf214
    SHA512          3e613de7f011b24754767b3d07e7608a80e0c2440a98eaf5d812133a3062a4ea2b7eeedac603f231eae5acb7950312cabb0a144f430660e656c46c038c7364aa
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
foreach(_dir "include" "share")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/${_dir}")
endforeach(_dir "include" "share")
