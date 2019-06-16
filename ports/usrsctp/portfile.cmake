include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sctplab/usrsctp
    REF 35c1d97020a20014b989bba4f20225fd9429c4f4
    SHA512 18786825ec2c8c8aeb6b0bcab97deeac40420f7a9bdb427c891b26633ff759266409381ae2545c5572a740322ae1a56f80da1a784d71e50fce97177c343d27ce
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -Dsctp_werror=OFF -Dsctp_build_programs=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/lib/usrsctp.dll
    ${CURRENT_PACKAGES_DIR}/lib/usrsctp.dll
)

configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/usrsctp/copyright COPYONLY)

vcpkg_copy_pdbs()
