#!/usr/bin/python

import urllib
import urllib2
import getpass

# 中国民航大学认证URL
url="http://192.168.100.200/a70.htm"

# 输入用户名
username = raw_input("Drcom Account: ")
# 输入密码
password = getpass.getpass("Password:")
# HTTP请求参数
parameter={"DDDDD":username,"upass":password,"R1":0,"R3":0,"R6":0,"MKKey":123456}
# 进行URL编码
data=urllib.urlencode(parameter)
# 创建HTTP POST请求
request=urllib2.Request(url,data)
# 获得HTTP响应
response=urllib2.urlopen(request)
# 从HTTP响应中读取页面内容
page=response.read()
# 页面特征：登录成功后可以找到IP字段
if(page.find("v46ip=")==-1):
	print "Login failed!"
else:
	print "Login success!"
	
	
	
