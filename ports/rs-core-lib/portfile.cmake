include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 3127d573eb15007f878a3cbab7faa8be3255df44
    SHA512 96b08485567547296dbe1d70bedc4d1e59d432b03c468eab83b0b436d2f92b6e51aa5571c039db65abe6797a88c9cf26048539f773bce58c38789384f1a495c3
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)