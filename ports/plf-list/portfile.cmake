set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_list
    REF e1b7b985f888ae54c19b54e0aaa2fddb08c3f35b
    SHA512 cd871125d32aa233d0134195c21ac9e6b3d2670dcdd78ff04551a174997682b80bdf33906d380a0e67e636cb1f0f0abc6eec48071559392f6c05987237b9ffed
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/plf_list.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
