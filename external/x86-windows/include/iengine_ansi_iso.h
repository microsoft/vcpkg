#ifndef _INC_IENGINE_ANSI_ISO
#define _INC_IENGINE_ANSI_ISO

#ifdef __cplusplus 
extern "C" {
#endif 

#if defined(_WIN32) && defined(IENGINE_BUILDING)
#  define IENGINE_API __declspec(dllexport)
#elif defined(_WIN32)
#  define IENGINE_API __declspec(dllimport)
#elif defined(__GNUC__) && defined(IENGINE_BUILDING)
#  define IENGINE_API __attribute__((__visibility__("default")))
#else
#  define IENGINE_API
#endif

typedef unsigned char BYTE;

typedef struct iengine_version 
{
    unsigned int Major;
    unsigned int Minor;
} IENGINE_VERSION, *IENGINE_VERSION_PTR;

/*
* Structure representing supported image formats.
*/
typedef enum
{
    IENGINE_FORMAT_BMP = 0,
    IENGINE_FORMAT_PNG = 1,
    IENGINE_FORMAT_WSQ = 5,
    IENGINE_FORMAT_JPEG2K = 6
} IENGINE_IMAGE_FORMAT;

/** Summary
   Enumeration defining codes for different hardware ID methods.
   Description
   This enumeration is used in <link IEngine_GetHwidByMethod>function
*/
typedef enum {
  /*
   * Automatically selects the hardware ID method based on platform defaults
   * On Linux platforms, IENGINE_HWID_METHOD_MAC is being used
   * On Windows platforms, IENGINE_HWID_METHOD_DISKID is being used
   * On Android platforms, IENGINE_HWID_METHOD_APPID is being used
   */
  IENGINE_HWID_METHOD_AUTO = 0,
  /*
   * Use disk based hardware id
   * This method is available only on Windows platforms
   */
  IENGINE_HWID_METHOD_DISKID = 1,
  /*
   * Use network MAC address based hardware ID
   * This method is available on Linux and Android platforms
   */
  IENGINE_HWID_METHOD_MAC = 2,
  /*
   * Use serial number based hardware ID
   * This method is available only on older Android OS versions ( Android OS version < 7.2.1),
   * and requires appropriate permissions
   */
  IENGINE_HWID_METHOD_SERIALNO = 3,
  /*
   * Use IMEI based hardware ID
   * This method is available only on older Android OS versions ( Android OS version < 7.2.1),
   * and required appropriate permissions
   */
  IENGINE_HWID_METHOD_IMEI = 4,
  /* Use SMBIOS UUID based hardware ID
   * Not supported
   */
  IENGINE_HWID_METHOD_SMBIOS = 5,
  /* Use application ID based hardware ID
   * Available on Android platforms
   */
  IENGINE_HWID_METHOD_AMAZON = 6,
  /* Use application ID based hardware ID
   * Available on Android platforms
   */
  IENGINE_HWID_METHOD_APPID = 7,
  /* Use only network mac address as hardware ID
   * Available on ARM/Android ("IM0<MAC addr>0" form)
   */
  IENGINE_HWID_METHOD_PHY = 8,
  /* Use only network mac address as hardware ID
   * Available on ARM/Android ("IM0<MAC addr>0" form)
   */
  IENGINE_HWID_METHOD_MAC_ADDR = 9
} IENGINE_HWID_METHOD;

/*
* Structure representing a particular minutia (distinctive fingerprint feature found in fingerprint skeleton, such as a bifurcation or an ending). 
*/
typedef struct iengine_minutiae
{
	/*
	* Minutia angle encoded in one byte. Valid range: 0-255. 
	*/
	BYTE angle;

	/*
	* Minutiae x coordinate as stored in the template.
	*/
	unsigned short x;

	/*
	* Minutiae y coordinate as stored in the template.
	*/
	unsigned short y;

	/*
	* Minutiae type (bifurcation/ending)
	*/
	unsigned char type;
/*
Minutiae quality (0.. undefined, 1 - lowest, 255 - highest)
*/
	unsigned char quality;
} IENGINE_MINUTIAE, *IENGINE_MINUTIAE_PTR;

#define IENGINE_MIN_IMAGE_WIDTH 90
#define IENGINE_MAX_IMAGE_WIDTH 1800
#define IENGINE_MIN_IMAGE_HEIGHT 90
#define IENGINE_MAX_IMAGE_HEIGHT 1800

/*
Maximal size of generated ANSI/INCITS 378 template (with only one finger view)
*/
#define IENGINE_MAX_ANSI_TEMPLATE_SIZE 1568
/*
Maximal size of generated ISO/IEC 19794-2 template (with only one finger view)
*/
#define IENGINE_MAX_ISO_TEMPLATE_SIZE 1566


/*
* Enumeration defining codes for different template formats
*/
typedef enum
{
/*
ANSI INCITS 378 template
*/
	ANSI_TEMPLATE = 0,
/*
ISO/IEC 19794-2:2005 template, template version 2.0, 6-byte format for minutiae
*/
	ISO_TEMPLATE = 1,
/*
ILO SID template format, specified in Seafarers Identity Documents convention (Revised), 2003 (No. 185)
*/
	ILO_SID_TEMPLATE = 2,
/*
ISO/IEC 19794-2:2005 template, template version 2.0, 3-byte format for minutiae (compact card encoding)
*/
	ISO_CC_TEMPLATE = 3,
/*
ISO/IEC 19794-2:2011 template, template version 3.0, 6-byte format for minutiae
*/
	ISO_TEMPLATE_V30 = 4,
/*
ISO/IEC 19794-2:2005 template, template version 2.0, 5-byte format for minutiae (normal card encoding)
*/
    ISO_NC_TEMPLATE  = 5
} IENGINE_TEMPLATE_FORMAT;


/*
* Enumeration defining codes for different finger positions
*/
typedef enum
{
	UNKNOWN_FINGER = 0,
	RIGHT_THUMB = 1,
	RIGHT_INDEX = 2,
	RIGHT_MIDDLE = 3,
	RIGHT_RING = 4,
	RIGHT_LITTLE = 5,
	LEFT_THUMB = 6,
	LEFT_INDEX = 7,
	LEFT_MIDDLE = 8,
	LEFT_RING = 9,
	LEFT_LITTLE = 10
} IENGINE_FINGER_POSITION;

/*
Summary: Defines sort order of minutiae points
*/
typedef enum
{
/*
No ordering required.
*/
	SORT_NONE = 0,
/*
Cartesian x-coordinate is used for ordering, ascending order.
*/
	SORT_X_ASC = 1,
/*
Cartesian x-coordinate is used for ordering, descending order.
*/
	SORT_X_DESC = 2,
/*
Cartesian y-coordinate is used for ordering, ascending order.
*/
	SORT_Y_ASC = 3,
/*
Cartesian y-coordinate is used for ordering, descending order.
*/
	SORT_Y_DESC = 4
} IENGINE_SORT_ORDER;

/*
* Defines impression type of fingerprint image 
*/
typedef enum
{
	TYPE_LIVE_SCAN_PLAIN = 0,
	TYPE_LIVE_SCAN_ROLLED = 1,
	TYPE_NONLIVE_SCAN_PLAIN = 2,
	TYPE_NONLIVE_SCAN_ROLLED = 3,
	TYPE_SWIPE = 4,
	TYPE_LIVE_SCAN_CONTACTLESS=9
} IENGINE_IMPRESSION_TYPE;


/* 
* Enumeration defining codes for parameters contained in ISO/IEC 19794-2 and ANSI/INCITS 378 compliant templates.
*/
typedef enum
{
	/* Specifies the 'owner' of the encoding application. This value is read-only (cannot be used with IEngine_SetTemplateParameter function). */
	PARAM_PRODUCT_OWNER = 0,

	/* Specifies the version of the encoding application. This value is read-only (cannot be used with IEngine_SetTemplateParameter function).*/
	PARAM_PRODUCT_VERSION = 1,

	/* Specifies the total length of the template in bytes. This value is read-only (cannot be used with IEngine_SetTemplateParameter function).*/
	PARAM_TEMPLATE_SIZE = 2,

	/*
	* Shall be a 4-bit value between 0 and 15, the most significant bit, if set to a 1,
	* indicates that the equipment was cerified to comply with Appendix F
	* (IAFIS Image Quality Specification, January 29, 1999) of FJIS-RS-0010,
	* the Federal Bureau of Investigations's Electronic Fingerprint Transmission Specification.
	* The other three bits are reserved for future compliance indicators.
	* The default value for this parameter is 0.
	*/
	PARAM_CAPTURE_EQUIPMENT_COMPLIANCE = 3,

	/*
	* Shall be recorded in twelve bits. 
	* A value of all zeros are acceptable and idicate that the capture equipment ID is unreported.
	* In other case, the value of the field is detemined by the vendor.
	* The default value for this parameter is 0.
	*/
	PARAM_CAPTURE_EQUIPMENT_ID = 4,

	/* 
	* Specifies total number of finger views contained within given template.
	* This value is read-only (cannot be used with IEngine_SetTemplateParameter function).
	*/
	PARAM_FINGER_VIEW_COUNT = 5,

	/* Specifies the finger position of the encoded fingerprint. 
	* The values of different finger positions are defined in <link IENGINE_FINGER_POSITION> enum.
	* The default value for this parameter is 0 (UNKNOWN_FINGER).
	*/
	PARAM_FINGER_POSITION = 10,

	/* Specifies the impression type of the encoded fingerprint. 
	* The values of different finger positions are defined in <link IENGINE_IMPRESSION_TYPE> enum.
	* The default value for this parameter is 0 (TYPE_LIVE_SCAN_PLAIN).
	*/
	PARAM_IMPRESSION_TYPE = 11,

	/*
	* Specifies the quality of the encoded fingerprint.
	* This quality number is an overall expression of the quality of the finger record, and represents quality of the original image.
	* A value of 0 represents the lowest possible quality and the value 100 represents the highest possible quality. The numeric
	* values in this field are set in accordance with the general guidelines contained in Section 7.2.5 of ANSI/INCITS 381 standard
	* (Section 8.3.7.3 Quality score of ISO/IEC 19794-4 international standard).
	* The default value for this parameter is 40 (fair quality).
	*/
	PARAM_FINGER_QUALITY = 12
} IENGINE_TEMPLATE_PARAMETER;




// Init, Terminate and other General Functions

IENGINE_API int IEngine_Init();
IENGINE_API int IEngine_InitWithChallenge(unsigned char *challenge, unsigned int * challenge_size, const unsigned char *hmac_signature, unsigned int hmac_size);
IENGINE_API int IEngine_Terminate();
IENGINE_API int IEngine_GetVersion(IENGINE_VERSION *version);
IENGINE_API const char* IEngine_GetVersionString();
IENGINE_API int IEngine_GetHwid(char *hwid,int *length); //deprecated
IENGINE_API int IEngine_GetHwidByMethod(IENGINE_HWID_METHOD method, char *hwid, int *length);
IENGINE_API char * IEngine_GetErrorMessage( int errcode );
IENGINE_API int IEngine_SetDebugLevel(int debugLevel);
IENGINE_API int IEngine_SetLicenseContent(const unsigned char *licenseContent, int length);
IENGINE_API int IEngine_GetLicenseValue(const char *key, char *value, int *valueLength);


// Conversion Functions

IENGINE_API int ANSI_ConvertToISO(const BYTE *ansiTemplate,int *length,BYTE *isoTemplate);
IENGINE_API int ISO_ConvertToANSI(const BYTE *isoTemplate,int *length,BYTE *ansiTemplate);
IENGINE_API int ISO_ConvertToISOCardCC(const BYTE *isoTemplate,int maximumMinutiaeCount, IENGINE_SORT_ORDER minutiaeOrder, IENGINE_SORT_ORDER minutiaeSecondaryOrder, int *length,BYTE *isoCCTemplate);
IENGINE_API int ISO_CARD_CC_ConvertToISO(const BYTE *isoCCTemplate,int *length,BYTE *isoTemplate);
IENGINE_API int IEngine_GetImageQuality( int width, int height, const BYTE *rawImage, int *quality );
IENGINE_API int IEngine_LoadBMP(const char *filename,int *width, int *height,BYTE *rawImage, int *length);
IENGINE_API int IEngine_MakeBMP(int width, int height,const BYTE *rawImage, BYTE *bmpImageData, int *length);
IENGINE_API int IEngine_ConvertBMP(const BYTE *bmpImage,int *width, int *height,BYTE *rawImage, int *length);
IENGINE_API int IEngine_ConvertToRaw(const BYTE *imageData, int imageLength, IENGINE_IMAGE_FORMAT imageFormat, int *width, int *height,BYTE *rawImage, int *rawImageLength);
IENGINE_API int IEngine_ConvertRawToImage(const BYTE *rawImage, int width, int height,BYTE *outImage, IENGINE_IMAGE_FORMAT imageFormat, int rate, int *length);
IENGINE_API int IEngine_ResizeImage(int width, int height, const BYTE *rawImage, int dpi, int *outWidth, int *outHeight, BYTE *outImage);
IENGINE_API int IEngine_ResizeImageInPlace(int width, int height, BYTE *rawImage, int dpi, int *outWidth, int *outHeight);

#define ISO_IMAGE_FORMAT_UNCOMPRESSED 0
#define ISO_IMAGE_FORMAT_UNCOMPRESSED_BIT_PACKED 1
#define ISO_IMAGE_FORMAT_WSQ 2
#define ISO_IMAGE_FORMAT_JPEG 3
#define ISO_IMAGE_FORMAT_JPEG2000 4
#define ISO_IMAGE_FORMAT_PNG 5

IENGINE_API int IEngine_ConvertRawToIso19794_4(const unsigned char *rawImage,int width,int height,unsigned char fingerPosition, unsigned char imageFormat, unsigned int dpiX,unsigned int dpiY, unsigned char *outData,int rate,int *length);
IENGINE_API int IEngine_ConvertIso19794_4ToRaw(const unsigned char *isoFingerImage,unsigned int isoImageLength,int *width,int *height,unsigned char *fingerPosition, unsigned char *imageFormat, unsigned int *dpiX,unsigned int *dpiY, unsigned char *rawImage,int *rawImageLength);


// Template Extraction and Matching Functions

IENGINE_API int ANSI_CreateTemplate(int width, int height, const BYTE *rawImage, BYTE * ansiTemplate);
IENGINE_API int ANSI_CreateTemplate2(int width, int height, const BYTE *rawImage, int dpi, BYTE * ansiTemplate);
IENGINE_API int ANSI_CreateTemplateEx(int width, int height, const BYTE *rawImage, BYTE * ansiTemplate, const char *skeletonImageFile, const char *binarizedImageFile, const char *minutiaeImageFile);
IENGINE_API int ANSI_VerifyMatch(const BYTE *probeTemplate, const BYTE *galleryTemplate, int maxRotation, int *score); 
IENGINE_API int ANSI_VerifyMatchEx(const BYTE *probeTemplate, int probeView, const BYTE *galleryTemplate, int galleryView, int maxRotation, int *score); 

IENGINE_API int ISO_CreateTemplate(int width, int height, const BYTE *rawImage, BYTE * isoTemplate);
IENGINE_API int ISO_CreateTemplate2(int width, int height, const BYTE *rawImage, int dpi, BYTE * isoTemplate);
IENGINE_API int ISO_CreateTemplateEx(int width, int height, const BYTE *rawImage, BYTE * isoTemplate, const char *skeletonImageFile, const char *binarizedImageFile, const char *minutiaeImageFile);
IENGINE_API int ISO_CreateTemplateEx2(int width, int height, const BYTE *rawImage, BYTE * isoTemplate, BYTE *filteredImage, BYTE *binarizedImage, BYTE *skeletonImage, int *blockWidth, int *blockHeight, BYTE * bMask, BYTE *bOrientation, BYTE * bQuality);
IENGINE_API int ISO_CreateTemplateInPlace(int width,int height,int dpi,BYTE *rawImageBuffer,int *rawImageBufferLength, BYTE *workBuffer,int *workBufferLength, BYTE *isoTemplate); // On embedded systems only
IENGINE_API int ISO_VerifyMatch(const BYTE *probeTemplate, const BYTE *galleryTemplate, int maxRotation, int *score);
IENGINE_API int ISO_VerifyMatchEx(const BYTE *probeTemplate, int probeView, const BYTE *galleryTemplate, int galleryView, int maxRotation, int *score);
IENGINE_API int ISO_VerifyMatchEx2(const BYTE *probeTemplate, int probeView, const BYTE *galleryTemplate, int galleryView, int maxRotation, int *score,int*dx,int *dy,int *rotation,int *associationCount,BYTE *assocProbeMinutiae,BYTE *assocGalleryMinutiae,BYTE *assocQuality);


// Template Manipulation Functions

IENGINE_API int ANSI_GetTemplateParameter(const BYTE *ansiTemplate, IENGINE_TEMPLATE_PARAMETER parameter, int *value);
IENGINE_API int ANSI_SetTemplateParameter(BYTE *ansiTemplate, IENGINE_TEMPLATE_PARAMETER parameter, int value);
IENGINE_API int ANSI_GetFingerView(const BYTE *ansiTemplate,int fingerView,BYTE *outTemplate);
IENGINE_API int ANSI_DrawMinutiae(const BYTE *ansiTemplate,int width,int height, unsigned char *inputImage, unsigned char *outputBmpImage,int *outputImageLength);
IENGINE_API int ANSI_GetMinutiae(const BYTE *ansiTemplate, IENGINE_MINUTIAE minutiae[256], int *minutiaeCount);
IENGINE_API int ANSI_MergeTemplates(const BYTE *referenceTemplate,const BYTE *addedTemplate,int *length,BYTE *outTemplate);
IENGINE_API int ANSI_LoadTemplate(const char *filename, BYTE *ansiTemplate);
IENGINE_API int ANSI_RemoveMinutiae(const BYTE *inTemplate, int maximumMinutiaeCount, int *length, BYTE *outTemplate);
IENGINE_API int ANSI_SaveTemplate(const char *filename, const BYTE *ansiTemplate);

IENGINE_API int ISO_GetTemplateParameter(const BYTE *isoTemplate, IENGINE_TEMPLATE_PARAMETER parameter, int *value);
IENGINE_API int ISO_SetTemplateParameter(BYTE *isoTemplate, IENGINE_TEMPLATE_PARAMETER parameter, int value);
IENGINE_API int ISO_GetFingerView(const BYTE *isoTemplate,int fingerView,BYTE *outTemplate);
IENGINE_API int ISO_DrawMinutiae(const BYTE *isoTemplate,int width,int height, unsigned char *inputImage, unsigned char *outputBmpImage,int *outputImageLength);
IENGINE_API int ISO_GetMinutiae(const BYTE *isoTemplate, IENGINE_MINUTIAE minutiae[256], int *minutiaeCount);
IENGINE_API int ISO_MergeTemplates(const BYTE *referenceTemplate,const BYTE *addedTemplate,int *length,BYTE *outTemplate);
IENGINE_API int ISO_LoadTemplate(const char *filename, BYTE *isoTemplate);
IENGINE_API int ISO_RemoveMinutiae(const BYTE *inTemplate, int maximumMinutiaeCount, int *length, BYTE *outTemplate);
IENGINE_API int ISO_SaveTemplate(const char *filename, const BYTE *isoTemplate);

IENGINE_API int IEngine_ConvertTemplate(IENGINE_TEMPLATE_FORMAT inputTemplateType, const BYTE *inputTemplate, IENGINE_TEMPLATE_FORMAT outputTemplateType, int *length, BYTE *outputTemplate);

IENGINE_API int ISO_CARD_CC_GetMinutiaeData(const BYTE *isoCCTemplate, int *minutiaeCount, BYTE *minutiaeData, int *minutiaeDataSize);

#define IENGINE_E_UNKNOWN_MSG		"Unknown error."
#define IENGINE_E_NOERROR             0
#define IENGINE_E_NOERROR_MSG	    "No error."
#define IENGINE_E_BADPARAM            1101
#define IENGINE_E_BADPARAM_MSG	    "Invalid parameter type provided."
#define IENGINE_E_BLANKIMAGE          1114
#define IENGINE_E_BLANKIMAGE_MSG    "Image is blank or contains non-recognizable fingerprint."
#define IENGINE_E_BADIMAGE            1115
#define IENGINE_E_BADIMAGE_MSG      "Invalid image or unsupported image format."
#define IENGINE_E_INIT			      1116
#define IENGINE_E_INIT_MSG		    "Library was not initialized."
#define IENGINE_E_FILE                1117
#define IENGINE_E_FILE_MSG			"Error occurred while opening/reading file."
#define IENGINE_E_MEMORY              1120
#define IENGINE_E_MEMORY_MSG		"Memory allocation failed."
#define IENGINE_E_NULLPARAM           1121
#define IENGINE_E_NULLPARAM_MSG		"NULL input parameter provided."
#define IENGINE_E_OTHER               1122
#define IENGINE_E_OTHER_MSG			"Other unspecified error."
#define IENGINE_E_NOTSUPPORTED        1123
#define IENGINE_E_NOTSUPPORTED_MSG	"The function is not supported for this version of product."
#define IENGINE_E_BADFORMAT           1132
#define IENGINE_E_BADFORMAT_MSG     "Unsupported format."
#define IENGINE_E_BADVALUE            1133
#define IENGINE_E_BADVALUE_MSG      "Invalid value provided."
#define IENGINE_E_BADTEMPLATE         1135
#define IENGINE_E_BADTEMPLATE_MSG	"Invalid template or unsupported template format."
#define IENGINE_E_READONLY            1136
#define IENGINE_E_READONLY_MSG	    "Value cannot be modified."
#define IENGINE_E_NOTDEFINED          1137
#define IENGINE_E_NOTDEFINED_MSG	"Value is not defined."
#define IENGINE_E_NULLTEMPLATE        1138
#define IENGINE_E_NULLTEMPLATE_MSG  "Template is NULL (contains no finger view)."
#define IENGINE_E_SMALLIMAGE          1146
#define IENGINE_E_SMALLIMAGE_MSG    "Image is too small. Minimal size of image must be 90x90."
#define IENGINE_E_BIGIMAGE            1147
#define IENGINE_E_BIGIMAGE_MSG   	"Image is too big. Maximal size of image must be 1800x1800."
#define IENGINE_E_BADDPI              1148
#define IENGINE_E_BADDPI_MSG        "Image does not have required DPI or bitrate."

#ifdef __cplusplus 
}
#endif 

#endif
