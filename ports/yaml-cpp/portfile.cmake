# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/yaml-cpp-380ecb404ef99ba132154ed43dd2b84136b30b14)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/jbeder/yaml-cpp/archive/380ecb404ef99ba132154ed43dd2b84136b30b14.zip"
    FILENAME "380ecb404ef99ba132154ed43dd2b84136b30b14.zip"
    SHA512 7e090b53ba760f4f9a44701359fe2c30c05f1bbcd2cba78a8f9a88c651b09be6d592e65826fbacb9dd7317afbe3cd968be531b89f83e79f15cd97e9c27d17232
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Remove debug include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Remove cmake files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/CMake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/CMake)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/yaml-cpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/yaml-cpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/yaml-cpp/copyright)

