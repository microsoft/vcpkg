vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            SamuelMarks/c-str-span
    REF             5b4479cff32dc786d91544dfb0ecd157160fdc4f
    SHA512          a352451302a11d752a8426f0d28766e4d0625ff48108c3c03000550bfacf98d6eda39adee6cda7a205ecdafdf5694797e368c690bf62df42b04ca7c18ebc6644
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE-MIT"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/c-str-span"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
