vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tdlib/td
    REF 7d257dcda5dd2c616c1146540ef51147c5bb2c69
    HEAD_REF master
    SHA512 fca25e017e6bc27bcc0a69b35ad478a5acfc46b511917440c3e560c18378c3f4133c1c553eb9a0752db5328f61c5813312d653f4ad5e5d0284b7a79d4f480be8
    PATCHES
        fix-pc.patch
)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DTD_INSTALL_SHARED_LIBRARIES=OFF
        -DTD_INSTALL_STATIC_LIBRARIES=ON
        -DTD_ENABLE_JNI=${VCPKG_TARGET_IS_ANDROID}
        -DTD_ENABLE_DOTNET=OFF
        -DTD_GENERATE_SOURCE_FILES=OFF
        -DTD_E2E_ONLY=OFF
        -DTD_ENABLE_LTO=${CMAKE_HOST_WIN32}
        -DTD_ENABLE_MULTI_PROCESSOR_COMPILATION=${VCPKG_DETECTED_MSVC}
        -DBUILD_TESTING=OFF
    MAYBE_UNUSED_VARIABLES
        TD_ENABLE_MULTI_PROCESSOR_COMPILATION
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Td")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
