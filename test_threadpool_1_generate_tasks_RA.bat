echo off
:: ת���������ļ�����·��
cd /d %~dp0
set taskfile=task-ra.txt
set /a counter=1
del /Q %taskfile%
::-----------------------------------------------------------------
:: ȡ������������Ҫ���Ե����ü���
:: LDP 22,27,32,37
:: for %%i in () do call :test_common LDB %%i "--IntraPeriod=-1"
::: RA 
 for %%i in (22) do call :test_common RA %%i ""
:::: AI
:: for %%i in ( ) do call :test_common AI %%i "--IntraPeriod=1"
::-----------------------------------------------------------------
pause
exit /b

:test_common
:: "encoder_cfg, add_params" is setted before being called
set dat_dir=dat_%1
set log_dir=log_%1
mkdir %dat_dir% %log_dir%
set encoder_cfg=encoder_%1.cfg
set QP=%2
set add_params=%3
set "add_params=%add_params:"=%"
:::::::: start ..
echo ================= ���� %1 QP %QP% ���ɿ�ʼ @ %date% %time% ===================
echo Class D
call :oneQP BasketballPass      416  240 50 100 48
call :oneQP BQSquare            416  240 60 100 64 
call :oneQP BlowingBubbles      416  240 50 100 48 
call :oneQP RaceHorses          416  240 30 100 32 

echo Class C
call :oneQP BasketballDrill      832  480 50 100 48 
call :oneQP BQMall               832  480 60 100 64
call :oneQP PartyScene           832  480 50 100 48 
call :oneQP RaceHorsesC          832  480 30 100 32 

echo Class B 
call :oneQP Kimono              1920 1080 24 100 48
call :oneQP BQTerrace           1920 1080 60 100 64
call :oneQP BasketballDrive     1920 1080 50 100 48
call :oneQP ParkScene           1920 1080 24 100 48
call :oneQP Cactus              1920 1080 50 100 48
      
echo Class E
call :oneQP Johnny              1280  720 60 100 64 
call :oneQP FourPeople          1280  720 60 100 64 
call :oneQP KristenAndSara      1280  720 60 100 64
 
echo Class A
:: call :oneQP PeopleOnStreet      2560  1600 30 60 32
:: call :oneQP Traffic             2560  1600 30 60 32

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
echo -c %encoder_cfg% -i "G:/test_sequence/%1_%2x%3_%4.yuv" -b %dat_dir%\str_%1_%2_QP%QP%.bin -o %dat_dir%\rec_%1_%2_QP%QP%.yuv -wdt %2 -hgt %3 -f %frames% -fr %4 -q %QP% --IntraPeriod=%6 %add_params% >> %taskfile%
:: ��������ع�YUV�ļ�������Ϊ���ַ���������-o������Ϊ����ֵ
:: -o %dat_dir%\rec_%1_%2_QP%QP%.yuv
echo %log_dir%\%1_%2_QP%QP%_log.txt >> %taskfile%
set /a counter+=1
exit /b
