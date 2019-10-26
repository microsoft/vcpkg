#ifndef __VCPKG_7ZIP_7ZIP_H_
#define __VCPKG_7ZIP_7ZIP_H_

#include <windows.h>

#include "7zip/C/7zTypes.h"
#include "7zip/guids.h"

#ifndef _7ZIP_STATIC
    #ifdef _7ZIP_DLLEXPORT
        #define _7ZIP_API __declspec(dllexport)
    #else
        #define _7ZIP_API __declspec(dllimport)
    #endif
#else
    #define _7ZIP_API

    //
    // *** BEWARE ***
    //
    // Some globals are not initialized when using 7z as a static library so
    // some functions will fail as format/codec seems unknown.
    //
    // Call 'Register' functions so proper variables will be intialized.
    //
    // Here are the minimal registration function calls to make for supporting
    // default compression level with 7z:
    //
    //  ::lib7zCrcTableInit();
    //  NArchive::N7z::Register();
    //  NCompress::RegisterCodecCopy();
    //  NCompress::NBcj::RegisterCodecBCJ();
    //  NCompress::NLzma::RegisterCodecLZMA();
    //  NCompress::NLzma2::RegisterCodecLZMA2();
    //  NCrypto::N7z::RegisterCodec7zAES();
    //  NCrypto::RegisterCodecAES256CBC();
    //
    // There may/will be missing 'register' functions to call depending on what
    // is done. For example maximum compression level also requires calling:
    //
    // NCompress::NBcj2::RegisterCodecBCJ2();
    //
    // Is binary size is not an issue you can call all 'Register' functions
    //

    void* lib7zCrcTableInit();

    namespace NArchive::N7z { void* Register(); }
    namespace NArchive::NApm { void* Register(); }
    namespace NArchive::NAr { void* Register(); }
    namespace NArchive::NArj { void* Register(); }
    namespace NArchive::NMub::NBe { void* Register(); }
    namespace NArchive::NBz2 { void* Register(); }
    namespace NArchive::NCab { void* Register(); }
    namespace NArchive::NCoff { void* Register(); }
    namespace NArchive::NCom { void* Register(); }
    namespace NArchive::NCpio { void* Register(); }
    namespace NArchive::NCramfs { void* Register(); }
    namespace NArchive::NDmg { void* Register(); }
    namespace NArchive::NElf { void* Register(); }
    namespace NArchive::NExt { void* Register(); }
    namespace NArchive::NFat { void* Register(); }
    namespace NArchive::NFlv { void* Register(); }
    namespace NArchive::NGpt { void* Register(); }
    namespace NArchive::NGz { void* Register(); }
    namespace NArchive::NHfs { void* Register(); }
    namespace NArchive::NChm::NHxs { void* Register(); }
    namespace NArchive::NIhex { void* Register(); }
    namespace NArchive::NIso { void* Register(); }
    namespace NArchive::NLzh { void* Register(); }
    namespace NArchive::NLzma::NLzma86Ar { void* Register(); }
    namespace NArchive::NLzma::NLzmaAr { void* Register(); }
    namespace NArchive::NMacho { void* Register(); }
    namespace NArchive::NMbr { void* Register(); }
    namespace NArchive::NMslz { void* Register(); }
    namespace NArchive::NNsis { void* Register(); }
    namespace NArchive::NPe { void* Register(); }
    namespace NArchive::NPpmd { void* Register(); }
    namespace NArchive::NQcow { void* Register(); }
    namespace NArchive::NRar5 { void* Register(); }
    namespace NArchive::NRar { void* Register(); }
    namespace NArchive::NRpm { void* Register(); }
    namespace NArchive::NSplit { void* Register(); }
    namespace NArchive::NSquashfs { void* Register(); }
    namespace NArchive::NSwf { void* Register(); }
    namespace NArchive::NSwfc { void* Register(); }
    namespace NArchive::NTar { void* Register(); }
    namespace NArchive::NTe { void* Register(); }
    namespace NArchive::NUdf { void* Register(); }
    namespace NArchive::NVdi { void* Register(); }
    namespace NArchive::NVhd { void* Register(); }
    namespace NArchive::NVmdk { void* Register(); }
    namespace NArchive::NWim { void* Register(); }
    namespace NArchive::NXar { void* Register(); }
    namespace NArchive::NXz { void* Register(); }
    namespace NArchive::NZ { void* Register(); }
    namespace NArchive::NZip { void* Register(); }
    namespace NArchive::Ntfs { void* Register(); }
    namespace NArchive::NUefi::UEFIc { void* Register(); }
    namespace NArchive::NUefi::UEFIf { void* Register(); }

    namespace NCrypto::N7z { void* RegisterCodec7zAES(); }
    namespace NCrypto { void* RegisterCodecAES256CBC(); }

    namespace NCompress::NBcj { void* RegisterCodecBCJ(); }
    namespace NCompress::NBcj2 { void* RegisterCodecBCJ2(); }
    namespace NCompress { void* RegisterCodecCopy(); }
    namespace NCompress::NByteSwap { void* RegisterCodecsByteSwap(); }
    namespace NCompress::NBranch { void* RegisterCodecsBranch(); }
    namespace NCompress::NBZip2 { void* RegisterCodecBZip2(); }
    namespace NCompress::NDelta { void* RegisterCodecDelta(); }
    namespace NCompress::NDeflate { void* RegisterCodecDeflate(); }
    namespace NCompress::NDeflate { void* RegisterCodecDeflate64(); }
    namespace NCompress::NLzma { void* RegisterCodecLZMA(); }
    namespace NCompress::NLzma2 { void* RegisterCodecLZMA2(); }
    namespace NCompress::NPpmd { void* RegisterCodecPPMD(); }
    namespace NCompress { void* RegisterCodecsRar(); }

#endif  // _7ZIP_STATIC

#ifdef __cplusplus
extern "C" {
#endif

HRESULT _7ZIP_API STDAPICALLTYPE GetNumberOfFormats(UInt32* numFormats);
HRESULT _7ZIP_API STDAPICALLTYPE GetNumberOfMethods(UInt32* numMethods);
HRESULT _7ZIP_API STDAPICALLTYPE GetMethodProperty(UInt32 codecIndex, PROPID propID, PROPVARIANT* value);
HRESULT _7ZIP_API STDAPICALLTYPE GetHandlerProperty2(UInt32 formatIndex, PROPID propID, PROPVARIANT* value);
HRESULT _7ZIP_API STDAPICALLTYPE CreateObject(const GUID* clsid, const GUID* iid, void** outObject);

#ifdef __cplusplus
}  // extern "C"
#endif

#endif  // __VCPKG_7ZIP_7ZIP_H_
