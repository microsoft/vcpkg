vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/dmon
    REF             f7d4067073153df16abd8705d0d7480f3f10f0d9
    SHA512          07985fc5b4538e2094f0f50ed1263a5562916f8d25fee8d9f9e8f9afaa9631d342363af56991b16476070347360d3e4b07de1c1c8cece7cad599290dae577073
    HEAD_REF        cmake-c89
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTS=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/dmon"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
