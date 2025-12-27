# --- THE CINEMATIC HERO UPGRADE (FIXED) ---

# 1. Folder Shield (Ensures Z:\backups and Z:\videos exist first)
$essentialFolders = @("Z:\backups", "Z:\videos", "Z:\images", "Z:\music")
foreach ($f in $essentialFolders) { 
    if (!(Test-Path $f)) { 
        New-Item -ItemType Directory -Path $f -Force | Out-Null
        Write-Host "[Fixed] Created missing directory: $f" -ForegroundColor Yellow
    } 
}

# 2. Local Backup
$zipName = "Z:\backups\Backup_$(Get-Date -Format 'yyyy-MM-dd_HH-mm').zip"
# Only attempt backup if there is something to back up
$filesToZip = Get-ChildItem Z:\ | Where-Object { $_.Name -ne "backups" -and $_.Name -ne "all_photos.zip" }
if ($filesToZip) {
    $filesToZip | Compress-Archive -DestinationPath $zipName -Update
}

# 3. Cinematic Styles with Hero Support
$style = @"
<style>
    :root { --main-bg: #0a0a0a; --card-bg: #141414; --accent: #00adb5; --text: #ffffff; }
    body { font-family: 'Helvetica Neue', Helvetica, sans-serif; background: var(--main-bg); color: var(--text); margin: 0; padding-top: 0; overflow-x: hidden; }
    nav { background: linear-gradient(to bottom, rgba(0,0,0,0.8), transparent); padding: 20px 4%; display: flex; align-items: center; justify-content: space-between; position: fixed; width: 100%; top: 0; z-index: 1000; box-sizing: border-box; }
    .logo { color: var(--accent); font-size: 1.8rem; font-weight: bold; text-transform: uppercase; letter-spacing: 2px; text-decoration: none; }
    .search-bar { background: rgba(0,0,0,0.5); border: 1px solid #444; color: #fff; padding: 8px 15px; border-radius: 20px; outline: none; width: 300px; backdrop-filter: blur(5px); }
    .hero { height: 75vh; position: relative; display: flex; align-items: center; padding-left: 4%; background: #000; overflow: hidden; }
    .hero-video { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; opacity: 0.5; }
    .hero-overlay { position: absolute; bottom: 0; left: 0; width: 100%; height: 50%; background: linear-gradient(to top, var(--main-bg), transparent); }
    .hero-content { position: relative; z-index: 10; max-width: 600px; }
    .hero-content h1 { font-size: 4rem; margin: 0; text-transform: uppercase; letter-spacing: -2px; }
    .hero-tag { color: var(--accent); font-weight: bold; text-transform: uppercase; letter-spacing: 2px; }
    .row { margin: 20px 0 40px 0; padding-left: 4%; }
    .row h2 { font-size: 1.4rem; color: #999; margin-bottom: 15px; border-left: 4px solid var(--accent); padding-left: 10px; }
    .row-container { display: flex; overflow-x: auto; gap: 15px; padding-bottom: 15px; scrollbar-width: none; }
    .row-container::-webkit-scrollbar { display: none; }
    .m-card { min-width: 300px; background: var(--card-bg); border-radius: 8px; overflow: hidden; transition: 0.4s; border: 1px solid #222; }
    .m-card:hover { transform: scale(1.08); border-color: var(--accent); z-index: 100; box-shadow: 0 10px 30px rgba(0,0,0,0.8); }
    video { width: 100%; aspect-ratio: 16/9; display: block; background: #000; }
    .card-info { padding: 15px; }
    .tag { font-size: 0.7rem; color: var(--accent); text-transform: uppercase; font-weight: bold; margin-bottom: 5px; }
    .title { font-size: 1rem; font-weight: bold; }
    .hidden { display: none !important; }
</style>
<script>
    function filterMedia() {
        const input = document.getElementById('search-input').value.toLowerCase();
        document.querySelectorAll('.m-card').forEach(card => {
            const text = card.innerText.toLowerCase();
            card.classList.toggle('hidden', !text.includes(input));
        });
        document.querySelectorAll('.row').forEach(row => {
            const hasVisible = row.querySelectorAll('.m-card:not(.hidden)').length > 0;
            row.classList.toggle('hidden', !hasVisible);
        });
    }
</script>
"@

$nav = @"
<nav>
    <a href='index.html' class='logo'>MUMBAI+</a>
    <input type='text' id='search-input' class='search-bar' placeholder='Search everything...' onkeyup='filterMedia()'>
    <div style='display:flex; gap:20px;'><a href='gallery.html' style='color:#fff;text-decoration:none;font-weight:bold;'>Gallery</a><a href='music.html' style='color:#fff;text-decoration:none;font-weight:bold;'>Music</a></div>
</nav>
"@

# 4. Find Latest Video for Hero
$latestVideo = Get-ChildItem "Z:\videos" -Filter *.mp4 -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$heroHtml = ""
if ($latestVideo) {
    $relativeHeroPath = $latestVideo.FullName.Replace("Z:\", "").Replace("\", "/")
    $heroHtml = @"
    <div class='hero'>
        <video class='hero-video' autoplay muted loop src='$relativeHeroPath'></video>
        <div class='hero-overlay'></div>
        <div class='hero-content'>
            <div class='hero-tag'>Now Playing</div>
            <h1>$($latestVideo.BaseName)</h1>
            <p>Your latest upload is now streaming on Mumbai+.</p>
        </div>
    </div>
"@
}

# 5. Build Rows
$allHtml = ""
$videoSubFolders = Get-ChildItem "Z:\videos" | Where-Object { $_.PSIsContainer }
foreach ($folder in $videoSubFolders) {
    $rowItems = ""
    $videos = Get-ChildItem $folder.FullName -Filter *.mp4 -Recurse
    foreach ($v in $videos) {
        $relPath = $v.FullName.Replace("Z:\", "").Replace("\", "/")
        $rowItems += @"
        <div class='m-card'>
            <video controls src='$relPath'></video>
            <div class='card-info'>
                <div class='tag'>$($folder.Name)</div>
                <div class='title'>$($v.BaseName)</div>
            </div>
        </div>
"@
    }
    if ($rowItems) { $allHtml += "<div class='row'><h2>$($folder.Name)</h2><div class='row-container'>$rowItems</div></div>" }
}

# 6. Final Assemble
$indexHtml = "<html><head><title>Mumbai+</title>$style</head><body>$nav $heroHtml $allHtml</body></html>"
$indexHtml | Set-Content index.html

# 7. Deployment
Write-Host "--- DEPLOYING CINEMATIC HUB ---" -ForegroundColor Cyan
aws s3 sync Z:\ s3://mumbai786buckets3 --exclude "backups/*" --exclude "update_site.ps1" --acl public-read
Write-Host "`n🚀 MUMBAI+ IS LIVE AND CINEMATIC!" -ForegroundColor Magenta
Read-Host -Prompt "Press Enter to finish"
