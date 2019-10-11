include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FluidSynth/fluidsynth
    REF v2.0.5
    SHA512 5344ac889d2927dc2465bae40096d756a9bf9b1100e287ba0621c55ffc76f9cb8fa763f6bc832d701cd0ad2997965cf344f58ae4b3dd445eb3491e3659c093d9
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
