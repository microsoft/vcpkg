set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_BUILD_TYPE release)
set(SQLITE_VERSION "3.39.3")

vcpkg_download_distfile(SOURCE_FILE
    URLS "https://github.com/sqlite/sqlite/raw/version-${SQLITE_VERSION}/tool/lemon.c"
    FILENAME "lemon.c"
    SHA512 "e9cca77d45a3be55fc958be69a30730dcbd39ba5c85c4c6c6c9eb6988c5cae9d14607be214ce57c11c73a6ffd4005784fb4d046d78f50e348ffa7ea6392ee03a"
)

get_filename_component(SOURCE_PATH "${SOURCE_FILE}" DIRECTORY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_download_distfile(LEMPAR
    URLS "https://github.com/sqlite/sqlite/raw/version-${SQLITE_VERSION}/tool/lempar.c"
    FILENAME "lempar.c"
    SHA512 "45ef60bbfef54f6583d6f9a854aaa72c5538e791b09ad15f4094a96905974277f964f471dcd5775e76b685b54415897a32a40c09f913f61cf91b99eb2e5ff5f0"
)

file(COPY "${LEMPAR}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/lemon")
