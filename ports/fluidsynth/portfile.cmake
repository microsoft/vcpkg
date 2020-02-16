vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FluidSynth/fluidsynth
    REF 37c9ae2bf431a764032f023b3b2c0c0b86b7c272 #v2.1.0
    SHA512 1eea26b7d71fd09e748df0989f7df42ab57a74d8d853a835da734120ee1198c0b8d73a39b8640aef8ef0c1788c9a329671de899882601da55ec20ab6ca3ff778
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
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)