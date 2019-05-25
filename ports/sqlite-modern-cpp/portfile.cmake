# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aminroosta/sqlite_modern_cpp
    REF 56af65d2c5085dd34a2c1a4ad20cf8b93ad1024f
    SHA512 7e54cc41713247c9f6373a441854e8dace8e334e6ee29f870f11bc3fd3b53b5cff4e1a6d4c7e3cda33509b70a3f9a47363922a589b9a6d0730ce6dc0c884d878
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/hdr/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp)
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp RENAME copyright)
