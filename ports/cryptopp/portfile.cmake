if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported. Building static.") # See note below
    set(VCPKG_LIBRARY_LINKAGE static)
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cryptopp-CRYPTOPP_5_6_5)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/weidai11/cryptopp/archive/CRYPTOPP_5_6_5.zip"
    FILENAME "CRYPTOPP_5_6_5.zip"
    SHA512 abca8089e2d587f59c503d2d6412b3128d061784349c735f3ee46be1cb9e3d0d0fed9a9173765fa033eb2dc744e03810de45b8cc2f8ca1672a36e4123648ea44
)
vcpkg_extract_source_archive(${ARCHIVE})

# Dynamic linking should be avoided for Crypto++ to reduce the attack surface,
# so generate a static lib for both dynamic and static vcpkg targets.
# See also:
#   https://www.cryptopp.com/wiki/Visual_Studio#Dynamic_Runtime_Linking
#   https://www.cryptopp.com/wiki/Visual_Studio#The_DLL

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_SHARED=OFF
        -DBUILD_STATIC=ON
        -DBUILD_TESTING=OFF
        -DBUILD_DOCUMENTATION=OFF
)

vcpkg_install_cmake()

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Remove executables
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/cryptest.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/cryptest.exe)

# Remove other files not required in package
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

# Handle copyright
file(COPY ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cryptopp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cryptopp/License.txt ${CURRENT_PACKAGES_DIR}/share/cryptopp/copyright)
