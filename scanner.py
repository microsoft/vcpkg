import html
import http
import gzip
import urllib.request
import json
import smtplib
from email.message import EmailMessage
import datetime
import sys

def get_github():
    githubdoc = []

    url = 'https://api.github.com/search/issues?q=vcpkg+-repo:microsoft/vcpkg&sort=updated&per_page=50'
    print("[GITHUB] Fetching {}".format(url))

    with urllib.request.urlopen(url) as res:
        doc = res.read().decode('utf-8')
        jdoc = json.loads(doc)
        print("total count = {}".format(jdoc['total_count']))
        today = datetime.datetime.utcnow()
        try:
            if 'items' in jdoc:
                for item in jdoc['items'][:50]:
                    updated_at = item['updated_at']
                    dt_updated_at = datetime.datetime.strptime(updated_at, "%Y-%m-%dT%H:%M:%SZ")
                    if today - dt_updated_at > datetime.timedelta(days=3):
                        break
                    repo = item['repository_url'][29:]
                    githubdoc.append("""<div class="github"><div>{} comments</div><div>updated {}</div><div>{}</div><div><a href="{}">{}</a></div></div>""".format(item['comments'], updated_at, repo, item['html_url'], html.escape(item['title'])))
            else:
                githubdoc.append("""<div class="github">{}</div>""".format(html.escape(json.dumps(jdoc))))
        except:
            githubdoc.append("<div>{}</div>".format(html.escape(sys.exc_info())))

    return "<h2>Github last 3 days ({} issues+PRs) <a href=\"{}\">[link]</a></h2>{}".format(len(githubdoc), url, "".join(githubdoc))

def get_google():
    googledoc = []

    url = 'https://www.googleapis.com/customsearch/v1?key=AIzaSyAgDJeOcCtOgYSLPboFLf_3SsV9TqSYTFE&cx=016162264654347836401:8cwjt4hwu-k&q=vcpkg+-site:github.com&dateRestrict=d5&exactTerms=vcpkg'
    print("[GOOGLE] Fetching {}".format(url))

    with urllib.request.urlopen(url) as res:
        jdoc = json.loads(res.read().decode('utf-8'))
        try:
            if 'items' in jdoc:
                for item in jdoc['items'][:30]:
                    googledoc.append("""<div class="google"><div><a href="{}">{}</a></div><div>{}</div></div>""".format(item['htmlFormattedUrl'], item['htmlTitle'][:120], item['htmlSnippet']))
            else:
                googledoc.append("""<div class="google">{}</div>""".format(html.escape(json.dumps(jdoc))))
        except:
            googledoc.append("<div>{}</div>".format(html.escape(sys.exc_info())))

    return "<h2>Google last 4 days ({} hits) <a href=\"{}\">[link]</a></h2>{}".format(len(googledoc), url, "".join(googledoc))

def get_stackoverflow():
    stackdoc = []

    fromdate = (datetime.datetime.now() - datetime.timedelta(days=14)).timestamp()
    url = 'https://api.stackexchange.com/2.2/search/excerpts?order=desc&sort=activity&q=vcpkg&site=stackoverflow&fromdate={}'.format(int(fromdate))
    print("[STACK OVERFLOW] Fetching {}".format(url))
    http.client.HTTPConnection.debuglevel = 1
    with urllib.request.urlopen(urllib.request.Request(url, headers={"Accept-Encoding": "gzip"})) as res:
        doc1 = res.read()
        doc = gzip.decompress(doc1)
        jdoc = json.loads(doc.decode('utf-8'))
        try:
            if 'items' in jdoc:
                for item in jdoc['items'][:30]:
                    activitydate = datetime.datetime.fromtimestamp(int(item['last_activity_date'])).isoformat()
                    if item['item_type'] == "question":
                        link = "https://stackoverflow.com/questions/{}".format(item["question_id"])
                    else:
                        link = "https://stackoverflow.com/questions/{}#{}".format(item["question_id"], item["answer_id"])
                    stackdoc.append("""<div class="stacko"><div><a href="{}">{}</a></div><div>Last Activity: {}</div><div>{}</div></div>""".format(link, html.escape(item['title']), activitydate, html.escape(item['excerpt'])))
            else:
                stackdoc.append("""<div class="stacko">{}</div>""".format(html.escape(json.dumps(jdoc))))
        except:
            stackdoc.append("<div>{}</div>".format(html.escape(sys.exc_info())))
    return "<h2>Stackoverflow last 14 days ({} posts) <a href=\"{}\">[link]</a></h2>{}".format(len(stackdoc), url, "".join(stackdoc))

stackodoc = get_stackoverflow()
googledoc = get_google()
githubdoc = get_github()

msg = EmailMessage()
msg.set_content("""<style>.github { margin: 10px 0px; border-left: 3px #aaf solid; background-color: #eef; }"""
    + """ .google { margin: 10px 0px; border-left: 3px #afa solid; background-color: #efe; }"""
    + """ .stacko { margin: 10px 0px; border-left: 3px #faa solid; background-color: #fee; }"""
    +""" </style>""" + githubdoc + googledoc + stackodoc + "<div>end of message</div>", subtype='html')

msg['Subject'] = '[vcpkg] Automatic social analysis for vcpkg {}'.format(datetime.datetime.now().isoformat())
msg['From'] = "vcpkg.social.analysis@xyz123.noreply"
msg['To'] = "vcpkg@microsoft.com,roschuma@microsoft.com,alkarata@microsoft.com,ericmitt@microsoft.com"

with smtplib.SMTP(host='microsoft-com.mail.protection.outlook.com', port=25, timeout=10) as smtp:
    print("connected")
    smtp.set_debuglevel(2)
    smtp.ehlo()
    print("ehlo")
    smtp.starttls()
    print("startls")
    smtp.ehlo()
    print("ehlo")
    smtp.send_message(msg)

print('Scan and email completed.')
