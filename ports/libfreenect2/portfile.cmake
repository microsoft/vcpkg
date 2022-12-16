vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenKinect/libfreenect2
    REF fd64c5d9b214df6f6a55b4419357e51083f15d93 #v0.2.1
    SHA512 34f3f407dbc47a73b4fec92965943ba403916898dcb38ccbc02205f027531fe07b60a13842ef4225d27f6a2e11ba7d5925064faeaea29b34062b6daaadc52839
    HEAD_REF master
    PATCHES
        fix-dependency-libusb.patch
        fix-macbuild.patch
)

file(READ "${SOURCE_PATH}/cmake_modules/FindLibUSB.cmake" FINDLIBUSB)
string(REPLACE "(WIN32)"
               "(WIN32_DISABLE)" FINDLIBUSB "${FINDLIBUSB}")
file(WRITE "${SOURCE_PATH}/cmake_modules/FindLibUSB.cmake" "${FINDLIBUSB}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opengl     ENABLE_OPENGL
        opencl     ENABLE_OPENCL
        openni2    BUILD_OPENNI2_DRIVER
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_CUDA=OFF
        -DBUILD_EXAMPLES=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME freenect2 CONFIG_PATH lib/cmake/freenect2)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/GPL2" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
