include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/msix-packaging
    REF MsixCoreInstaller-preview
    SHA512 b034559da8e4d5fedc79b3ef65b6f8e9bca69c92f3d85096e7ea84a0e394fa04a92f84079524437ceebd6c006a12dac9cc2e46197154257bbf7449ded031d3e8
    HEAD_REF master
    PATCHES install-cmake.patch
)

file(REMOVE_RECURSE ${SOURCE_PATH}/lib)
file(MAKE_DIRECTORY ${SOURCE_PATH}/lib)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/lib)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(PLATFORM WIN32)
    set(CRYPTO_LIB crypt32)
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(PLATFORM LINUX)
    set(CRYPTO_LIB openssl)
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(PLATFORM MACOS)
    set(CRYPTO_LIB openssl)
else()
    message(FATAL_ERROR "Unknown system: ${VCPKG_CMAKE_SYSTEM_NAME}")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    NO_CHARSET_FLAG
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DINSTALL_LIBMSIX=ON
        -DUSE_SHARED_ZLIB=ON
        -D${PLATFORM}=ON
        -DXML_PARSER=xerces
        -DCRYPTO_LIB=${CRYPTO_LIB}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/msix RENAME copyright)

vcpkg_copy_pdbs()
