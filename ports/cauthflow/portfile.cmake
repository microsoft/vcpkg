vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             78eaaf7ac1ff9dc79c9f4a9ae7b5f4eb87287943
    SHA512          f57e8ea6f3dc3546fc989e55213fd65b9bc9d8534c8be59613bea2791153366dc805a462b941e2b57432eb18e8e5cca536a5723c00aaf82b80962c2d1a198461
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
