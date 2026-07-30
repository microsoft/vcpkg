vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/ideep
    REF e087b6e4b32a7ba684db82231d1558123968ac1d
    SHA512 7458481aafc066a5e73bc4406b7309c93cbc9ec2c9f3d298cb43a10418f751ca7c5638fb2195d38b484e07c1975b1b27ba7ff3876bfca2afe86fb3abab05a120
    HEAD_REF master
    PATCHES
        fix-missing-cassert-include.patch
)

# Header-only library: install the include tree directly.
file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# ideep/python/binding.hpp defines a pybind11 extension module. It pulls in
# pybind11 headers, which this port does not depend on, and its functions are
# not declared inline, so it can only ever be compiled into a single
# translation unit. Nothing else in ideep includes it, so drop it rather than
# taking on a pybind11 dependency for a header no consumer of this port can use.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/ideep/python")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
