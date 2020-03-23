# Author: Qt君
# QQ交流群: 732271126
# AUTHOR_INFO: 扫码关注微信公众号: [Qt君] 第一时间获取最新推送.
#██████████████    ██      ██████████████    ██████████████
#██          ██  ████  ████    ██  ██        ██          ██
#██  ██████  ██    ██████              ██    ██  ██████  ██
#██  ██████  ██  ████  ██    ████████    ██  ██  ██████  ██
#██  ██████  ██      ██  ██      ██    ████  ██  ██████  ██
#██          ██  ██  ██      ████    ██  ██  ██          ██
#██████████████  ██  ██  ██  ██  ██  ██  ██  ██████████████
#                        ██  ██████  ██████
#██████████  ██████████  ██  ████████████  ██  ██  ██  ██
#      ██        ████        ██  ██    ██  ████████      ██
#  ██  ██  ████  ████  ████████████  ██  ██  ██████
#    ██████        ██████        ██  ██  ██████        ██
#      ██████████  ██  ██  ██  ██  ██  ██  ██      ████
#                ██  ██  ██████  ████  ████████████  ██  ██
#████  ██████████    ██        ████  ██  ██  ██  ██  ██
#████    ████      ████  ██  ██████  ██████████        ██
#  ██  ████  ██    ████  ██████    ██  ██      ██    ██
#████████      ██  ██      ████  ██    ████  ██████████  ██
#██    ████  ████  ██  ████    ████      ████  ████████
#██  ████  ██  ██      ██      ████    ██              ██
#██  ██████  ████    ████  ██████████    ██████████  ██████
#                ████    ████  ████  ██  ██      ██████████
#██████████████  ████        ██████    ████  ██  ██████
#██          ██    ████  ██  ██████  ██████      ████    ██
#██  ██████  ██  ████    ████  ██  ██    ██████████████████
#██  ██████  ██  ████        ██████████  ██        ██  ████
#██  ██████  ██  ██  ██████    ██  ████████  ████████████
#██          ██  ██    ██    ████    ██  ████  ██████  ██
#██████████████  ██████████      ██            ████  ██

# ---v1.0.1--- #

# --- [start]注意事项[start] --- #
    # 目前仅支持windows平台 #
# --- [end]注意事项[end] --- #

# --- [start]使用方法[start] --- #
    # 复制本脚本代码到你的项目文件中 #
    # 或在项目文件中使用include包含本文件 #
# --- [end]使用方法[end] --- #

# --- [start]输入参数[start] --- #
    # 指定打包后的输出目录
    # 默认为程序pro文件路径的package_output目录(没有则新键)
isEmpty(DEPLOY_OUT_PUT_DIR): DEPLOY_OUT_PUT_DIR = $$_PRO_FILE_PWD_/package_output

    # 是否开启打印信息输出(不会影响主项目的打印输出) #
    # 需要屏蔽打印就将它注释即可 #
    # 默认不开启 #
#DEBUG_LOGGER = hello world

    # 是否在编译完成后自动打开目标目录
    # 需要屏蔽该功能就将它注释即可 #
    # 默认开启 #
DEPLOY_COMPLETE_AUTO_OPEN_EXPLORER = hello world

    # 是否开启实验性功能 #
    # 需要屏蔽实验性功能只需注释即可 #
    # 默认不开启 #
#EXPERIMENTAL = hello world # 优化qmake执行速度
# --- [end]输入参数[end] --- #

# --- [start]函数[start] --- #
# 移除多余的debug或release配置项(实验功能)
defineReplace(remove_extra_config_parameter) {
    configs = $$1
    debug_and_release_params =
    keys = debug Debug release Release #debug_and_release
    for (iter, configs) {
        contains(keys, $$lower($$iter)) {
            debug_and_release_params += $$lower($$iter)
        }
    }

    for (iter, debug_and_release_params) {
        configs -= $$iter
    }

    configs += $$last(debug_and_release_params)

    return($$configs)
}

# 获取资源文件中的qml文件
defineReplace(find_qml_file) {
    resources = $$1
    qml_file_list =

    for (resource, resources) {
        # 需要相对路径使用
        # _PRO_FILE_PWD_
        resource_file = $$_PRO_FILE_PWD_/$$resource
        !exists($$resource_file) : error($$resource not found.)
        content_lines = $$cat($$resource_file)
        for (iter, content_lines) {
            tmp = $$find(iter, <file>.*</file>)
            !isEmpty(tmp) {
                qml_file_list += $$replace(iter, (<file>(.*)</file>), \2)
            }
        }
    }

    return ($$qml_file_list)
}

# 获取qml文件中使用到的模块
defineReplace(get_qml_module_list) {
    qml_file_list = $$1
    default_qml_module_list = QtQuick.Shapes QtQuick.Particles
    qml_module_list =
    for (file, qml_file_list) {
        qml_file = $$_PRO_FILE_PWD_/$$file
        !exists($$qml_file) : error($$file not found.)
        content_lines = $$cat($$qml_file)
        for (iter, content_lines) {
            contains(default_qml_module_list, $$iter) {
                module_name = $$section(iter, ., 1, 1)
                qml_module_list += $$module_name
            }
        }
    }

    return ($$qml_module_list)
}

# 获取需要复制qml库的命令行
defineReplace(get_copy_qml_library_cmd_line) {
    qt_dir = $$1
    qt_bin_dir = $$2
    target_out_dir = $$3
    resources = $$4
    cmd_line =

    qml_file_list = $$find_qml_file($$resources)
    !isEmpty(DEBUG_LOGGER): !isEmpty(qml_file_list): message(result: $$qml_file_list)

    qml_module_list = $$get_qml_module_list($$qml_file_list)
    !isEmpty(DEBUG_LOGGER): message(qml_module_list: $$qml_module_list)

    for (qml_module, qml_module_list) {
        if (equals(qml_module, Particles)) {
            # 源qml的quick的某个模块库目录
            source = $${qt_dir}qml/QtQuick/$${qml_module}.2
            # 目标qml的quick的某个模块源库目录
            dest   = $${target_out_dir}QtQuick/$${qml_module}.2
        }
        else {
            # 源qml的quick的某个模块库目录
            source = $${qt_dir}qml/QtQuick/$${qml_module}
            # 目标qml的quick的某个模块源库目录
            dest   = $${target_out_dir}QtQuick/$${qml_module}
        }



        # 复制qml模块(dll)(命令行)
        CONFIG(debug, debug|release) {
            qml_module_params = $${qt_bin_dir}Qt5Quick$${qml_module}d.dll $${target_out_dir}
        }
        else {
            qml_module_params = $${qt_bin_dir}Qt5Quick$${qml_module}.dll $${target_out_dir}
        }

        # 判断平台是/还是\为路径符
        equals(QMAKE_DIR_SEP, \\) {
            source = $$replace(source, /, \\)
            dest   = $$replace(dest, /, \\)
            qml_module_params = $$replace(qml_module_params, /, \\)
        }


        copy_qml_quick_module_file_cmd_line = $$QMAKE_COPY_DIR $$source $$dest # 复制Qml模块到指定目录
        copy_qml_module_cmd_line = $$QMAKE_COPY_FILE $$qml_module_params

        cmd_line += && $$command_warpper($$copy_qml_quick_module_file_cmd_line, $$_LINE_)
        cmd_line += && $$command_warpper($$copy_qml_module_cmd_line, $$_LINE_)
    }

    return ($$cmd_line)
}

# 命令包装，主要附加命令本身打印
defineReplace(command_warpper) {
    cmd_line = $$1
    line = $$2
    return (echo Execute Command: line: $$line cmd_line: $$cmd_line && $$cmd_line)
}

# 根据平台处理路径分隔符
defineReplace(processing_slash) {
    tmp = $$1
    # 判断平台是/还是\为路径符
    equals(QMAKE_DIR_SEP, \\): return ($$replace(tmp, /, \\))

    return ($$tmp)
}

defineReplace(is_debug) {
    CONFIG(debug, debug|release): return (true)
    return (false)
}

# 目前仅支持window系统
defineReplace(get_copy_system_library_to_target_dir_cmd_line) {
    target = $$1
    !win32-msvc*: return (echo ignore)

    contains(QMAKE_HOST.arch, x86_64) {
        # 64bit
        system_dir = C:\Windows\SysWOW64
    }
    else {
        # 32bit
        system_dir = C:\Windows\System32
    }

    # fixed
    $$is_debug() {
        cmd_line = $$QMAKE_COPY_FILE $$system_dir\msvcp1?0d.dll $$target
        cmd_line = $$QMAKE_COPY_FILE $$system_dir\vcruntime*d.dll $$target
        cmd_line = $$QMAKE_COPY_FILE $$system_dir\ucrtbased.dll $$target
    }
    else {
        cmd_line = $$QMAKE_COPY_FILE $$system_dir\msvcp1?0.dll $$target
        cmd_line = $$QMAKE_COPY_FILE $$system_dir\vcruntime1?0.dll $$target
        cmd_line = $$QMAKE_COPY_FILE $$system_dir\ucrtbase.dll $$target
    }
    cmd_line += && $$QMAKE_COPY_FILE $$system_dir\api-ms-win-*.dll $$target

    return ($$cmd_line)
}

defineReplace(get_third_part_library_cmd_line) {
    target = $$1
    lib_file_list =
    lib_dir_list =
    lib_prefix =
    lib_suffix =
    cmd_line =
    for (iter, LIBS) {
        prefix = $$str_member($$iter, 0, 1)
        content = $$str_member($$iter, 2, -1)
        equals(prefix, -L) {
            suffix = $$str_member($$content, -1, -1))
            !equals(suffix, /): content = $$content/
            message(-L: $$content)
            lib_dir_list += $$content
        }
        else: equals(prefix, -l) {
            message(-l: $$content)
            lib_file_list += $$content
        }
    }

    win32: lib_suffix = *.dll

    for (file, lib_file_list) {
        for (dir, lib_dir_list) {
            exists($$_PRO_FILE_PWD_/$$dir$$file$$lib_suffix) {
                cmd_line += && $$QMAKE_COPY_FILE $$processing_slash($$_PRO_FILE_PWD_/$$dir$$file$$lib_suffix $$target)
            }
        }
    }

    message($$cmd_line)
    return ($$cmd_line)
}
# --- [end]函数[end] --- #

# 获取从QMake执行文件的所在目录得出Qt的bin路径
QT_DIR = $$[QT_INSTALL_PREFIX]/
# 获取Qt开发环境路径
QT_BIN_DIR = $${QT_DIR}bin/

isEmpty(QT_DIR) {
    QT_BIN_DIR = $$replace(QMAKE_QMAKE, ^(\S*/)\S+$, \1)
    QT_DIR = $${QT_BIN_DIR}../
}

# Qt打包工具参数配置集合
DEPLOY_OPTIONS += --force

# 可用的Qt模块
QT_AVAILABLE_LIBRARY_LIST = \
    bluetooth concurrent core declarative designer designercomponents enginio \
    gamepad gui qthelp multimedia multimediawidgets multimediaquick network nfc \
    opengl positioning printsupport qml qmltooling quick quickparticles quickwidgets \
    script scripttools sensors serialport sql svg test webkit webkitwidgets \
    websockets widgets winextras xml xmlpatterns webenginecore webengine \
    webenginewidgets 3dcore 3drenderer 3dquick 3dquickrenderer 3dinput 3danimation \
    3dextras geoservices webchannel texttospeech serialbus webview

# 扫描QT变量用于打包模块的参数配置
for (LIBRARY_MODULE, QT_AVAILABLE_LIBRARY_LIST) {
    if (contains(QT, $$LIBRARY_MODULE)) {
        DEPLOY_OPTIONS *= --$$LIBRARY_MODULE
    }
    else {
        DEPLOY_OPTIONS *= --no-$$LIBRARY_MODULE
    }
}

# 针对Qml模块配置打包参数
if (contains(QT, quick)) {
    DEPLOY_OPTIONS -= --no-qml
    DEPLOY_OPTIONS *= --qml

    DEPLOY_OPTIONS -= --no-network
    DEPLOY_OPTIONS *= --network

    DEPLOY_OPTIONS *= --qmldir $${QT_DIR}qml/
}

if (!isEmpty(DESTDIR)) {
    # 如有设置目标输出路径则定向于该路径
    TARGET_OUT_DIR = $$OUT_PWD/$$DESTDIR/
}
else {
    # 判断是debug版本还是release版本
    CONFIG(debug, debug|release) {
        contains(CONFIG, debug_and_release) {
            TARGET_OUT_DIR = $${OUT_PWD}/debug/
        }
        else {
            TARGET_OUT_DIR = $${OUT_PWD}/
        }
        DEPLOY_OPTIONS *= --debug
    }
    else {
        contains(CONFIG, debug_and_release) {
            TARGET_OUT_DIR = $${OUT_PWD}/release/
        }
        else {
            TARGET_OUT_DIR = $${OUT_PWD}/
        }
        DEPLOY_OPTIONS *= --release
    }
}

# 预打包目标目录
isEmpty(DEPLOY_OUT_PUT_DIR) {
    DEPLOY_OUT_PUT_DIR = $$TARGET_OUT_DIR
}

# 实验性功能
!isEmpty(EXPERIMENTAL) {
    # 该功能(用于优化qmake调试输出)是否开放还需待定，因为会导致其他未知的问题。
    CONFIG = $$remove_extra_config_parameter($$CONFIG)
}

win32 {
    # 拼接Qt部署程序的文件(windows平台下为windeployqt.exe)
    WIN_DEPLOY_BIN = $${QT_BIN_DIR}windeployqt.exe
    # 编译输出的执行文件(含文件和目录路径)
    TARGET_OUT_FILE = $$TARGET_OUT_DIR$${TARGET}.exe

    WIN_DEPLOY_BIN = $$processing_slash($$WIN_DEPLOY_BIN)
    TARGET_OUT_FILE   = $$processing_slash($$TARGET_OUT_FILE)

    DEPLOY_OUT_PUT_DIR = $$absolute_path("&&&Qtjun&&&", $$DEPLOY_OUT_PUT_DIR) #需要fixed
    DEPLOY_OUT_PUT_DIR = $$replace(DEPLOY_OUT_PUT_DIR, &&&Qtjun&&&,)
    DEPLOY_OUT_PUT_DIR = $$processing_slash($$DEPLOY_OUT_PUT_DIR)

    TARGET_OUT_DIR = $$processing_slash($$TARGET_OUT_DIR)

    # 预编译所在目录的执行文件
    DEPLOY_OUT_PUT_FILE = $$DEPLOY_OUT_PUT_DIR$${TARGET}.exe
    DEPLOY_OUT_PUT_FILE = $$processing_slash($$DEPLOY_OUT_PUT_FILE)

    # 复制执行文件到预打包目录
    !equals(DEPLOY_OUT_PUT_DIR, $$TARGET_OUT_DIR) {
        !isEmpty(QMAKE_POST_LINK): QMAKE_POST_LINK += &&
        QMAKE_POST_LINK += $$command_warpper($$QMAKE_MKDIR \"$$DEPLOY_OUT_PUT_DIR\", $$_LINE_)
        QMAKE_POST_LINK += & $$command_warpper($$QMAKE_COPY_FILE \"$$TARGET_OUT_FILE\" \"$$DEPLOY_OUT_PUT_DIR\", $$_LINE_)
    }

    # 编译完成后执行打包命令
    !isEmpty(QMAKE_POST_LINK): QMAKE_POST_LINK += &&
    QMAKE_POST_LINK += $$command_warpper($$WIN_DEPLOY_BIN $$DEPLOY_OPTIONS \"$$DEPLOY_OUT_PUT_FILE\", $$_LINE_)

    # 扫描Qml依赖库，并在编译完成后自动复制qml依赖库到目标目录
    QMAKE_POST_LINK += $$get_copy_qml_library_cmd_line($$QT_DIR, $$QT_BIN_DIR, \"$$DEPLOY_OUT_PUT_DIR\", $$RESOURCES)

    # 复制系统库
    QMAKE_POST_LINK += && $$command_warpper($$get_copy_system_library_to_target_dir_cmd_line(\"$$DEPLOY_OUT_PUT_DIR\"), $$_LINE_)

    # 扫描复制第三方库
#    QMAKE_POST_LINK += $$command_warpper($$get_third_part_library_cmd_line($$DEPLOY_OUT_PUT_DIR), $$_LINE_)

    !isEmpty(DEPLOY_COMPLETE_AUTO_OPEN_EXPLORER) {
        # 打包完成后自动打开目标路径
        QMAKE_POST_LINK += && $$command_warpper(cmd /c explorer \"$$DEPLOY_OUT_PUT_DIR\", $$_LINE_) # FIXME
    }

    # 注意：该命令放在最后
    QMAKE_POST_LINK += & echo ------------------------------Package Success------------------------------
}

# 调试输出
!isEmpty(DEBUG_LOGGER) {
    message(TARGET_OUT_DIR: $$TARGET_OUT_DIR) # 生成文件的输出目录
    message(DEPLOY_OUT_PUT_DIR: $$DEPLOY_OUT_PUT_DIR) # 预打包文件的输出目录
    message(QMAKE_POST_LINK: $$QMAKE_POST_LINK) # 打印命令
}
