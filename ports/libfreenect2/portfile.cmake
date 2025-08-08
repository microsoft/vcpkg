vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenKinect/libfreenect2
    REF "v${VERSION}"
    SHA512 0fcee5471deb013d2b57581ef8d8838f652dfed2f457c4240d5b754674e949c59337a167ac74ad04b25ace69af470a7e014e0474a688d930a3323946feadee67
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

vcpkg_find_acquire_program(PKGCONFIG)

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(path_suffix "/debug")
endif()
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(path_suffix "")
endif()
vcpkg_backup_env_variables(VARS PKG_CONFIG_PATH)
vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}${path_suffix}/lib/pkgconfig")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DENABLE_CUDA=OFF
        -DBUILD_EXAMPLES=OFF
        ${FEATURE_OPTIONS}
)
vcpkg_restore_env_variables(VARS PKG_CONFIG_PATH)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME freenect2 CONFIG_PATH lib/cmake/freenect2)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/GPL2")

vcpkg_fixup_pkgconfig()
