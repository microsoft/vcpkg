vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/apr/apr-util-1.6.1.tar.bz2"
    FILENAME "apr-util-1.6.1.tar.bz2"
    SHA512 40eff8a37c0634f7fdddd6ca5e596b38de15fd10767a34c30bbe49c632816e8f3e1e230678034f578dd5816a94f246fb5dfdf48d644829af13bf28de3225205d
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    crypto APU_HAVE_CRYPTO
    crypto CMAKE_REQUIRE_FIND_PACKAGE_OpenSSL
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_extract_source_archive(
        SOURCE_PATH
        ARCHIVE "${ARCHIVE}"
        PATCHES
            use-vcpkg-expat.patch
            apr.patch
            unglue.patch
    )

    vcpkg_cmake_configure(
      SOURCE_PATH "${SOURCE_PATH}"
      OPTIONS
        ${FEATURE_OPTIONS}
      OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
    )

    vcpkg_cmake_install()
    vcpkg_copy_pdbs()

    # Upstream include/apu.h.in has:
    # ```
    #elif defined(APU_DECLARE_STATIC)
    #define APU_DECLARE(type)            type __stdcall
    #define APU_DECLARE_NONSTD(type)     type __cdecl
    #define APU_DECLARE_DATA
    #elif defined(APU_DECLARE_EXPORT)
    #define APU_DECLARE(type)            __declspec(dllexport) type __stdcall
    #define APU_DECLARE_NONSTD(type)     __declspec(dllexport) type __cdecl
    #define APU_DECLARE_DATA             __declspec(dllexport)
    #else
    #define APU_DECLARE(type)            __declspec(dllimport) type __stdcall
    #define APU_DECLARE_NONSTD(type)     __declspec(dllimport) type __cdecl
    #define APU_DECLARE_DATA             __declspec(dllimport)
    #endif
    # ```
    # When building, BUILD_SHARED_LIBS sets APU_DECLARE_STATIC to 0 and APU_DECLARE_EXPORT to 1
    # Not BUILD_SHARED_LIBS sets APU_DECLARE_STATIC to 1 and APU_DECLARE_EXPORT to 0
    # When consuming APU_DECLARE_EXPORT is always 0 (assumed), so we need only embed the static or not setting
    # into the resulting headers:
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/apu.h" "defined(APU_DECLARE_STATIC)" "0")
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/apu.h" "defined(APU_DECLARE_STATIC)" "1")
    endif()
else()
    vcpkg_extract_source_archive(
        SOURCE_PATH
        ARCHIVE "${ARCHIVE}"
    )

    if ("crypto" IN_LIST FEATURES)
        set(CRYPTO_OPTIONS 
            "--with-crypto=yes"
            "--with-openssl=${CURRENT_INSTALLED_DIR}")
    else()
        set(CRYPTO_OPTIONS "--with-crypto=no")
    endif()

    # To cross-compile you will need a triplet file that locates the tool chain and sets --host and --cache parameters of "./configure".
    # The ${VCPKG_PLATFORM_TOOLSET}.cache file must have been generated on the targeted host using "./configure -C".
    # For example, to target aarch64-linux-gnu, triplets/aarch64-linux-gnu.cmake should contain (beyond the standard content):
    # set(VCPKG_PLATFORM_TOOLSET aarch64-linux-gnu)
    # set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE ${MY_CROSS_DIR}/cmake/Toolchain-${VCPKG_PLATFORM_TOOLSET}.cmake)
    # set(CONFIGURE_PARAMETER_1 --host=${VCPKG_PLATFORM_TOOLSET})
    # set(CONFIGURE_PARAMETER_2 --cache-file=${MY_CROSS_DIR}/autoconf/${VCPKG_PLATFORM_TOOLSET}.cache)
    if(CONFIGURE_PARAMETER_1)
        message(STATUS "Configuring apr-util with ${CONFIGURE_PARAMETER_1} ${CONFIGURE_PARAMETER_2} ${CONFIGURE_PARAMETER_3}")
    else()
        message(STATUS "Configuring apr-util")
    endif()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            "--prefix=${CURRENT_INSTALLED_DIR}"
            ${CRYPTO_OPTIONS}
            "--with-apr=${CURRENT_INSTALLED_DIR}/tools/apr"
            "--with-expat=${CURRENT_INSTALLED_DIR}"
            "${CONFIGURE_PARAMETER_1}"
            "${CONFIGURE_PARAMETER_2}"
            "${CONFIGURE_PARAMETER_3}"
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/apr-util/bin/apu-1-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/apr-util/bin/apu-1-config" "${CURRENT_BUILDTREES_DIR}" "not/existing")
    if(NOT VCPKG_BUILD_TYPE)
      vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/apr-util/debug/bin/apu-1-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
      vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/apr-util/debug/bin/apu-1-config" "${CURRENT_BUILDTREES_DIR}" "not/existing")
    endif()
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
