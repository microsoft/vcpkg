# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LukasBanana/GaussianLib
    REF 9b4a163a9a97c900b0febd93e22dc1be3faf6e20
    SHA512 f16c3cd699e30d3fbd3ef6e80f64716d72383a1f2dc073325f785b63c2ba6edc62e2a7d360eba6a92a42bf4a2ad32accd4ce3e249ee510ff5133745b897a4f55
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/Gauss DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
