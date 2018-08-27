from scrapy.spider import CrawlSpider
from scrapy.selector import Selector
from xiaozhu.items import XiaozhuItem


class xiaozhu(CrawlSpider):
    name = 'xiaozhu'
    start_urls = ['http://sh.xiaozhu.com/fangzi/3198744731.html']

    def parse(self, response):
        item = XiaozhuItem()
        selector = Selector(response)
        title = selector.xpath('//div[@class="pho_info"]/h4/em/text()').extract()[0]
        address = selector.xpath('//div/p/span[@class="pr5"]/text()').extract()[0].strip()
        price = selector.xpath('//*[@id="pricePart"]/div/span/text()').extract()[0]
        lease_type = selector.xpath('//*[@id="introduce"]/li/h6/text()').extract()[0]
        suggestion = selector.xpath('//*[@id="introduce"]/li/h6/text()').extract()[1]
        bed = selector.xpath('//*[@id="introduce"]/li/h6/text()').extract()[2]

        item['title'] = title
        item['address'] = address
        item['price'] = price
        item['lease_type'] = lease_type
        item['suggestion'] = suggestion
        item['bed'] = bed
        yield item