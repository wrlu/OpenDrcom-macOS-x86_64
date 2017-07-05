//
//  DrcomPythonModuleCSolver.h
//  OpenDrcom
//
//  Created by 路伟饶 on 2017/6/30.
//  Copyright © 2017年 路伟饶. All rights reserved.
//

#ifndef DrcomPythonModuleCSolver_h
#define DrcomPythonModuleCSolver_h

#include <stdio.h>
#include <Python/Python.h>

/**
 Python模块调用函数

 @param pyModulePath Python脚本文件所在的路径
 @param param 传入Python模块的字符串参数
 */
void startLogin(const char *pyModulePath,const char *param);

#endif /* DrcomPythonModuleCSolver_h */
