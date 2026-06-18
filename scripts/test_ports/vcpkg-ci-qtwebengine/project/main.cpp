#ifdef REQUIRE_PDF
#include <QPdfDocument>
#endif
#ifdef REQUIRE_WEBENGINE
#include <QWebEnginePage>
#endif

int main()
{
#ifdef REQUIRE_PDF
    QPdfDocument doc(nullptr);
#endif
#ifdef REQUIRE_WEBENGINE
    QObject* parent = nullptr;
    QWebEnginePage page(parent);
#endif
    return 0;
}
