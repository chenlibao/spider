import re
import requests
from bs4 import BeautifulSoup


headers = {
    'accept': 'text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36'
}


def get_imgurl(url):
    html = requests.get(url, headers=headers)
    soup = BeautifulSoup(html.text, 'lxml')
    imgs = soup.select('div.photos > article > a > img')
    for img in imgs:
        img_url = img.get('src')
        get_picture(img_url)


def get_picture(img_url):
    name = re.findall('\d+/(.*?)\?', img_url)
    print(name)
    res = requests.get(img_url, headers=headers)
    path = 'D://mongodb/'
    fp = open(path+name[0], 'wb')
    fp.write(res.content)
    fp.close()


if __name__ == "__main__":
    urls = ['https://www.pexels.com/?page={}'.format(str(i)) for i in range(1, 2)]
    for url in urls:
        get_imgurl(url)
        print(url)