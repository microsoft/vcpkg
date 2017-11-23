# UnitTest++ 
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported by unittest-cpp yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/unittest-cpp-2.0.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/unittest-cpp/unittest-cpp/archive/v2.0.0.zip"
    FILENAME "unittest-cpp-2.0.0.zip"
    SHA512 2f1bdedc9cd8dcfeccca8be034dcc07544d991f8fc183166d9224d466f5e47100e0769b8c2b85dd45ca9ff57e42460bf41478a9e52fe2d2df4663fb22fe8cb6e
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/unittest-cpp RENAME copyright)

# Remove duplicate includes
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Clean up cmake files and move to share
file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/UnitTest++/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib/cmake/UnitTest++/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/UnitTest++/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/unittest-cpp/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)