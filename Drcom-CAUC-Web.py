#!/usr/bin/python

import urllib
import urllib2
import getpass

url="http://192.168.100.200/a70.htm"

username = raw_input("Drcom Account: ")

password = getpass.getpass("Password:")

parameter={"DDDDD":username,"upass":password,"R1":0,"R3":0,"R6":0,"MKKey":123456}

data=urllib.urlencode(parameter)

request=urllib2.Request(url,data)

response=urllib2.urlopen(request)

page=response.read()

if(page.find("v46ip=")==-1):
	print "Login failed!"
else:
	print "Login success!"
	
	
	
