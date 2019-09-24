include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kfrlib/kfr
    REF 11d9a1568b6157ebe6b4b44e121be8c9d3e587bf
    SHA512 09120b38bcd5e49ca83a14516ab678d0cb866cf08ca5dd33cc6701ac7db7cd73cd7a3f445b30085b4e1718d98a53497e4e9b27772224051f623ac3006fe409bf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTS=OFF
        -DENABLE_ASMTEST=OFF
        -DREGENERATE_TESTS=OFF
        -DKFR_EXTENDED_TESTS=OFF
        -DSKIP_TESTS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
