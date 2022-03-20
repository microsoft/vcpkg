vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             f1b7b6ac389935d664e901a58a1a61eb7a977e92
    SHA512          ca70ff9180926310e742ed2c069a546bf467b41ae4b7fc8c2bec133287628b5839fa38c34adfce2ec36cf45e7332120257bcdfb0bf29574d798b18a97c32117b
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
