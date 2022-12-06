if(NOT VCPKG_TARGET_IS_LINUX)
   set(USE_LIBUV ON)
endif()

if ("network" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "Feature 'network' is only supported on Windows")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uSockets
    REF 917ea86baad640967f62c4a92290e5211bb7966c  #v0.8.2
    SHA512 bc7850d9e7e79a390817b7ce530d79d9dc0f04386da81abbd616f06a9108dc18f928b29f1e31ef99600fb3a18ed28e8d9815fc9c3bc6c0ea66b7fe81a2fa19ff
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl CMAKE_USE_OPENSSL
        event CMAKE_USE_EVENT
        network CMAKE_USE_NETWORK
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DLIBUS_USE_LIBUV=${USE_LIBUV}"
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
