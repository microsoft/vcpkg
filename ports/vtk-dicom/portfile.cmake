include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dgobbi/vtk-dicom
    REF ca27801fad6356c98ba19e760b9b4b8e9128f60e
    SHA512 d4916fa385e6f26da0a5d7eb981497c9121ff4f67b4b03e518aa4974d2b0ef207168e939e5063e705c15f627ace56e39aca5f5891d333924cbc80c9277aa7dd2
    HEAD_REF master
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_PROGRAMS=OFF
        -DBUILD_EXAMPLES=OFF
        ${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk-dicom)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/vtk-dicom/Copyright.txt ${CURRENT_PACKAGES_DIR}/share/vtk-dicom/copyright)
