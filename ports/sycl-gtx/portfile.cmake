# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sycl-gtx-master)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ProGTX/sycl-gtx/archive/master.zip"
    FILENAME "master.zip"
    SHA512 935db46460d7d768e52fd2c1ddd3ac8c6ad10ca8e5f1d45920fa130c83b7b9eb08b2c8c7f7150471f78bc03cb1130e54a26693806356ae0aaa2aa75f67345a09
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DOpenCL_LIBRARY=$ENV{OPENCL_LIBRARY} -DOpenCL_INCLUDE_DIR=$ENV{OPENCL_INCLUDE_DIR}
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/ProGTX/sycl-gtx/master/LICENSE"
    FILENAME "LICENSE"
    SHA512 cc13c86d851c55cc5de5329375ebe2f7624fdd17bd19fc0124e3da52471214aa2a3c912d989372a5874014a12212f295cee53fc0542fa5d2c271818ab544b03e
)

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/sycl-gtx-master/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sycl-gtx RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME sycl-gtx)
