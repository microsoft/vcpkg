vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            "offscale/${PORT}"
    REF             2c269f257ecbd55fd16867b65fec3259277acbb9
    SHA512          2f8715e08ac2fd573240778ac86bce308a68e02e314c86df68a1d0f0b85abc956067cd40bea6e942fdc74e33934aaed676239458b3afa5f7021dc6d3009da2f2
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
foreach(_dir "include" "share")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/${_dir}")
endforeach(_dir "include" "share")
