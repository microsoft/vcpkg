cmake_minimum_required(VERSION 3.11)
cmake_policy(VERSION 3.11)

project (rappture)

set(SRC_RAPPTURE_CORE
    src/core/scew_extras.c
    src/core/RpBindingsDict.cc
    src/core/RpBuffer.cc
    src/core/RpBufferCInterface.cc
    src/core/RpDXWriter.cc
    src/core/RpDXWriterFInterface.cc
    src/core/RpEncode.cc
    src/core/RpEntityRef.cc
    src/core/RpFortranCommon.cc
    src/core/RpLibrary.cc
    src/core/RpLibraryCInterface.cc
    src/core/RpLibraryFInterface.cc
    src/core/RpOutcome.cc
    src/core/RpOutcomeCInterface.cc
    src/core/RpPtr.cc
    src/core/RpResult.cc
    src/core/RpUnits.cc
    src/core/RpUnitsCInterface.cc
    src/core/RpUnitsFInterface.cc
    src/core/RpUnitsStd.cc
    src/core/RpUtils.cc
    src/core/RpUtilsCInterface.cc
    src/core/RpUtilsFInterface.cc
    src/core/b64/cdecode.c
    src/core/b64/cencode.c
    src/core/scew/attribute.c
    src/core/scew/element.c
    src/core/scew/error.c
    src/core/scew/parser.c
    src/core/scew/str.c
    src/core/scew/tree.c
    src/core/scew/writer.c
    src/core/scew/xattribute.c
    src/core/scew/xerror.c
    src/core/scew/xhandler.c
    src/core/scew/xparser.c
    src/core/scew/xprint.c
)

set(HEADERS
    src/core/rappture.h
    src/core/RpBindingsDict.h
    src/core/RpBuffer.h
    src/core/RpBufferCHelper.h
    src/core/RpBufferCInterface.h
    src/core/RpDict.h
    src/core/RpDXWriter.h
    src/core/RpDXWriterFInterface.h
    src/core/RpDXWriterFStubs.h
    src/core/RpEncode.h
    src/core/RpEntityRef.h
    src/core/RpFortranCommon.h
    src/core/RpLibrary.h
    src/core/RpLibraryCInterface.h
    src/core/RpLibraryFInterface.h
    src/core/RpLibraryFStubs.h
    src/core/RpOutcome.h
    src/core/RpOutcomeCHelper.h
    src/core/RpOutcomeCInterface.h
    src/core/RpPtr.h
    src/core/RpSimpleBuffer.h
    src/core/RpUnits.h
    src/core/RpUnitsCInterface.h
    src/core/RpUnitsFInterface.h
    src/core/RpUnitsFStubs.h
    src/core/RpUnitsStd.h
    src/core/RpUtils.h
    src/core/RpUtilsCInterface.h
    src/core/RpUtilsFInterface.h
    src/core/RpUtilsFStubs.h
    src/core/scew_extras.h

)

add_library(rappture ${SRC_RAPPTURE_CORE} ${HEADERS})

set_property(TARGET rappture PROPERTY CXX_STANDARD 11)

target_include_directories(rappture PUBLIC
                            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/core/>
                            $<INSTALL_INTERFACE:include>
)

find_package(expat CONFIG REQUIRED)
find_package(ZLIB REQUIRED)

target_compile_definitions(rappture PUBLIC
                            -D_CRT_SECURE_NO_WARNINGS
                            -DRAPPTURE_VERSION=1.9
                            -DSVN_VERSION=6713
                            -D_USE_MATH_DEFINES
)

target_link_libraries(rappture PRIVATE
                        expat::expat
                        ZLIB::ZLIB
)

install(TARGETS rappture EXPORT rappture-config
            RUNTIME DESTINATION bin
            ARCHIVE DESTINATION lib
            LIBRARY DESTINATION lib
        )

install(FILES ${HEADERS} DESTINATION include/rappture)
install(EXPORT rappture-config NAMESPACE unofficial::rappture:: DESTINATION share/rappture)
