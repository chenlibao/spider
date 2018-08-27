# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://doc.scrapy.org/en/latest/topics/item-pipeline.html
from pymongo import MongoClient


class Jianshu1Pipeline(object):
    def __init__(self):
        client = MongoClient('localhost', 27017)
        jianshu1_db = client['jianshu1_db']
        jianshu1 = jianshu1_db['jianshu1']
        self.post = jianshu1

    def process_item(self, item, spider):
        info = dict(item)
        self.post.insert(info)
        return item
