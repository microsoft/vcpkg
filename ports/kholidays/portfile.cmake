vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kholidays
    REF "v${VERSION}"
    SHA512 1547173481b496ac2fbcda060e42ae8fd806a45ac59b675897c53d66808bbf2c00a643da13e756799fe876508d4c355acb8cfc0c448acce728d6fadfb2083519
    HEAD_REF master
    PATCHES
        optional-qml.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qml          CMAKE_REQUIRE_FIND_PACKAGE_Qt6Qml
    INVERTED_FEATURES
        qml          CMAKE_DISABLE_FIND_PACKAGE_Qt6Qml
        translations KF_SKIP_PO_PROCESSING
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

# The bundled FlexLexer.h declares LexerInput() and LexerOutput() with int parameters, like GNU flex,
# but some flex versions (e.g. Apple's) generate them with size_t: make it match the flex in use
file(WRITE "${CURRENT_BUILDTREES_DIR}/flex-check.l" "%option c++ noyywrap\n%%\n%%\n")
vcpkg_execute_required_process(
    COMMAND "${FLEX}" -o flex-check.cpp flex-check.l
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME flex-check
)
file(READ "${CURRENT_BUILDTREES_DIR}/flex-check.cpp" flex_check)
if(flex_check MATCHES "size_t yyFlexLexer::LexerInput")
    vcpkg_replace_string("${SOURCE_PATH}/src/parsers/plan2/FlexLexer.h"
        "virtual int LexerInput(char *buf, int max_size);"
        "virtual size_t LexerInput(char *buf, size_t max_size);"
    )
    vcpkg_replace_string("${SOURCE_PATH}/src/parsers/plan2/FlexLexer.h"
        "virtual void LexerOutput(const char *buf, int size);"
        "virtual void LexerOutput(const char *buf, size_t size);"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DKDE_INSTALL_QMLDIR=qml
        "-DFLEX_EXECUTABLE=${FLEX}"
        "-DBISON_EXECUTABLE=${BISON}"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6holidays CONFIG_PATH lib/cmake/KF6Holidays)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
# LICENSES/ lacks the texts of the licenses of SunEvents, of the Hebrew calendar converter,
# and of the week number routine in qcalendarsystem.cpp
vcpkg_download_distfile(GPL_2_0_LICENSE
    URLS "https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt"
    FILENAME "kholidays-GPL-2.0.txt"
    SHA512 7a1dba2c878f7a2395175da465a20103ac7e33b145c662373114cd84a29b2b1f0a45e04e6140cdcdf56c11e2e0260dab90a2cc29babc0e6cbf1676b1dd377af2
)
vcpkg_download_distfile(LGPL_2_1_LICENSE
    URLS "https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt"
    FILENAME "kholidays-LGPL-2.1.txt"
    SHA512 e7e968ad0983d03f6bea8b35de580ce6d717fd4ade95e32ed26807d8ae89631c0f188a7a18f9eefba9a2eba46c31aa8b1f2aaa56621dea1df5140919b441ba39
)
vcpkg_download_distfile(LGPL_3_0_LICENSE
    URLS "https://www.gnu.org/licenses/lgpl-3.0.txt"
    FILENAME "kholidays-LGPL-3.0.txt"
    SHA512 6a21e9f6706dacb99162dd4c70ec704e3fdf283b93ca2cc1521e08e55e0727db4c7384d027d54739f100cd26c8d3d5be717715c6b21086a9bb22efb893c34fcf
)
vcpkg_download_distfile(KDE_ACCEPTED_LGPL_LICENSE
    URLS "https://raw.githubusercontent.com/KDE/kcoreaddons/v6.31.0/LICENSES/LicenseRef-KDE-Accepted-LGPL.txt"
    FILENAME "kholidays-LicenseRef-KDE-Accepted-LGPL.txt"
    SHA512 21d3e707d34089ab8d9b5f91e747dc8546c1bc398c71f0957b385469d6d9dc7d2d2f68013fae03829ad395a769668e9061eac88e02036b5959f3e4b762ed12d9
)
vcpkg_download_distfile(BSD_3_CLAUSE_LICENSE
    URLS "https://raw.githubusercontent.com/KDE/kcoreaddons/v6.31.0/LICENSES/BSD-3-Clause.txt"
    FILENAME "kholidays-BSD-3-Clause.txt"
    SHA512 a4a301dc9c6af57586e26a112fa3cf449b147b1dd8d6879b6042efbe2e8a985fed635ce43734fbad2f6bbf570c4677cf7eeb4abea4ff361c15c0dfc371bad426
)
list(APPEND LICENSE_FILES
    "${SOURCE_PATH}/src/sunevents.h"
    "${SOURCE_PATH}/src/hebrewconverter.h"
    "${GPL_2_0_LICENSE}"
    "${LGPL_2_1_LICENSE}"
    "${LGPL_3_0_LICENSE}"
    "${KDE_ACCEPTED_LGPL_LICENSE}"
    "${BSD_3_CLAUSE_LICENSE}"
)
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
