vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lfreist/hwinfo
    REF 5cb31dbdb2c40413a837ce52ffadee23578c9069
    SHA512 7c431528d5bf2f91843a3f6f8de908f6bc5b1427f85961bb885ab95e7765a875cb0358638e0e1e1f9a9336476ba74dc22819c97189251391fd8459c334c1092a
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNO_OCL=TRUE # disable OpenCL usage
    MAYBE_UNUSED_VARIABLES
        NO_OCL
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
