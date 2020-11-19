vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} currently doesn't supports UWP.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emoon/minifb
    REF 25a440f8226f12b8014d24288ad0587724005afc
    SHA512 e54d86e43193d22263003a9539b11cc61cfd4a1b7093c982165cdd6e6f150b431a44e7d4dc8512b62b9853a7605e29cee19f85b8d25a34b3b530f9aa41a2f4a9
    HEAD_REF master
    PATCHES 
        fix-install-error.patch
        fix-build-error.patch
        fix-arm-build-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA   
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)