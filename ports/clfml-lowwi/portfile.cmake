vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CLFML/lowwi
    REF v3.0
    SHA512 ad7e833b7b14d7038330e804fce7b91def046a2d4fd8a6e27e97004a0ff37a0cb639c9ef5453e877d6f5b672d5503e68fdf6fafbf165b9e1c64daadcee08f79a
    HEAD_REF main
)

# 1. Configure (Examples OFF kar diye taaki SDL2 download na ho)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCLFML_LOWWI_BUILD_EXAMPLE_PROJECTS=OFF"  # <--- YE HAI SOLUTION (No Examples = No SDL2 Download)
        "-DFETCHCONTENT_FULLY_DISCONNECTED=OFF"     # Onnx ke liye internet on rakha hai
)

# 2. Build Only
vcpkg_cmake_build()

# 3. MANUAL INSTALLATION (Files khud copy karenge) ✋

# A. Headers copy karo
# A. Headers copy karo (Seedha include folder me, lowwi folder me nahi)
file(GLOB HEADER_FILES "${SOURCE_PATH}/src/*.h" "${SOURCE_PATH}/src/*.hpp")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")  

# B. Libraries copy karo (Release)
file(GLOB_RECURSE REL_LIB "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib")
file(INSTALL ${REL_LIB} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

# C. Libraries copy karo (Debug)
file(GLOB_RECURSE DBG_LIB "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib")
file(INSTALL ${DBG_LIB} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

# D. Copyright file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")