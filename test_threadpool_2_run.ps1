# powershell thread pool
Set-Location "E:/workplace/VC_bat" # 执行ps脚本需要切换到当前路径
$tm_start = Get-Date
Write-Host '任务开始于：' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
$throttleLimit = 4
$SessionState = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
$Pool = [runspacefactory]::CreateRunspacePool(1, $throttleLimit, $SessionState, $Host) #设置Runspace数量(1，4)
$Pool.Open()

# {}定义脚本块
$ScriptBlock = {
    param($id)
    Write-Host "Start Task ID $id." -foregroundcolor Cyan -backgroundcolor DarkBlue
    $num_rows=3*$id
    $file_cont = (Get-Content "task.txt" -TotalCount $num_rows)
    $exe_id     = $file_cont[-3]
    $exe_params = $file_cont[-2]
    $exe_output = $file_cont[-1]
    cmd /c del /Q $exe_output # cmd /c 执行cmd命令 删除旧的log文件
    Write-Host "Task [$exe_id]: $exe_params" -ForegroundColor Green 
    Write-Host "Task [$exe_id]: /output:$exe_output" -ForegroundColor Red
    $exe_params = $exe_params.Split(" ")
    # echo $exe_params >> $exe_output
    # Start-Process -FilePath bin/TAppEncoder.exe -ArgumentList "$exe_params" >> $exe_output
    ./EncoderApp.exe $exe_params >> $exe_output # 执行编码，写入log文件
    Write-Host "Done processing ID $id"
}

$num_finished_task = 0
$num_task = (Get-Content "task.txt").Length / 3 # task.txt 每个任务占三行
Write-Host number of tasks: $num_task -foregroundcolor Cyan -backgroundcolor DarkBlue
$threads = @()
$handles = @()
# -le <=
for ($x = 1; $x -le $num_task; $x++) {
    $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($x)
    $powershell.RunspacePool = $Pool
    $handles += $powershell.BeginInvoke() # 提交异步操作
  $threads += $powershell
}

Write-Host "wait threads"
$Host.UI.RawUI.WindowTitle = '完成' + $num_finished_task + '/' + $num_task

do { 
  $i = 0
  $done = $true
  foreach ($handle in $handles) {
    if ($null -ne $handle) {
      if ($handle.IsCompleted) {
        $threads[$i].EndInvoke($handle) # 获得异步执行结果
        $threads[$i].Dispose() # 销毁
        $handles[$i] = $null
        $num_finished_task += 1
        $Host.UI.RawUI.WindowTitle = '完成' + $num_finished_task + '/' + $num_task
      } else {
        $done = $false
      }
    }
    $i++ 
  }
  if (-not $done) { Start-Sleep -Milliseconds 500 }
} until ($done)

$tm_finish = Get-Date
Write-Host -ForegroundColor Yellow '--------------------------------------------'
Write-Host -ForegroundColor Yellow '  任务开始于：'   $tm_start
Write-Host -ForegroundColor Yellow '  任务完成于：'   $tm_finish
Write-Host -ForegroundColor Yellow '  总  耗  时：'  ($tm_finish - $tm_start)
Write-Host -ForegroundColor Yellow '--------------------------------------------'
$Host.UI.RawUI.WindowTitle = '全部完成'

