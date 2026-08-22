vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tinycthread/tinycthread
    REF 6957fc8383d6c7db25b60b8c849b29caab1caaee
    SHA512 d8b1ad73676f90b236bef06464cfd34996e7b6676ef28cf011cfff86d63e9d6322f7b00ca15290b3f87ed40e704d5325f676440d0223a7f8716d3392a5d1345d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTINYCTHREAD_DISABLE_TESTS=OFF
        -DTINYCTHREAD_INSTALL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(STRINGS "${SOURCE_PATH}/README.txt" SOURCE_LINES)
list(SUBLIST SOURCE_LINES 70 120 SOURCE_LINES)
list(JOIN SOURCE_LINES "\n" _contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${_contents}")
