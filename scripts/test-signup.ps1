# Test POST /api/auth/signup - run with backend on http://localhost:8080
$base = 'http://localhost:8080'
$body = @{
  fullName = 'Test User'
  email    = 'testuser' + (Get-Random -Maximum 99999) + '@example.com'
  password = 'Password1!'
  confirmPassword = 'Password1!'
  role     = 'manager'
} | ConvertTo-Json

try {
  $r = Invoke-RestMethod -Uri "$base/api/auth/signup" -Method Post -Body $body -ContentType 'application/json' -ErrorAction Stop
  Write-Host "Success:" ($r | ConvertTo-Json -Depth 3)
} catch {
  $status = $_.Exception.Response.StatusCode.value__
  $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
  $reader.BaseStream.Position = 0
  $errBody = $reader.ReadToEnd()
  Write-Host "HTTP $status" -ForegroundColor Red
  Write-Host $errBody
}
