vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnr-isti-vclab/vcglib
    REF 38c3a410b168975de719f91d4a9325fb4edbb3ae #2021.10
    SHA512 20285bd73927a47a52757d90f34a9d02f4206872f319e3ec1386d35c1c42888df47e3da321b05eca60b6cd1121e06d12ef7d1897ce2770dc54ddfb3929ed90b5
    PATCHES
        consume-vcpkg-eigen3.patch
    )

configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/vcglib/copyright" COPYONLY)

file(COPY "${SOURCE_PATH}/vcg/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vcg")
file(COPY "${SOURCE_PATH}/wrap/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/wrap")
file(COPY "${SOURCE_PATH}/img/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/img")
