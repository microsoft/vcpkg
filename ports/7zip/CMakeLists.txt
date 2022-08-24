cmake_minimum_required(VERSION 3.19)

project(7zip LANGUAGES C CXX)

if(VCPKG_TARGET_IS_WINDOWS)
    enable_language(ASM_MASM)
elseif(VCPKG_TARGET_IS_LINUX)
    enable_language(ASM)
endif()

add_library(7zip)

target_sources(7zip PRIVATE
    CPP/7zip/Compress/Bcj2Coder.cpp
    CPP/7zip/Compress/Bcj2Register.cpp
    CPP/7zip/Compress/BcjCoder.cpp
    CPP/7zip/Compress/BcjRegister.cpp
    CPP/7zip/Compress/BitlDecoder.cpp
    CPP/7zip/Compress/BranchMisc.cpp
    CPP/7zip/Compress/BranchRegister.cpp
    CPP/7zip/Compress/ByteSwap.cpp
    CPP/7zip/Compress/BZip2Crc.cpp
    CPP/7zip/Compress/BZip2Decoder.cpp
    CPP/7zip/Compress/BZip2Encoder.cpp
    CPP/7zip/Compress/BZip2Register.cpp
    CPP/7zip/Compress/CopyCoder.cpp
    CPP/7zip/Compress/CopyRegister.cpp
    CPP/7zip/Compress/Deflate64Register.cpp
    CPP/7zip/Compress/DeflateDecoder.cpp
    CPP/7zip/Compress/DeflateEncoder.cpp
    CPP/7zip/Compress/DeflateRegister.cpp
    CPP/7zip/Compress/DeltaFilter.cpp
    CPP/7zip/Compress/ImplodeDecoder.cpp
    CPP/7zip/Compress/LzfseDecoder.cpp
    CPP/7zip/Compress/LzhDecoder.cpp
    CPP/7zip/Compress/Lzma2Decoder.cpp
    CPP/7zip/Compress/Lzma2Encoder.cpp
    CPP/7zip/Compress/Lzma2Register.cpp
    CPP/7zip/Compress/LzmaDecoder.cpp
    CPP/7zip/Compress/LzmaEncoder.cpp
    CPP/7zip/Compress/LzmaRegister.cpp
    CPP/7zip/Compress/LzmsDecoder.cpp
    CPP/7zip/Compress/LzOutWindow.cpp
    CPP/7zip/Compress/LzxDecoder.cpp
    CPP/7zip/Compress/PpmdDecoder.cpp
    CPP/7zip/Compress/PpmdEncoder.cpp
    CPP/7zip/Compress/PpmdRegister.cpp
    CPP/7zip/Compress/PpmdZip.cpp
    CPP/7zip/Compress/QuantumDecoder.cpp
    CPP/7zip/Compress/Rar1Decoder.cpp
    CPP/7zip/Compress/Rar2Decoder.cpp
    CPP/7zip/Compress/Rar3Decoder.cpp
    CPP/7zip/Compress/Rar3Vm.cpp
    CPP/7zip/Compress/Rar5Decoder.cpp
    CPP/7zip/Compress/RarCodecsRegister.cpp
    CPP/7zip/Compress/ShrinkDecoder.cpp
    CPP/7zip/Compress/XpressDecoder.cpp
    CPP/7zip/Compress/XzDecoder.cpp
    CPP/7zip/Compress/XzEncoder.cpp
    CPP/7zip/Compress/ZlibDecoder.cpp
    CPP/7zip/Compress/ZlibEncoder.cpp
    CPP/7zip/Compress/ZDecoder.cpp
    CPP/7zip/Compress/CodecExports.cpp

    CPP/7zip/Crypto/7zAes.cpp
    CPP/7zip/Crypto/7zAesRegister.cpp
    CPP/7zip/Crypto/HmacSha1.cpp
    CPP/7zip/Crypto/HmacSha256.cpp
    CPP/7zip/Crypto/MyAes.cpp
    CPP/7zip/Crypto/MyAesReg.cpp
    CPP/7zip/Crypto/Pbkdf2HmacSha1.cpp
    CPP/7zip/Crypto/RandGen.cpp
    CPP/7zip/Crypto/Rar20Crypto.cpp
    CPP/7zip/Crypto/Rar5Aes.cpp
    CPP/7zip/Crypto/RarAes.cpp
    CPP/7zip/Crypto/WzAes.cpp
    CPP/7zip/Crypto/ZipCrypto.cpp
    CPP/7zip/Crypto/ZipStrong.cpp

    C/7zBuf2.c
    C/7zStream.c
    C/Alloc.c
    C/Bcj2.c
    C/Bcj2Enc.c
    C/Blake2s.c
    C/Bra.c
    C/Bra86.c
    C/BraIA64.c
    C/BwtSort.c
    C/CpuArch.c
    C/Delta.c
    C/HuffEnc.c
    C/LzFind.c
    C/LzFindMt.c
    C/Lzma2Dec.c
    C/Lzma2DecMt.c
    C/Lzma2Enc.c
    C/LzmaEnc.c
    C/LzmaLib.c
    C/MtCoder.c
    C/MtDec.c
    C/Ppmd7.c
    C/Ppmd7aDec.c
    C/Ppmd7Dec.c
    C/Ppmd7Enc.c
    C/Ppmd8.c
    C/Ppmd8Dec.c
    C/Ppmd8Enc.c
    C/Sha1.c
    C/Sha256.c
    C/Sort.c
    C/Threads.c
    C/Xz.c
    C/XzDec.c
    C/XzEnc.c
    C/XzIn.c
    C/Aes.c
    C/7zCrc.c
    C/XzCrc64.c

    CPP/Common/CRC.cpp
    CPP/Common/CrcReg.cpp
    CPP/Common/DynLimBuf.cpp
    CPP/Common/IntToString.cpp
    CPP/Common/LzFindPrepare.cpp
    CPP/Common/MyMap.cpp
    CPP/Common/MyString.cpp
    CPP/Common/MyVector.cpp
    CPP/Common/MyWindows.cpp
    CPP/Common/MyXml.cpp
    CPP/Common/NewHandler.cpp
    CPP/Common/Sha1Prepare.cpp
    CPP/Common/Sha1Reg.cpp
    CPP/Common/Sha256Prepare.cpp
    CPP/Common/Sha256Reg.cpp
    CPP/Common/StringConvert.cpp
    CPP/Common/StringToInt.cpp
    CPP/Common/UTFConvert.cpp
    CPP/Common/Wildcard.cpp
    CPP/Common/XzCrc64Init.cpp
    CPP/Common/XzCrc64Reg.cpp

    CPP/Windows/FileDir.cpp
    CPP/Windows/FileFind.cpp
    CPP/Windows/FileIO.cpp
    CPP/Windows/FileName.cpp
    CPP/Windows/PropVariant.cpp
    CPP/Windows/PropVariantUtils.cpp
    CPP/Windows/Synchronization.cpp
    CPP/Windows/System.cpp
    CPP/Windows/TimeUtils.cpp

    CPP/7zip/Common/CreateCoder.cpp
    CPP/7zip/Common/CWrappers.cpp
    CPP/7zip/Common/InBuffer.cpp
    CPP/7zip/Common/InOutTempBuffer.cpp
    CPP/7zip/Common/FilterCoder.cpp
    CPP/7zip/Common/LimitedStreams.cpp
    CPP/7zip/Common/LockedStream.cpp
    CPP/7zip/Common/MemBlocks.cpp
    CPP/7zip/Common/MethodId.cpp
    CPP/7zip/Common/MethodProps.cpp
    CPP/7zip/Common/OffsetStream.cpp
    CPP/7zip/Common/OutBuffer.cpp
    CPP/7zip/Common/OutMemStream.cpp
    CPP/7zip/Common/ProgressMt.cpp
    CPP/7zip/Common/ProgressUtils.cpp
    CPP/7zip/Common/PropId.cpp
    CPP/7zip/Common/StreamBinder.cpp
    CPP/7zip/Common/StreamObjects.cpp
    CPP/7zip/Common/StreamUtils.cpp
    CPP/7zip/Common/UniqBlocks.cpp
    CPP/7zip/Common/VirtThread.cpp

    CPP/7zip/Archive/ApmHandler.cpp
    CPP/7zip/Archive/ArHandler.cpp
    CPP/7zip/Archive/ArjHandler.cpp
    CPP/7zip/Archive/Base64Handler.cpp
    CPP/7zip/Archive/Bz2Handler.cpp
    CPP/7zip/Archive/ComHandler.cpp
    CPP/7zip/Archive/CpioHandler.cpp
    CPP/7zip/Archive/CramfsHandler.cpp
    CPP/7zip/Archive/DeflateProps.cpp
    CPP/7zip/Archive/DmgHandler.cpp
    CPP/7zip/Archive/ElfHandler.cpp
    CPP/7zip/Archive/ExtHandler.cpp
    CPP/7zip/Archive/FatHandler.cpp
    CPP/7zip/Archive/FlvHandler.cpp
    CPP/7zip/Archive/GzHandler.cpp
    CPP/7zip/Archive/GptHandler.cpp
    CPP/7zip/Archive/HandlerCont.cpp
    CPP/7zip/Archive/HfsHandler.cpp
    CPP/7zip/Archive/IhexHandler.cpp
    CPP/7zip/Archive/LzhHandler.cpp
    CPP/7zip/Archive/LzmaHandler.cpp
    CPP/7zip/Archive/MachoHandler.cpp
    CPP/7zip/Archive/MbrHandler.cpp
    CPP/7zip/Archive/MslzHandler.cpp
    CPP/7zip/Archive/MubHandler.cpp
    CPP/7zip/Archive/NtfsHandler.cpp
    CPP/7zip/Archive/PeHandler.cpp
    CPP/7zip/Archive/PpmdHandler.cpp
    CPP/7zip/Archive/QcowHandler.cpp
    CPP/7zip/Archive/RpmHandler.cpp
    CPP/7zip/Archive/SplitHandler.cpp
    CPP/7zip/Archive/SquashfsHandler.cpp
    CPP/7zip/Archive/SwfHandler.cpp
    CPP/7zip/Archive/UefiHandler.cpp
    CPP/7zip/Archive/VdiHandler.cpp
    CPP/7zip/Archive/VhdHandler.cpp
    CPP/7zip/Archive/VmdkHandler.cpp
    CPP/7zip/Archive/XarHandler.cpp
    CPP/7zip/Archive/XzHandler.cpp
    CPP/7zip/Archive/ZHandler.cpp
    CPP/7zip/Archive/ArchiveExports.cpp
    CPP/7zip/Archive/DllExports2.cpp

    CPP/7zip/Archive/Common/CoderMixer2.cpp
    CPP/7zip/Archive/Common/DummyOutStream.cpp
    CPP/7zip/Archive/Common/FindSignature.cpp
    CPP/7zip/Archive/Common/InStreamWithCRC.cpp
    CPP/7zip/Archive/Common/ItemNameUtils.cpp
    CPP/7zip/Archive/Common/MultiStream.cpp
    CPP/7zip/Archive/Common/OutStreamWithCRC.cpp
    CPP/7zip/Archive/Common/OutStreamWithSha1.cpp
    CPP/7zip/Archive/Common/HandlerOut.cpp
    CPP/7zip/Archive/Common/ParseProperties.cpp

    CPP/7zip/Archive/7z/7zCompressionMode.cpp
    CPP/7zip/Archive/7z/7zDecode.cpp
    CPP/7zip/Archive/7z/7zEncode.cpp
    CPP/7zip/Archive/7z/7zExtract.cpp
    CPP/7zip/Archive/7z/7zFolderInStream.cpp
    CPP/7zip/Archive/7z/7zHandler.cpp
    CPP/7zip/Archive/7z/7zHandlerOut.cpp
    CPP/7zip/Archive/7z/7zHeader.cpp
    CPP/7zip/Archive/7z/7zIn.cpp
    CPP/7zip/Archive/7z/7zOut.cpp
    CPP/7zip/Archive/7z/7zProperties.cpp
    CPP/7zip/Archive/7z/7zSpecStream.cpp
    CPP/7zip/Archive/7z/7zUpdate.cpp
    CPP/7zip/Archive/7z/7zRegister.cpp

    CPP/7zip/Archive/Cab/CabBlockInStream.cpp
    CPP/7zip/Archive/Cab/CabHandler.cpp
    CPP/7zip/Archive/Cab/CabHeader.cpp
    CPP/7zip/Archive/Cab/CabIn.cpp
    CPP/7zip/Archive/Cab/CabRegister.cpp

    CPP/7zip/Archive/Chm/ChmHandler.cpp
    CPP/7zip/Archive/Chm/ChmIn.cpp

    CPP/7zip/Archive/Iso/IsoHandler.cpp
    CPP/7zip/Archive/Iso/IsoHeader.cpp
    CPP/7zip/Archive/Iso/IsoIn.cpp
    CPP/7zip/Archive/Iso/IsoRegister.cpp

    CPP/7zip/Archive/Nsis/NsisDecode.cpp
    CPP/7zip/Archive/Nsis/NsisHandler.cpp
    CPP/7zip/Archive/Nsis/NsisIn.cpp
    CPP/7zip/Archive/Nsis/NsisRegister.cpp

    CPP/7zip/Archive/Rar/RarHandler.cpp
    CPP/7zip/Archive/Rar/Rar5Handler.cpp

    CPP/7zip/Archive/Tar/TarHandler.cpp
    CPP/7zip/Archive/Tar/TarHandlerOut.cpp
    CPP/7zip/Archive/Tar/TarHeader.cpp
    CPP/7zip/Archive/Tar/TarIn.cpp
    CPP/7zip/Archive/Tar/TarOut.cpp
    CPP/7zip/Archive/Tar/TarUpdate.cpp
    CPP/7zip/Archive/Tar/TarRegister.cpp

    CPP/7zip/Archive/Udf/UdfHandler.cpp
    CPP/7zip/Archive/Udf/UdfIn.cpp

    CPP/7zip/Archive/Wim/WimHandler.cpp
    CPP/7zip/Archive/Wim/WimHandlerOut.cpp
    CPP/7zip/Archive/Wim/WimIn.cpp
    CPP/7zip/Archive/Wim/WimRegister.cpp

    CPP/7zip/Archive/Zip/ZipAddCommon.cpp
    CPP/7zip/Archive/Zip/ZipHandler.cpp
    CPP/7zip/Archive/Zip/ZipHandlerOut.cpp
    CPP/7zip/Archive/Zip/ZipIn.cpp
    CPP/7zip/Archive/Zip/ZipItem.cpp
    CPP/7zip/Archive/Zip/ZipOut.cpp
    CPP/7zip/Archive/Zip/ZipUpdate.cpp
    CPP/7zip/Archive/Zip/ZipRegister.cpp

    CPP/7zip/Archive/Archive2.def
    C/Util/LzmaLib/LzmaLib.def
)

# 7zCrcOpt
if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        target_sources(7zip PRIVATE Asm/x86/7zCrcOpt.asm)
        set_source_files_properties(Asm/x86/7zCrcOpt.asm PROPERTIES LANGUAGE ASM_MASM)
    else()
        target_sources(7zip PRIVATE C/7zCrcOpt.c)
    endif()
else()
    target_sources(7zip PRIVATE C/7zCrcOpt.c)
endif()

# AesOpt
if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        target_sources(7zip PRIVATE Asm/x86/AesOpt.asm)
        set_source_files_properties(Asm/x86/AesOpt.asm PROPERTIES LANGUAGE ASM_MASM)
    else()
        target_sources(7zip PRIVATE C/AesOpt.c)
    endif()
else()
    target_sources(7zip PRIVATE C/AesOpt.c)
endif()

# LzFindOpt
if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        target_sources(7zip PRIVATE Asm/x86/LzFindOpt.asm)
        set_source_files_properties(Asm/x86/LzFindOpt.asm PROPERTIES LANGUAGE ASM_MASM)
    else()
        target_sources(7zip PRIVATE C/LzFindOpt.c)
    endif()
else()
    target_sources(7zip PRIVATE C/LzFindOpt.c)
endif()

# LzmaDecOpt
target_sources(7zip PRIVATE C/LzmaDec.c)
if((VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64") OR
    (VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    )
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        target_sources(7zip PRIVATE Asm/x86/LzmaDecOpt.asm)
        set_source_files_properties(Asm/x86/LzmaDecOpt.asm PROPERTIES LANGUAGE ASM_MASM)
    elseif(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        target_sources(7zip PRIVATE Asm/arm64/LzmaDecOpt.S)
        set_source_files_properties(Asm/x86/LzmaDecOpt.asm PROPERTIES LANGUAGE ASM)
    endif()

    get_source_file_property(defs C/LzmaDec.c COMPILE_DEFINITIONS)
    list(APPEND defs "_LZMA_DEC_OPT")
    set_source_files_properties(C/LzmaDec.c PROPERTIES COMPILE_DEFINITIONS "${defs}")
endif()

# Sha1Opt
if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        target_sources(7zip PRIVATE Asm/x86/Sha1Opt.asm)
        set_source_files_properties(Asm/x86/Sha1Opt.asm PROPERTIES LANGUAGE ASM_MASM)
    else()
        target_sources(7zip PRIVATE C/Sha1Opt.c)
    endif()
else()
    target_sources(7zip PRIVATE C/Sha1Opt.c)
endif()

# Sha256Opt
if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        target_sources(7zip PRIVATE Asm/x86/Sha256Opt.asm)
        set_source_files_properties(Asm/x86/Sha256Opt.asm PROPERTIES LANGUAGE ASM_MASM)
    else()
        target_sources(7zip PRIVATE C/Sha256Opt.c)
    endif()
else()
    target_sources(7zip PRIVATE C/Sha256Opt.c)
endif()

# XzCrc64Opt
if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        target_sources(7zip PRIVATE Asm/x86/XzCrc64Opt.asm)
        set_source_files_properties(Asm/x86/XzCrc64Opt.asm PROPERTIES LANGUAGE ASM_MASM)
    else()
        target_sources(7zip PRIVATE C/XzCrc64Opt.c)
    endif()
else()
    target_sources(7zip PRIVATE C/XzCrc64Opt.c)
endif()

target_compile_definitions(7zip
    PUBLIC
        -D_REENTRANT
        -D_FILE_OFFSET_BITS=64
        -D_LARGEFILE_SOURCE
        -DEXTERNAL_CODECS
        -D_7ZIP_LARGE_PAGES
        -DUNICODE
        -D_UNICODE
)

target_include_directories(7zip
    INTERFACE
        $<INSTALL_INTERFACE:include>/7zip/CPP
)

set(PUBLIC_HEADERS
    C/7zTypes.h
    C/Alloc.h
    C/LzFind.h
    C/LzFindMt.h
    C/LzHash.h
    C/LzmaDec.h
    C/LzmaEnc.h
    C/LzmaLib.h
    C/Threads.h
    CPP/7zip/Archive/IArchive.h
    CPP/7zip/ICoder.h
    CPP/7zip/IDecl.h
    CPP/7zip/IPassword.h
    CPP/7zip/IProgress.h
    CPP/7zip/IStream.h
    CPP/7zip/PropID.h
    CPP/Common/Defs.h
    CPP/Common/MyTypes.h
    CPP/Common/MyUnknown.h
    CPP/Common/MyWindows.h
)

install(
    TARGETS 7zip
    EXPORT 7zip-targets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

# Headers makes relative includes so directory structure must be kept
foreach(HEADER ${PUBLIC_HEADERS})
    get_filename_component(HEADER_DIR ${HEADER} DIRECTORY)
    install(
        FILES ${HEADER}
        CONFIGURATIONS Release
        DESTINATION include/7zip/${HEADER_DIR}
    )
endforeach()

include(CMakePackageConfigHelpers)
configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/7zip-config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/7zip-config.cmake"
  INSTALL_DESTINATION "share/7zip"
)
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/7zip-config.cmake"
  DESTINATION "share/7zip"
)

install(
    EXPORT 7zip-targets
    DESTINATION share/7zip
    NAMESPACE 7zip::
)
