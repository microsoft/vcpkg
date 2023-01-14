if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  message("unicorn-lib is a static library, now build with static.")
  set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/unicorn-lib
    REF 44e975ffc8dcd8dedbe01a8cbe7812e351f3f74f # 2022-01-24
    SHA512 b22264420174c950ca8025e861366118d79a53edce9297d84af9511e255af5971c3719f0b464f4a4886848edea7c2ba4ae32ce9abab135628d64adbde5fa7b0d
    HEAD_REF master
)

file(COPY ${CURRENT_PORT_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DUNICORN_LIB_SKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
