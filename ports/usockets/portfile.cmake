if(NOT VCPKG_TARGET_IS_LINUX)
   set(USE_LIBUV ON)
endif()

if ("network" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "Feature 'network' is only supported on Windows")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uSockets
    REF 760a0243c77272df2225fcd50acfc0b1d7ffff0d  #v0.8.3
    SHA512 23b79d11ebdfc1578fd5234246ba39d5c191c4bc3c32b62cd6c18aabc160bf0033829809451f28bfb911eedde1ccd71182d4af6884eb15949dbfacda4cded259
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
