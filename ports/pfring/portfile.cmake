vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ntop/PF_RING
    REF "${VERSION}"
    SHA512 fc540d31027fc3a674a874c22bcbecb2b5ed6c7c7af534e876e6a2a2679cffc391a031e30d307b4e8fe294170ba5f5691fe3630cb131190db035b06f50a03d60
    HEAD_REF dev
)

file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/kernel")
file(COPY "${SOURCE_PATH}/kernel/linux/pf_ring.h" DESTINATION "${CURRENT_BUILDTREES_DIR}/kernel/linux")

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "userland"
    COPY_SOURCE
    OPTIONS
        --disable-archopt
)
string(REPLACE "dynamic" "shared" install_target "install-${VCPKG_LIBRARY_LINKAGE}")
vcpkg_install_make(
    SUBPATH "lib"
    INSTALL_TARGET "${install_target}"
    OPTIONS
        "LEX=${FLEX}"
        "YACC=${BISON}"
)

vcpkg_install_copyright(
    COMMENT [[
The user-space PF_RING library source code is distributed under the LGPLv2.1.
The library is built using binary objects from the userland/lib/libs directory
which adds an NTOP END USER LICENSE AGREEMENT.
]]
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/userland/lib/libs/EULA.txt"
)
