# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustasMasiulis/nt_wrapper
    REF 6a150292a43f6aea35918a5c5e93a66c334ea301
    SHA512 fb8a1c4c934d3cb48a76a935ba69fd51ec2e6b66f5c265a8da9456691f933c6080057fec9a714f252c39d02525603b993cecd905452598058254ac9318655c4f
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
