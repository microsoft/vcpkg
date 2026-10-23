#include <jxl/decode.h>

int main()
{
	JxlDecoder* decoder = JxlDecoderCreate(NULL);
	JxlDecoderDestroy(decoder);

	const uint32_t version = JxlDecoderVersion();
	return (int) version;
}
