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

# --- [start]注意事项[start] --- #
    # 目前仅支持windows平台 #
# --- [end]注意事项[end] --- #

# --- [start]使用方法[start] --- #
    # 复制本脚本代码到你的项目文件中 #
    # 或在项目文件中使用include包含本文件 #
# --- [end]使用方法[end] --- #

# --- [start]输入参数[start] --- #
    # 是否开启打印信息输出(不会影响主项目的打印输出) #
    # 需要屏蔽打印就将它注释即可 #
    # 默认不开启 #
#DEBUG_LOGGER = hello world

    # 是否在编译完成后自动打开目标目录
    # 需要屏蔽该功能就将它注释即可 #
    # 默认开启 #
DEPLOY_COMPLETE_AUTO_OPEN_EXPLORER = hello world

    # 是否开启实验性功能 #
    # 需要屏蔽实验性共功能只需注释即可 #
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
        content_lines = $$cat($$resource)
        for (iter, content_lines) {
            tmp = $$find(iter, <file>.*</file>)
            !isEmpty(tmp) {
                qml_file_list += $$replace(iter, (<file>(.*)<\/file>), \2)
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
        content_lines = $$cat($$file)
        for (iter, content_lines) {
            contains(default_qml_module_list, $$iter) {
                module_name = $$section(iter, ., 1, 1)
                qml_module_list += $$module_name
            }
        }
    }

    !isEmpty(DEBUG_LOGGER): message(qml_module_list: $$qml_module_list)
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
    !isEmpty(DEBUG_LOGGER): !isEmpty(qml_module_list): message($$qml_module_list)

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

        source = $$replace(source, /, \\)
        dest   = $$replace(dest, /, \\)

        mkdir_qml_quick_module_dest_cmd_line = cmd /c mkdir $$dest # 创建模块目录在QtQuick
        copy_qml_quick_module_file_cmd_line = cmd /c xcopy /s/y $$source $$dest # 复制Qml模块到指定目录

        # 复制qml模块(dll)(命令行)
        CONFIG(debug, debug|release) {
            qml_module_params = $${qt_bin_dir}Qt5Quick$${qml_module}d.dll $${target_out_dir}
        }
        else {
            qml_module_params = $${qt_bin_dir}Qt5Quick$${qml_module}.dll $${target_out_dir}
        }

        qml_module_params = $$replace(qml_module_params, /, \\)
        copy_qml_module_cmd_line = cmd /c copy $$qml_module_params

        cmd_line += && $$mkdir_qml_quick_module_dest_cmd_line
        cmd_line += & $$copy_qml_quick_module_file_cmd_line
        cmd_line += && $$copy_qml_module_cmd_line
    }

    return ($$cmd_line)
}
# --- [end]函数[end] --- #

# 获取从QMake执行文件的所在目录得出Qt的bin路径
QT_BIN_DIR = $$replace(QMAKE_QMAKE, ^(\S*/)\S+$, \1)
# 获取Qt开发环境路径
QT_DIR = $${QT_BIN_DIR}../

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

# 扫描`QT`变量用于打包模块的参数配置
for (LIBRARY_MODULE, QT_AVAILABLE_LIBRARY_LIST) {
    if (contains(QT, $$LIBRARY_MODULE)) {
        DEPLOY_OPTIONS += --$$LIBRARY_MODULE
    }
    else {
        DEPLOY_OPTIONS += --no-$$LIBRARY_MODULE
    }
}

# 针对Qml模块配置打包参数
if (contains(QT, quick)) {
    DEPLOY_OPTIONS -= --no-qml
    DEPLOY_OPTIONS += --qml

    DEPLOY_OPTIONS -= --no-network
    DEPLOY_OPTIONS += --network

    DEPLOY_OPTIONS += --qmldir $${QT_DIR}qml/
}

if (!isEmpty(DESTDIR)) {
    # 如有设置目标输出路径则定向于该路径
    TARGET_OUT_DIR = $$OUT_PWD/$$DESTDIR/
}
else {
    # 判断时debug版本还是release版本
    CONFIG(debug, debug|release) {
        TARGET_OUT_DIR = $${OUT_PWD}/debug/
        DEPLOY_OPTIONS += --debug
    }
    else {
        TARGET_OUT_DIR = $${OUT_PWD}/release/
        DEPLOY_OPTIONS += --release
    }
}

# 实验性功能
!isEmpty(EXPERIMENTAL) {
    # 该功能(用于优化qmake调试输出)是否开放还需待定，因为会导致其他未知的问题。
    CONFIG = $$remove_extra_config_parameter($$CONFIG)
}

# 调试输出
!isEmpty(DEBUG_LOGGER) {
    message(TARGET_OUT_DIR: $$TARGET_OUT_DIR) # 生成文件的输出目录
    message(QMAKE_POST_LINK: $$QMAKE_POST_LINK) # 打印命令
}

win32 {
    # 拼接Qt部署程序的文件(windows平台下为windeployqt.exe)
    WIN_DEPLOY_BIN = $${QT_BIN_DIR}windeployqt.exe

    # 编译完成后执行打包命令
    QMAKE_POST_LINK += $$WIN_DEPLOY_BIN $$DEPLOY_OPTIONS $$TARGET_OUT_DIR$${TARGET}.exe

    # 扫描Qml依赖库，并在编译完成后自动复制qml依赖库到目标目录
    QMAKE_POST_LINK += $$get_copy_qml_library_cmd_line($$QT_DIR, $$QT_BIN_DIR, $$TARGET_OUT_DIR, $$RESOURCES)

    !isEmpty(DEPLOY_COMPLETE_AUTO_OPEN_EXPLORER) {
        # 打包完成后自动打开目标路径
        QMAKE_POST_LINK += && start $$TARGET_OUT_DIR
    }
}
