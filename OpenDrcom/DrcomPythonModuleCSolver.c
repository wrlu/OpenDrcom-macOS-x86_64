//
//  DrcomPythonModuleCSolver.c
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

#include "DrcomPythonModuleCSolver.h"


/**
 Python模块调用函数
 
 @param pyModulePath Python脚本文件所在的路径
 @param param 传入Python模块的字符串参数
 */
void startLogin(const char *pyModulePath,const char *param) {
//    初始化python
    Py_Initialize();
    PyObject *pModule = NULL, *pFunc = NULL, *pArg = NULL;
//    导入模块
    PyRun_SimpleString("import socket, struct, time");
    PyRun_SimpleString("from hashlib import md5");
    PyRun_SimpleString("import sys");
    PyRun_SimpleString("import os");
    PyRun_SimpleString("import random");
    PyRun_SimpleString(pyModulePath);
//    引入Python模块
    pModule = PyImport_ImportModule("Drcom_CAUC");
//    直接获取模块中的函数
    pFunc = PyObject_GetAttrString(pModule, "start");
//    参数类型转换，传递一个字符串
    pArg = Py_BuildValue("(s)", param);
//    调用直接获得的函数，并传递参数
    PyEval_CallObject(pFunc, pArg);
//    释放python
    Py_Finalize();
}
