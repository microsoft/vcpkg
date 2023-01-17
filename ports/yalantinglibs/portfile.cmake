# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/yalantinglibs
    REF "d773413c6d86fd0cadb73be81a7334282298b47a" # 0.1.0
    SHA512 "00e3a68c6e6ba639b0513ab3b229d7d67bdced23b069841629d9c4263a8366af06a00d14b144ab3c084d559dca5dfb6bdac83f2c5bbb08245bbed696228526f0"
    HEAD_REF main
)

# Install source files
file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)