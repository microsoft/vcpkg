include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO muflihun/easyloggingpp
    REF v9.96.5
    SHA512 51493693095df03f8772174a8ec4fc681832319bd723224a544539efdcf73c7653d3973ec0ae0cd004e496bf98c105c278e4a72694ebf34b207c658b3225a87b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dbuild_static_lib=ON
)
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/easyloggingpp RENAME copyright)
