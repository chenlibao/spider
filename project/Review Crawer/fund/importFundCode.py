import requests
import re

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36'
}


def get_info(url):
    html = requests.get(url, headers=headers)
    data = re.findall('var rankData = {datas:(.*),allRecord.*', html.text)
    data_list = eval(data[0])
    fund_code = []

    for i in range(0, len(data_list)):
        onefund_list = data_list[i].strip(',').split(',')
        fund_codes = onefund_list[0]
        fund_code.append(fund_codes)

    return fund_code

