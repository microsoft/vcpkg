vcpkg_from_github(
        OUT_SOURCE_PATH source
        REPO saadshams/nanojson
        TAG 1.0.0
)

add_definitions(-DYOUR_LIBRARY_VERSION="1.0.0")  # Define a version macro

# Build YourLibrary
vcpkg_configure_cmake(
        SOURCE_PATH ${source}
        BINARY_DIR build
        CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX=${vcpkg_installed_dir}
)

vcpkg_install(
        DESTINATION include  # Install headers
        FILES include/
        INSTALL_HEADERS
)

vcpkg_install(
        DESTINATION api  # Install library files
        FILES build/libnanojson.a
        DISPLAY_NAME "nanoJSON"
)

# Set the version of the library
set(VCPKG_TARGET_TRIPLET ${VCPKG_TARGET_TRIPLET} PARENT_SCOPE)
set(YOUR_LIBRARY_VERSION 1.0.0 PARENT_SCOPE)
