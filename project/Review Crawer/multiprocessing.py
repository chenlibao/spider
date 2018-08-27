import requests
import re
import time
from multiprocessing import Pool

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36'
}


def get_info(url):
    res = requests.get(url, headers=headers)
    names = re.findall('<h2>(.*?)</h2>', res.text, re.S)
    contents = re.findall('<div class="content">.*?<span>(.*?)</span>', res.text, re.S)
    laughs = re.findall('<i class="number">(\d+)</i> 好笑', res.text, re.S)
    comments = re.findall('<i class="number">(\d+)</i> 评论', res.text, re.S)
    for name, content, laugh, comment in zip(names, contents, laughs, comments):
        data = {
            'name': name,
            'content': content,
            'laugh': laugh,
            'comment': comment
        }
        print(data)


if __name__ == "__main__":
    urls = ['https://www.qiushibaike.com/8hr/page/{}/'.format(str(i)) for i in range(1, 2)]

    # t_start1 = time.time()
    # for url in urls:
    #     get_info(url)
    # t_end1 = time.time()
    # print('time:', t_end1-t_start1)

    t_start2 = time.time()
    pool = Pool(processes=2)
    pool.map(get_info(url), urls)
    t_end2 = time.time()
    print('time2:', t_end2-t_start2)
    #
    # t_start3 = time.time()
    # pool = Pool(processes=4)
    # pool.map(get_info(url), urls)
    # t_end3 = time.time()
    # print('time3:', t_end3-t_start3)