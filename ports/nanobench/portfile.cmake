# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinus/nanobench
    REF ee8b36e956bb2b8753dd1f6732b4d9d90afb09f9 #v4.3.0
    SHA512 46807f3b945d062dd3c829ec349cc892f9b2334c8a3c74c1225b0cd918af6864a1e539ac2bbad0ee6e20d285b5ad8e307e72996f2531377c55683cb0593ed3e7
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/src/include/nanobench.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
