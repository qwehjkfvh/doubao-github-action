# 一键推送脚本：先开代理/VPN，再右键“使用 PowerShell 运行”
$ErrorActionPreference = "Stop"
$git = "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe"
Set-Location $PSScriptRoot

Write-Host "== 1. 探测本地代理 ==" -ForegroundColor Cyan
$proxy = $null
foreach ($port in 7890, 7897, 10809, 10808, 1080, 8888) {
    $r = Test-NetConnection 127.0.0.1 -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($r) { $proxy = "http://127.0.0.1:$port"; Write-Host "发现代理: $proxy"; break }
}
if ($proxy) {
    & $git config --global http.proxy $proxy
    & $git config --global https.proxy $proxy
} else {
    Write-Host "未发现本地代理。如果直连 GitHub 失败，请先开启代理/VPN 后重跑本脚本。" -ForegroundColor Yellow
}

Write-Host "== 2. 检查与 GitHub 的连通性 ==" -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri "https://github.com" -TimeoutSec 12 -UseBasicParsing -MaximumRedirection 0 -ErrorAction Stop | Out-Null
    Write-Host "GitHub 可达。" -ForegroundColor Green
} catch {
    Write-Host "github.com 仍无法访问（$($_.Exception.Message)）。请开启代理后重试。" -ForegroundColor Red
    Read-Host "按回车退出"; exit 1
}

Write-Host "== 3. 配置远程仓库 ==" -ForegroundColor Cyan
$repoUrl = Read-Host "粘贴你在 GitHub 上新建的空仓库地址（形如 https://github.com/用户名/仓库名.git）"
if (-not $repoUrl) { Write-Host "未输入地址，退出。" -ForegroundColor Red; exit 1 }

& $git remote remove origin 2>$null
& $git remote add origin $repoUrl
& $git branch -M main

Write-Host "== 4. 推送（首次会弹出浏览器让你登录 GitHub，点授权即可）==" -ForegroundColor Cyan
& $git push -u origin main

Write-Host "完成！仓库地址: $repoUrl" -ForegroundColor Green
Write-Host "别忘了在仓库 Settings -> Secrets and variables -> Actions 添加 ARK_API_KEY 和 ARK_MODEL_ID" -ForegroundColor Yellow
Read-Host "按回车退出"
