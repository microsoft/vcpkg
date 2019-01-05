#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF c02ddae4bcff82b17826fe3127e835f5aa54b485
    SHA512 5fcb67d410a46a4e202c367bae59b1dd4f4220ac2b75a70bc34503612a616b2792e74a18b50901656d18a031cc32cf42da8673d3412ccfe8a236daa54eae44c7
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
