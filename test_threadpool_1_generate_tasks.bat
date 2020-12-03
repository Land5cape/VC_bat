echo off %后面所有的命令均不显示%
:: 转到批处理文件所在路径  
cd /d %~dp0
set taskfile=task.txt
set /a counter=1
del /Q %taskfile%
set test_dir=E:/workplace/test_sequence
::-----------------------------------------------------------------
:: 取消如下行中需要测试的配置即可
:: 任务的设置也需随之更改
:::: LDP 22,27,32,37
for %%i in (22) do call :test_common LDB %%i ""
:::: RA 22
:: for %%i in () do call :test_common RA %%i ""
:::: AI 22,27,32
::for %%i in (22) do call :test_common AI %%i "--IntraPeriod=1"
::-----------------------------------------------------------------
pause
exit /b

:test_common
:: "encoder_cfg, add_params" is setted before being called
:: %i 表示第i个参数
set "dat_dir=dat_%1"
echo %dat_dir%
set "log_dir=log_%1"
mkdir %dat_dir% %log_dir%
set encoder_cfg=encoder_%1.cfg
set QP=%2
set add_params=%3
:: 将add_params中的所有双引号删除
set "add_params=%add_params:"=%"
:::::::: start ..
echo ================= 任务 %1 QP %QP% 生成开始 @ %date% %time% ===================
echo Class D
call :oneQP BasketballPass      416  240 50 300 -1
call :oneQP BQSquare            416  240 60 300 -1 
call :oneQP BlowingBubbles      416  240 50 300 -1 
call :oneQP RaceHorses          416  240 30 300 -1 

echo Class C
call :oneQP BasketballDrill      832  480 50 300 -1 
call :oneQP BQMall               832  480 60 300 -1
call :oneQP PartyScene           832  480 50 300 -1 
call :oneQP RaceHorses           832  480 30 300 -1 

echo ================= 任务 %1 QP %QP% 生成完毕 @ %date% %time% ===================
title QP%QP%完成
:::::::: end
exit /b

:: oneQP参数说明：  1:序列名  2:宽度  3:高度  4:帧率  5:帧数  6:IntraPeriod
:oneQP
title 测试序列%1_%2x%3_QP%Qp%中，请勿关闭本窗口
echo :::::::: %1   %2x%3   qp=%Qp%   @ %date% %time%
:: set frames=100
set frames=%5
:: 2> stderr重定向
echo %counter% >> %taskfile%

set test_file="%test_dir%/%1_%2x%3_%4.yuv"
echo -c %encoder_cfg% -i %test_file% -b %dat_dir%\str_%1_%2_QP%QP%.bin -o %dat_dir%\rec_%1_%2_QP%QP%.yuv -wdt %2 -hgt %3 -f %frames% -fr %4 -q %QP% --IntraPeriod=%6 %add_params% >> %taskfile%
:: 无需输出重构YUV文件，设置为空字符串；否则将-o参数改为如下值
:: -o %dat_dir%\rec_%1_%2_QP%QP%.yuv
echo %log_dir%\%1_%2_QP%QP%_log.txt >> %taskfile%
set /a counter+=1
exit /b
