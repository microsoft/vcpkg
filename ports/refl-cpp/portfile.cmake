# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO veselink1/refl-cpp
    REF ce47c1355219f3b9af56ae91d997daf2b1555d97 #v0.12.3
    SHA512 f73e542a9ee00d677e2445c148b732cbdf6247adc1f4f412ad8e9587c5971b3cb02b39b15cdb9b0788f53e9efea6c5a485367505ecb569a367be012f6246ea92
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/refl.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
