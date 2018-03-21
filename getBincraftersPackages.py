import html
import http
import gzip
import urllib.request
import json
import smtplib
from email.message import EmailMessage
import datetime
import sys
import re

def get_bincrafters():
    bincrafterspackages = []

    pageno = 1
    while True:
        url = 'https://api.github.com/orgs/bincrafters/repos?page={}&per_page=100'.format(pageno)
        print("[GITHUB] Fetching {}".format(url))

        today = datetime.datetime.utcnow()

        pageno = pageno + 1

        with urllib.request.urlopen(url) as res:
            doc = res.read().decode('utf-8')
            jdoc = json.loads(doc)
            print("total count = {}".format(len(jdoc)))
            if len(jdoc) < 100:
                break
            try:
                for item in jdoc:
                    
                    name = item['name']
                    
                    created_at = item['created_at']
                    dt_created_at = datetime.datetime.strptime(created_at, "%Y-%m-%dT%H:%M:%SZ")
                    updated_at = item['updated_at']
                    dt_updated_at = datetime.datetime.strptime(updated_at, "%Y-%m-%dT%H:%M:%SZ")
                    
                    # if today - dt_updated_at > datetime.timedelta(days=3):
                    #     break
                    # doc.append("""<div class="github"><div>{} comments</div><div>updated {}</div><div>{}</div><div><a href="{}">{}</a></div></div>""".format(
                    #     item['comments'],
                    #     updated_at,
                    #     repo,
                    #     item['html_url'],
                    #     html.escape(item['title'])
                    # ))

                    massaged_name = re.sub('^conan-', '', name)
                    massaged_name = re.sub('_', '-', massaged_name)
                    massaged_name = massaged_name.lower()
                    bincrafterspackages.append({
                        "full_name": item['full_name'],
                        "html_url": item['html_url'],
                        "massaged_name": massaged_name,
                        "created_at": created_at,
                        "updated_at": updated_at,
                        "open_issues_count": item['open_issues_count'],
                        "watchers_count": item['watchers_count'],
                        "stargazers_count": item['stargazers_count'],
                        "default_branch": item['default_branch'],
                    })
            except:
                bincrafterspackages.append({ "error": True})

    bincrafterspackages.sort(key=lambda a: a['massaged_name'])

    return json.dumps(bincrafterspackages, indent=4, sort_keys=True)

print(get_bincrafters())
