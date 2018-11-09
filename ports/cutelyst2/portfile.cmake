include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cutelyst-2.5.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/cutelyst/cutelyst/archive/v2.5.2.tar.gz"
    FILENAME "v2.5.2.tar.gz"
    SHA512 462214168026733e38fa0090c22caa468a3933066b04115cefffb57e499077456a479ec1c48a758e66a8fa078a78a5fb32df16a00e7a5f349c69c7aa06c89693
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DBUILD_TESTS:BOOL=OFF
        -DCMAKE_INSTALL_DIR:STRING=cmake
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# Move CMake config files to the right place
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/cutelyst2 RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME cutelyst2)
