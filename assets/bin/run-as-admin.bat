set command=%1
set args=%2

:param
if "%3"=="" (
    goto end
)
set args=%args% %3
shift /0
goto param

:end
mshta vbscript:createobject("shell.application").shellexecute("%command%","%args%","","runas",0)(window.close)