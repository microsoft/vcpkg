include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FluidSynth/fluidsynth
    REF 34b4db10b7164d95e1266c713610554fa96f6914 # v2.0.8
    SHA512 c46e198eb271e27972e2bf6a5b8f694a3f0c15034aab5dded0a5524b979bdcfbc4d10668e7e1b56d7735aae7665e7a24cd8f5f97de85326ce403efb604af3272
    HEAD_REF master
    PATCHES
       force-x86-gentables.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
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
