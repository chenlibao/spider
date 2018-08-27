# catch 588ku.com picture to local
# url = http://588ku.com/yishuzi-zt/776/p2.html

import requests
from bs4 import BeautifulSoup
import time
import random

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36'
}


def get_imgurl(url):
    html1 = requests.get(url, headers=headers)
    soup1 = BeautifulSoup(html1.text, 'lxml')
    imgs1 = soup1.select('#png-pic-box > li > div > a')
    for img in imgs1:
        i = random.randint(1, 3)
        imgurl = img.get('href')
        get_src(imgurl)
        time.sleep(i)


def get_src(imgurl):
    html2 = requests.get(imgurl, headers=headers)
    soup2 = BeautifulSoup(html2.text, 'lxml')
    imgs2 = soup2.select('body > div > div > div > div > img')
    name = imgs2[0].get('title')
    src = imgs2[0].get('src')
    get_img(src, name)


def get_img(src, name):
    html3 = requests.get(src, headers=headers)
    path = 'D://mongodb/'
    fp = open(path+name+'.jpg', 'wb')
    fp.write(html3.content)
    fp.close()


if __name__ == "__main__":
    urls = ['http://588ku.com/yishuzi-zt/776/p{}.html'.format(str(i)) for i in range(2, 3)]
    for url in urls:
        get_imgurl(url)