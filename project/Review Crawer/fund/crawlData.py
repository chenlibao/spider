# coding=utf-8
from selenium import webdriver
from bs4 import BeautifulSoup
import time
import random
from pymongo import MongoClient
import datetime


client = MongoClient('localhost', 27017)
fund_db = client['fund_db']
fund_data = fund_db['fund_data']
fund_no_data = fund_db['fund_no_data']


def get_info(url):
    print(url)
    opt = webdriver.ChromeOptions()
    opt.set_headless()
    driver = webdriver.Chrome(options=opt)
    driver.maximize_window()
    driver.get(url)
    driver.implicitly_wait(5)
    day = datetime.date.today()
    today = '%s' % day

    with open('jijin1.html', 'w', encoding='utf-8') as f:
        f.write(driver.page_source)
    time.sleep(1)
    file = open('jijin1.html', 'r', encoding='utf-8')
    soup = BeautifulSoup(file, 'lxml')

    try:
        fund = soup.select('#bodydiv > div > div > div.basic-new > div.bs_jz > div.col-left > h4 > a')[0].get_text()
        scale = soup.select('#bodydiv > div > div.r_cont > div.basic-new > div.bs_gl > p > label > span')[2].get_text().strip().split()[0]
        table = soup.select('#cctable > div > div > table')
        trs = table[0].select('tbody > tr')
        for tr in trs:
            code = tr.select('td > a')[0].get_text()
            name = tr.select('td > a')[1].get_text()
            price = tr.select('td > span')[0].get_text()
            try:
                round(float(price), 2)
            except ValueError:
                price = 0
            num = tr.select('td.tor')[3].get_text()
            market = float(num.replace(',', '')) * float(price)

            data = {
                'crawl_date': today,
                'code': code,
                'fund': fund.split(' (')[0],
                'scale': scale,
                'name': name,
                'price': round(float(price), 2),
                'num': round(float(num.replace(',', '')), 2),
                'market_value': round(market, 2),
                'fund_url': url
            }
            fund_data.insert(data)
    except IndexError:
        info = {
            'url': url
        }
        fund_no_data.insert(info)


if __name__ == "__main__":
    with open('fund_url.txt', 'r') as f:
        i = 0
        for url in f.readlines():
            get_info(url)
            time.sleep(random.randint(0, 2))
            i = i + 1
        print('run times:', i)