vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             f0b0dc259c81c8ba889576e8cb518343de015e0d
    SHA512          d81900bf2498d85058d88b9ecfa119abe33cd0e26fd367e3ef50b3f7909d2198046ced04de2acd984beac2e1d96b8641458b29f68612cc9c935b0f4f01ca762b
    HEAD_REF        master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/License.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
