vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dgobbi/vtk-dicom
    REF 5034c68450de857b70fbe4a4b9f8dddb62badef3 # v0.8.12
    SHA512 bad1ed6a4a412402a2cd69e5f85b2b73f1ee7ea46a6bbcac31c5f66d07ae006679ffbd9a3c70f9baa1b05b1af0a2d4ca0efc34ec0a85a92f5116b900e81635cd
    HEAD_REF master
    PATCHES std.patch # similar patch is already in master
)

if ("gdcm" IN_LIST FEATURES)
    set(USE_GDCM                      ON )
else()
    set(USE_GDCM                      OFF )
endif()


if(USE_GDCM)
    list(APPEND ADDITIONAL_OPTIONS
        -DUSE_GDCM=ON
        -DUSE_DCMTK=OFF
    )
endif()
vcpkg_find_acquire_program(PYTHON3)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_PROGRAMS=OFF
        -DBUILD_EXAMPLES=OFF
        "-DPython3_EXECUTABLE=${PYTHON3}"
        ${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
