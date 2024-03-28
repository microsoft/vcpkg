vcpkg_check_linkage(ONLY_STATIC_LIBRARY) #Upstream only support static compilation: https://github.com/uNetworking/uSockets/commit/b950efd6b10f06dd3ecb5b692e5d415f48474647

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uSockets
    REF "v${VERSION}"
    SHA512 726b1665209d0006d6621352c12019bbab22bed75450c5ef1509b409d3c19c059caf94775439d3b910676fa2a4a790d490c3e25e5b8141423d88823642be7ac7
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl     WITH_OPENSSL    # no SSL or one of WITH_BORINGSSL, WITH_OPENSSL, WITH_WOLFSSL
)
set(LIBUS_COMPLEMENT_OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS) # win requires a third party event-loop
    list(APPEND LIBUS_COMPLEMENT_OPTIONS "-DWITH_LIBUV=ON") # system default or one of WITH_IO_URING, WITH_LIBUV, WITH_ASIO, WITH_GCD
endif()

message(STATUS "This version of uSockets uses the OpenSSL as SSL backend. To use the BoringSSL or WolfSSL instead, create an overlay port of this with WITH_BORINGSSL or WITH_WOLFSSL set to 1 and the `openssl` dependency replaced with required.")
message(STATUS "This version of uSockets uses the default event-loop (dependency libuv for _WIN32, kqueue for __APPLE__ and __FreeBSD__, epoll for others). To use the one of io_uring, libuv, asio, gcd instead, create an overlay port of this with WITH_IO_URING, WITH_LIBUV, WITH_ASIO, WITH_GCD set to 1 and the `libuv` dependency replaced with required.")
message(STATUS "This recipe is at ${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "See the overlay ports documentation at https://learn.microsoft.com/en-us/vcpkg/concepts/overlay-ports")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${LIBUS_COMPLEMENT_OPTIONS}
        -DBUILD_EXAMPLES=OFF
        -DWITH_LTO=OFF
        -DVERSION=${VERSION}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-uSockets")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
