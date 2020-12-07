# powershell thread pool
Set-Location "E:/workplace/VC_bat" # ִ��ps�ű���Ҫ�л�����ǰ·��
$tm_start = Get-Date
Write-Host '����ʼ�ڣ�' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
$throttleLimit = 4
$SessionState = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
$Pool = [runspacefactory]::CreateRunspacePool(1, $throttleLimit, $SessionState, $Host) #����Runspace����(1��4)
$Pool.Open()

# {}����ű���
$ScriptBlock = {
    param($id)
    Write-Host "Start Task ID $id." -foregroundcolor Cyan -backgroundcolor DarkBlue
    $num_rows=3*$id
    $file_cont = (Get-Content "task.txt" -TotalCount $num_rows)
    $exe_id     = $file_cont[-3]
    $exe_params = $file_cont[-2]
    $exe_output = $file_cont[-1]
    cmd /c del /Q $exe_output # cmd /c ִ��cmd���� ɾ���ɵ�log�ļ�
    Write-Host "Task [$exe_id]: $exe_params" -ForegroundColor Green 
    Write-Host "Task [$exe_id]: /output:$exe_output" -ForegroundColor Red
    $exe_params = $exe_params.Split(" ")
    # echo $exe_params >> $exe_output
    # Start-Process -FilePath bin/TAppEncoder.exe -ArgumentList "$exe_params" >> $exe_output
    ./EncoderApp.exe $exe_params >> $exe_output # ִ�б��룬д��log�ļ�
    Write-Host "Done processing ID $id"
}

$num_finished_task = 0
$num_task = (Get-Content "task.txt").Length / 3 # task.txt ÿ������ռ����
Write-Host number of tasks: $num_task -foregroundcolor Cyan -backgroundcolor DarkBlue
$threads = @()
$handles = @()
# -le <=
for ($x = 1; $x -le $num_task; $x++) {
    $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($x)
    $powershell.RunspacePool = $Pool
    $handles += $powershell.BeginInvoke() # �ύ�첽����
  $threads += $powershell
}

Write-Host "wait threads"
$Host.UI.RawUI.WindowTitle = '���' + $num_finished_task + '/' + $num_task

do { 
  $i = 0
  $done = $true
  foreach ($handle in $handles) {
    if ($null -ne $handle) {
      if ($handle.IsCompleted) {
        $threads[$i].EndInvoke($handle) # ����첽ִ�н��
        $threads[$i].Dispose() # ����
        $handles[$i] = $null
        $num_finished_task += 1
        $Host.UI.RawUI.WindowTitle = '���' + $num_finished_task + '/' + $num_task
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
Write-Host -ForegroundColor Yellow '  ����ʼ�ڣ�'   $tm_start
Write-Host -ForegroundColor Yellow '  ��������ڣ�'   $tm_finish
Write-Host -ForegroundColor Yellow '  ��  ��  ʱ��'  ($tm_finish - $tm_start)
Write-Host -ForegroundColor Yellow '--------------------------------------------'
$Host.UI.RawUI.WindowTitle = 'ȫ�����'

