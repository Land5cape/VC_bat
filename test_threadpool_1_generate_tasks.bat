echo off %�������е����������ʾ%
:: ת���������ļ�����·��  
cd /d %~dp0
set taskfile=task.txt
set /a counter=1
del /Q %taskfile%
set test_dir=E:/workplace/test_sequence
::-----------------------------------------------------------------
:: ȡ������������Ҫ���Ե����ü���
:: ���������Ҳ����֮����
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
:: %i ��ʾ��i������
set "dat_dir=dat_%1"
echo %dat_dir%
set "log_dir=log_%1"
mkdir %dat_dir% %log_dir%
set encoder_cfg=encoder_%1.cfg
set QP=%2
set add_params=%3
:: ��add_params�е�����˫����ɾ��
set "add_params=%add_params:"=%"
:::::::: start ..
echo ================= ���� %1 QP %QP% ���ɿ�ʼ @ %date% %time% ===================
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

echo ================= ���� %1 QP %QP% ������� @ %date% %time% ===================
title QP%QP%���
:::::::: end
exit /b

:: oneQP����˵����  1:������  2:���  3:�߶�  4:֡��  5:֡��  6:IntraPeriod
:oneQP
title ��������%1_%2x%3_QP%Qp%�У�����رձ�����
echo :::::::: %1   %2x%3   qp=%Qp%   @ %date% %time%
:: set frames=100
set frames=%5
:: 2> stderr�ض���
echo %counter% >> %taskfile%

set test_file="%test_dir%/%1_%2x%3_%4.yuv"
echo -c %encoder_cfg% -i %test_file% -b %dat_dir%\str_%1_%2_QP%QP%.bin -o %dat_dir%\rec_%1_%2_QP%QP%.yuv -wdt %2 -hgt %3 -f %frames% -fr %4 -q %QP% --IntraPeriod=%6 %add_params% >> %taskfile%
:: ��������ع�YUV�ļ�������Ϊ���ַ���������-o������Ϊ����ֵ
:: -o %dat_dir%\rec_%1_%2_QP%QP%.yuv
echo %log_dir%\%1_%2_QP%QP%_log.txt >> %taskfile%
set /a counter+=1
exit /b
