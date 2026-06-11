vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/ideep
    REF e539e0f9774e2018f0d56fe865da66581f692e3d
    SHA512 46eeb0455597aca6c65d119edfe2ad11166e889e1c1b67f4ac55b33bae3a9c393ac4bed81a33bfb371ce3fe155d7be912d75f927a911ca76b1ba820bfed0ab7e
    HEAD_REF master
)

# Header-only library: install the include tree directly.
file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
