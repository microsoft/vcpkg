include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/getsentry/sentry-native/releases/download/0.4.0/sentry-native.zip"
    FILENAME "sentry-native.zip"
    SHA512 1ad5e3eb18a85e7fc4e2015c3ba30840173ead19f988f3b85af9081166a889cf0d9f80946f6d8e92a44f58fbe0b86211faa1f1966496c57afd1261637e9b377c
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sentry TARGET_PATH share/sentry-native/cmake)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/sentry-native/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/crashpad_handler.exe ${CURRENT_PACKAGES_DIR}/tools/sentry-native/crashpad_handler.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/crashpad_handler.exe)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(
    INSTALL ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/sentry-native
    RENAME copyright
)
