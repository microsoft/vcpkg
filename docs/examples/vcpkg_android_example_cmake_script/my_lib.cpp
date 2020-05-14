#include <json/json.h>

int answer()
{
  Json::Value meaning_of;
  meaning_of["everything"] = 42;
  return meaning_of["everything"].asInt();
}
