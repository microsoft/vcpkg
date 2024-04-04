# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/sml2
    REF df727871ec119343e68881d47a24ce69f9bbd841
    SHA512 5a1ce9a6a6afb9504049a3e681d920c8b32394c5ffb6d635763488b8916dbcaf3390063ff0bae671729216f4eaea0f799bba7037aa922a1fc77ca9b0b1ac3a5b 
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/sml2"
  DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost"
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
