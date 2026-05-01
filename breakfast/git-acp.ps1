Param(
    [Parameter(Mandatory=$false)]
    [string]$Message
)

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "找不到 git，請先安裝並確認 git 已加入系統路徑。"
    exit 1
}

Set-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

if (-not $Message) {
    $Message = Read-Host -Prompt '請輸入 commit 訊息'
}

if (-not $Message) {
    Write-Error '未提供 commit 訊息，已取消。'
    exit 1
}

Write-Host "進行 git add -A..." -ForegroundColor Cyan
git add -A
if (-not $?) {
    Write-Error 'git add 失敗，請檢查檔案狀態。'
    exit 1
}

Write-Host "進行 git commit..." -ForegroundColor Cyan
if (-not (git commit -m "$Message")) {
    Write-Error 'git commit 失敗，請檢查是否有變更或衝突。'
    exit 1
}

Write-Host "檢查是否需設定 upstream..." -ForegroundColor Cyan
$upstream = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
if (-not $upstream) {
    Write-Host "尚未設定上游分支，將建立 upstream origin/HEAD..." -ForegroundColor Cyan
    if (-not (git push -u origin HEAD)) {
        Write-Error 'git push 失敗，請檢查遠端設定與網路。'
        exit 1
    }
} else {
    Write-Host "進行 git push..." -ForegroundColor Cyan
    if (-not (git push)) {
        Write-Error 'git push 失敗，請檢查遠端設定與網路。'
        exit 1
    }
}

Write-Host 'git acp 已完成。' -ForegroundColor Green
