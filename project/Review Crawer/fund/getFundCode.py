# coding=utf-8
import requests
from lxml import etree


headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36'
}


def get_code(url):
    html = requests.get(url, headers=headers)
    html.encoding = 'gbk'
    document = etree.HTML(html.text)

    info = document.xpath('// *[ @ id = "code_content"] / div / ul / li / div / a[1] /text()')
    i = 0
    for fund in info:
        str = fund.split('）')[0]
        code = str.split('（')[1]

        with open('fund_code.txt', 'a+') as f:
            f.write(code + '\n')

        with open('fund_url.txt', 'a+') as u:
            fund_url = 'http://fundf10.eastmoney.com/ccmx_%s.html' % code
            u.write(fund_url + '\n')
        i = i + 1
    print('i:', i)


if __name__ == "__main__":
    url = 'http://fund.eastmoney.com/allfund.html'
    get_code(url)