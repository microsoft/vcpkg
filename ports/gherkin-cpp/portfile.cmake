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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ambrou/gherkin-cpp
    REF 7486a6869a5f58ef9eae48187cdd09706031fad2
    SHA512 bf5d068da2c9ef0bd08803ad8dd6a19bf84ca0765f9eeb8a83b7f12c1c5b854bdaa010d9843835124ca8a5eee3a877a41e30ced829165b7f07fb70520d53bae5
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DFMEM_INCLUDE=${VCPKG_ROOT_DIR}/packages/fmem_${TARGET_TRIPLET}/include -DGHERKIN_C_INCLUDE=${VCPKG_ROOT_DIR}/packages/gherkin-c_${TARGET_TRIPLET}/include
    #PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    OPTIONS_RELEASE -DFMEM_LIB=${VCPKG_ROOT_DIR}/packages/fmem_${TARGET_TRIPLET}/lib -DGHERKIN_C_LIB=${VCPKG_ROOT_DIR}/packages/gherkin-c_${TARGET_TRIPLET}/lib
    OPTIONS_DEBUG -DFMEM_LIB=${VCPKG_ROOT_DIR}/packages/fmem_${TARGET_TRIPLET}/debug/lib -DGHERKIN_C_LIB=${VCPKG_ROOT_DIR}/packages/gherkin-c_${TARGET_TRIPLET}/debug/lib
)


vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gherkin-cpp RENAME copyright)
