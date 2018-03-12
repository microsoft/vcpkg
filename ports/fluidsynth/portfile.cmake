include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fluidsynth-1.1.10)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FluidSynth/fluidsynth
    REF v1.1.10
    SHA512 7ff7757baf6dee37f65a4fd214ffab1aa1434cfd1545deb4108fe2e9b0ed19d616880b2740a693b51ade0a4be998a671910b43cae26eb67fb97b16a513752cbc
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -Denable-pkgconfig=0
)

vcpkg_install_cmake()

# Copy fluidsynth.exe to tools dir
file(COPY ${CURRENT_PACKAGES_DIR}/bin/fluidsynth.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/fluidsynth)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/fluidsynth)

# Remove unnecessary files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/fluidsynth.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fluidsynth.exe)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fluidsynth RENAME copyright)
