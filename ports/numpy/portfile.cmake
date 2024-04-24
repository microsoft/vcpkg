set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # Numpy includes are stored in the module itself
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)
set(VCPKG_BUILD_TYPE release) # No debug builds required for pure python modules since vcpkg does not install a debug python executable. 

find_program(VCPKG_PYTHON3 NAMES python${PYTHON3_VERSION_MAJOR}.${PYTHON3_VERSION_MINOR} python${PYTHON3_VERSION_MAJOR} python PATHS "${VCPKG_PYTHON3_BASEDIR}" NO_DEFAULT_PATH)
find_program(VCPKG_CYTHON NAMES cython PATHS "${VCPKG_PYTHON3_BASEDIR}" "${VCPKG_PYTHON3_BASEDIR}/Scripts" NO_DEFAULT_PATH)
message(STATUS "PYTHON3:${VCPKG_PYTHON3}")
set(ENV{PYTHON3} "${VCPKG_PYTHON3}")
set(PYTHON3 "${VCPKG_PYTHON3}")

vcpkg_add_to_path(PREPEND "${VCPKG_PYTHON3_BASEDIR}")
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_add_to_path(PREPEND "${VCPKG_PYTHON3_BASEDIR}/Scripts")
endif()

cmake_path(GET SCRIPT_MESON PARENT_PATH MESON_DIR)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO numpy/numpy
    REF v${VERSION}
    SHA512 01b6a124c72d082f1dafdd98cdaaa84ab57f2bf0112d89d9355fa458a04deb8309c7e78449767429049971793c040e51412060681218a51c671ac6086dba2fa4
    HEAD_REF main
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_SIMD
    REPO intel/x86-simd-sort
    REF v5.0
    SHA512 8e7a1929b7234399d8ac30cd296b69efdfc0d9d03a91507f3b4e06f486b6b715199b35e0495f330c21b70165bcab48842cd7c0a887df4e6508b6151ad1dc9c2a
    HEAD_REF main
)

file(COPY "${SOURCE_PATH_SIMD}/" DESTINATION "${SOURCE_PATH}/numpy/core/src/npysort/x86-simd-sort")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_MESON_NUMPY
    REPO numpy/meson
    REF 4e370ca8ab73c07f7b84abe8a4b937caace050a4
    SHA512 dec6e3b9428f95790f85a863778227a73e4f432f8f54e87d61fd6499b5a0723c59a334fcaf880afd59ae50c924d8f2cfa340a143f752cb39f976c731ca0ea123
    HEAD_REF main
)

file(COPY "${SOURCE_PATH_MESON_NUMPY}/mesonbuild/modules/features" DESTINATION "${MESON_DIR}/mesonbuild/modules")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_SVML
    REPO numpy/SVML
    REF 32bf2a98420762a63ab418aaa0a7d6e17eb9627a
    SHA512 6242569840ac4b645c6070f72f0691ffc090b1c0c87cb935cb04ffd39c6d334bff0cbddcbf8a2ae5de2b1d5bb322f2a5a2dfd8a30b2e25bf7f6af732ffc47040
    HEAD_REF main
)

file(COPY "${SOURCE_PATH_SVML}/" DESTINATION "${SOURCE_PATH}/numpy/core/src/umath/svml")

vcpkg_replace_string("${SOURCE_PATH}/meson.build" "py.dependency()" "dependency('python-3.${PYTHON3_VERSION_MINOR}', method : 'pkg-config')")

#debug replacement 
vcpkg_replace_string("${SOURCE_PATH}/numpy/_build_utils/tempita.py" "import argparse" "import argparse\nprint(sys.executable)\nimport os\n
print(os.environ['PATH'])")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CROSSCOMPILING AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
  set(opts 
      ADDITIONAL_PROPERTIES
      "longdouble_format = 'IEEE_DOUBLE_LE'"
  )
endif()

message(STATUS "PATH is: '$ENV{PATH}'")
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -Dblas=blas
        -Dlapack=lapack
        #-Duse-ilp64=true
    ADDITIONAL_BINARIES
      cython=['${VCPKG_CYTHON}']
      python3=['${VCPKG_PYTHON3}']
      python=['${VCPKG_PYTHON3}']
    ${opts}
    )
message(STATUS "PATH is: '$ENV{PATH}'")
vcpkg_install_meson()
message(STATUS "PATH is: '$ENV{PATH}'")
vcpkg_fixup_pkgconfig()

#E:\vcpkg_folders\numpy\packages\numpy_arm64-windows-release\tools\python3\Lib\site-packages\numpy\__config__.py
# "path": r"E:/vcpkg_folders/numpy/installed/x64-windows-release/tools/python3/python.exe", and full paths to compilers
#"commands": "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.39.33519/bin/Hostx64/arm64/cl.exe, -DWIN32, -D_WINDOWS, -W3, -utf-8, -MP, -MD, -O2, -Oi, -Gy, -DNDEBUG, -Z7",

set(subdir "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/")
if(VCPKG_TARGET_IS_WINDOWS)
  set(subdir "${CURRENT_PACKAGES_DIR}/lib/site-packages/")
endif()
set(pyfile "${subdir}/numpy/__config__.py")
file(READ "${pyfile}" contents)
string(REPLACE "${CURRENT_INSTALLED_DIR}" "$(prefix)" contents "${contents}")
string(REPLACE "r\"${VCPKG_PYTHON3}\"" "sys.executable" contents "${contents}")
file(WRITE "${pyfile}" "${contents}")


if(VCPKG_TARGET_IS_WINDOWS)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/site-packages/numpy" "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/numpy")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

# Add required Metadata for some python build plugins
file(WRITE "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/numpy-${VERSION}.dist-info/METADATA"
"Metadata-Version: 2.1\n\
Name: numpy\n\
Version: ${VERSION}"
)

vcpkg_python_test_import(MODULE "numpy")
