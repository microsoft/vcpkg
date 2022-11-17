vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO romeric/Fastor
    REF 76152e2fded7f014af969089e7d2ca966cef4d3b
    SHA512 e2c4a267f592a7fbb92a54f7bf774a709b2a6d4a7bd3d338a20c455299a30d8352bfc6dd6c71eafa21ac70331ac0f4a86b176a56577699b82fde6f536429fb39
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

