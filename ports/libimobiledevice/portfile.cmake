include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libimobiledevice
    REF 7cf5cb4b9675ddcaed5ea3d7ee2c8848da18d691 # v1.2.137
    SHA512 cfc32d3414af333d3410c292660b526f2339d210bc2cc3ddf1de87c951bff526c731c4d61609441b3c1ce8e2d1398e6d4c35fdae3e7434bfd5050e5975047a11
    HEAD_REF msvc-master
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH libimobiledevice.sln
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING
    REMOVE_ROOT_INCLUDES
    USE_VCPKG_INTEGRATION
)
