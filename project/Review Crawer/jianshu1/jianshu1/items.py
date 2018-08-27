# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

from scrapy.item import Item, Field


class Jianshu1Item(Item):
    # define the fields for your item here like:
    user = Field()
    title = Field()
    comment = Field()
    like = Field()
    content = Field()
