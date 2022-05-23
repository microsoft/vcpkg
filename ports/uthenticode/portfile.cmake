vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO trailofbits/uthenticode
    REF v1.0.6
    SHA512 6C9C4DD9E1FE7C329E10BC39E41927C8B82DD004275A88385C691AD85EF4079EBE2922083D5252019B8B25CC540F48E544B42B8178F256AE987D6B677713B063
    HEAD_REF master
    PATCHES
        openssl.patch
)

# compatibility fix for newer versions of pe-parse
foreach(FILE IN ITEMS test/wincert-test.cpp test/signeddata-test.cpp test/uthenticode-test.cpp test/certificate-test.cpp src/include/uthenticode.h)
    vcpkg_replace_string("${SOURCE_PATH}/${FILE}" "#include <parser-library/parse.h>" "#include <pe-parse/parse.h>")
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/uthenticode)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
