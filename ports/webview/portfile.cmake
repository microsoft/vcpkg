vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webview/webview
    REF "${VERSION}"
    SHA512 f198e414145101693fd2b5724fb017df578770c6edda319ce312cf9e9e1fdc1b1d94beba2e64e75d9746dee16010cc525be8ae7ca0713ee541b75a0a1d9bc791
    HEAD_REF master
    PATCHES 001_use_system_webview2.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWEBVIEW_BUILD_DOCS=OFF
        -DWEBVIEW_BUILD_TESTS=OFF
        -DWEBVIEW_BUILD_EXAMPLES=OFF
        -DWEBVIEW_ENABLE_CHECKS=OFF
        -DWEBVIEW_ENABLE_PACKAGING=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
