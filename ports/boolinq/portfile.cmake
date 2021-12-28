# Single-file header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO k06a/boolinq
    REF c60ca05669ca91bf83eb16c65e818364919c5d09 #v3.0.3
    SHA512 0d2551762efa23c52b47db2991289f142c81d62bb1e992899882c3e94d1d14943d4bfb32ad6f0e6d96ff3319e27f64e416609d6759df7bf106dcd31bd84d6cf7
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/boolinq/boolinq.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/boolinq")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
