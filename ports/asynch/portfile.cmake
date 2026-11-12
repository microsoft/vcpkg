vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO naasking/async.h
    REF 427bd46a1389b594f6963df38323ebb38e55e93f # Commits on 2022-03-16
    SHA512 fd943f3171fd85f64dc542291849935b9f5574b0239a0854786e65611a51c751f7391b395066ccc5d748dbd8d91f78cd0b660a90e67542b74123c8766613df40
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY "${SOURCE_PATH}/async/async.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
