#include <glib.h>
#include <gmime/gmime.h>

void verify_callback(GMimeObject *parent, GMimeObject *part, gpointer user_data)
{
#ifdef ENABLE_CRYPTO
	if (GMIME_IS_MULTIPART_SIGNED(part))
    {
		GMimeMultipartSigned *mps = (GMimeMultipartSigned *)part;
		GError *err = NULL;
		GMimeSignatureList *signatures = g_mime_multipart_signed_verify(mps, GMIME_VERIFY_NONE, &err);
        g_object_unref(signatures);
    }
#endif
}

int main()
{
    g_mime_init();
    GMimeParser *parser = g_mime_parser_new();
    GMimeMessage *message = g_mime_parser_construct_message(parser, NULL);
	g_mime_message_foreach(message, verify_callback, NULL);
    g_object_unref(message);
    g_object_unref(parser);
    return 0;
}
