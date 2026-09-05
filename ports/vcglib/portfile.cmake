# header-only library
set(VCPKG_BUILD_TYPE release)

string(REGEX REPLACE "^([0-9]+)\\.([0-9])$" "\\1.0\\2" VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnr-isti-vclab/vcglib
    REF "${VERSION}"
    SHA512 6533dfdc48a8ee0f904c49edcd25a3c06a945cec7baa047ddbba78ae48fbf7b490718fe15eb7c729f9c097114b798ec5204302b37011906a0bed4de819616717
    PATCHES
        consume-vcpkg-eigen3.patch
)

# Remove non-header folders)
file(REMOVE_RECURSE 
    "${SOURCE_PATH}/wrap/gcache/docs" 
    "${SOURCE_PATH}/wrap/gl/splatting_apss/shaders" 
    "${SOURCE_PATH}/wrap/igl/sample" 
    "${SOURCE_PATH}/wrap/nanoply"
)

file(COPY "${SOURCE_PATH}/img"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/vcg"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/wrap" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
