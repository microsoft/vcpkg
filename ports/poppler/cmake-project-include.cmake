if("${FONT_CONFIGURATION}" STREQUAL "fontconfig")
    # Poppler uses different variable names than CMake.
    find_package(Fontconfig REQUIRED)
    set(FONTCONFIG_DEFINITIONS "")
    set(FONTCONFIG_INCLUDE_DIR "${Fontconfig_INCLUDE_DIRS}")
    set(FONTCONFIG_LIBRARIES "Fontconfig::Fontconfig")
endif()

# Poppler uses different variable names than CMake,
# plus ICONV_SECOND_ARGUMENT_IS_CONST
find_package(Iconv REQUIRED)
set(ICONV_INCLUDE_DIR "${Iconv_INCLUDE_DIR}")
set(ICONV_LIBRARIES "${Iconv_LIBRARIES}")
