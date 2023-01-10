vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libphonenumber
    REF v8.13.4
    SHA512 f1869c2d2021e6ce1d9ae3ef21bc1d6b54ee9b677510adfbde1c1f48802a371040a533558612e0882b02e9dd3451bc0269f364b53a1159d6ff5bb81ca8c72f40
    HEAD_REF master
    PATCHES 
        "fix-re2-identifiers.patch"
        "fix-multiple-rules-generated-ninja.patch"
        "fix-icui18n-lib-name.patch"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        re2                      USE_RE2
        boost                    USE_BOOST
        protobuf-lite            USE_PROTOBUF_LITE
        lite-metadata            USE_LITE_METADATA
        std-map                  USE_STD_MAP
        stdmutex                 USE_STDMUTEX
        posix                    USE_POSIX_THREAD
        build-testing            BUILD_TESTING

    INVERTED_FEATURES
        disable-static-lib              BUILD_STATIC_LIB
        disable-alt-formats             USE_ALTERNATE_FORMATS
        disable-icu-regexp              USE_ICU_REGEXP
)

if ("disable-shared-libs" IN_LIST FEATURES AND NOT "disable-static-lib" IN_LIST FEATURES)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)    # Cannot turn off BUILD_SHARED_LIBS via FEATURE_OPTIONS
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_GEOCODER=OFF                    # Geocoder has bug with Windows
        -DREGENERATE_METADATA=OFF               # This option needs Java
        )

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

if ("disable-static-lib" IN_LIST FEATURES)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
endif()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)