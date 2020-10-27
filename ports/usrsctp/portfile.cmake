vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sctplab/usrsctp
    REF 0db969100094422d9ea74a08ae5e5d9a4cfdb06b
    SHA512 53993d663b6899896409cb4cdbbb6d41a9eccba012b032773708be90c16e3d617b3c3256ea624dc3e984dc7099f69f3b7cd647c11e24abae4b77594e2cd64ef7
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dsctp_werror=OFF
        -Dsctp_build_programs=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/lib/usrsctp.dll
    ${CURRENT_PACKAGES_DIR}/lib/usrsctp.dll
)

configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/usrsctp/copyright COPYONLY)

vcpkg_copy_pdbs()
