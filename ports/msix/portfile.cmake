vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/msix-packaging
    REF ab322965d64baf1448548cbe18139e8872d686f2 # v1.7
    SHA512 d64767c84d5933bf3d1e0e62e9dc21fa13e02b8cf31776ccbe2e7066e514798d8ff758dc2b6fd64f6eabcf3deb83ef0eaa03e1a7d407307f347a045e8a75d3dd
    HEAD_REF master
    PATCHES
        install-cmake.patch
        fix-dependency-catch2.patch
)

file(REMOVE_RECURSE ${SOURCE_PATH}/lib)
file(MAKE_DIRECTORY ${SOURCE_PATH}/lib)
configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt ${SOURCE_PATH}/lib/CMakeLists.txt)

if(VCPKG_TARGET_IS_WINDOWS)
    set(PLATFORM WIN32)
    set(CRYPTO_LIB crypt32)
elseif(VCPKG_TARGET_IS_LINUX)
    set(PLATFORM LINUX)
    set(CRYPTO_LIB openssl)
elseif(VCPKG_TARGET_IS_OSX)
    set(PLATFORM MACOS)
    set(CRYPTO_LIB openssl)
else()
    message(FATAL_ERROR "Unknown system: ${VCPKG_CMAKE_SYSTEM_NAME}")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    NO_CHARSET_FLAG
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DINSTALL_LIBMSIX=ON
        -DUSE_SHARED_ZLIB=ON
        -D${PLATFORM}=ON
        -DXML_PARSER=xerces
        -DCRYPTO_LIB=${CRYPTO_LIB}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
