vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             efa65b7b2b9b65e3b92b3a99d552005c33773139
    SHA512          c7c7b28d91f6edf5fe3acb89514b9396ce5078a9f332b79b4fda2362fd98d475042836dfa94018d5792d53bbf1ee47faa1694a85ce4734b3f46dabfab4f2ade4
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
