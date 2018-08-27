from scrapy.http import Request
from scrapy.spider import CrawlSpider
from scrapy.selector import Selector
from jianshu1.items import Jianshu1Item


class jianshu1(CrawlSpider):
    name = 'jianshu1'
    start_url = ['https://www.jianshu.com/c/MZp7Ey?order_by=added_at&page=1']

    def parse(self, response):
        item = Jianshu1Item()
        selector = Selector(response)
        infos = selector.xpath('//ul[@class="note-list"]/li')
        print('infos:', infos)
        print('------------------------------')
        for info in infos:
            user = info.xpath('div/div/a[@class="nickname"]/text()').extract()[0].strip()
            title = info.xpath('div/a[@class="title"]/text()').extract()[0].strip()
            comment = info.xpath('//*[@id="note-31137822"]/div/div/a[2]/text()').extract()
            if comment:
                comment = comment[0].strip()
            else:
                comment = '0'
            like = info.xpath('div/div/span/text()').extract()[0].strip()
            content = info.xpath('').extract()[0].strip()

            item['user'] = user
            item['title'] = title
            item['comment'] = comment
            item['like'] = like
            item['content'] = content

            yield item

        urls = ['https://www.jianshu.com/c/MZp7Ey?order_by=added_at&page={}'.format(str(i)) for i in range(2, 3)]
        for url in urls:
            yield Request(url, callback=self.parse)