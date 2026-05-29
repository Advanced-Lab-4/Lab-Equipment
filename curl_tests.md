# Edge Case Testing Documentation

## Test Environment

- **OS:** Windows 10/11
- **Shell:** Windows PowerShell
- **Rails Version:** 8.1.3
- **Ruby Version:** 4.0.0

## PowerShell Helper Function

Before running any tests, define this helper function in your PowerShell session:

```powershell
function Test-Api {
    param(
        [string]$Uri,
        [string]$Method = "GET",
        [string]$Body = $null
    )
    try {
        $params = @{ Uri = $Uri; Method = $Method; UseBasicParsing = $true }
        if ($Body) {
            $params.ContentType = "application/json"
            $params.Body = $Body
        }
        $response = Invoke-WebRequest @params
        Write-Host ""
        Write-Host "HTTP Status: $($response.StatusCode)"
        Write-Host ""
        $response.Content
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host ""
        Write-Host "HTTP Status: $statusCode"
        Write-Host ""
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $reader.ReadToEnd()
    }
}
```

**Why this function:**
- Windows PowerShell's `curl.exe` corrupts JSON request bodies, causing `400 Bad Request` errors.
- `Invoke-RestMethod` throws red errors on 4xx/5xx responses and doesn't show status codes cleanly.
- `Test-Api` uses native `Invoke-WebRequest` with a `try-catch` wrapper, handling both success and error responses correctly.

---

## Edge Case 1: Equipment with non-existent category_id

**Command:**
```powershell
Test-Api -Uri http://localhost:3000/equipment -Method Post -Body '{"equipment":{"name":"Test","serial_number":"ZZZ-999","status":"available","category_id":999}}'
```

**Response:**
```
HTTP Status: 422

{"errors":["Category must exist"]}
```

**Result:**  PASS (422 as expected, not 500)

---

## Edge Case 2: Duplicate serial number

**Command:**
```powershell
Test-Api -Uri http://localhost:3000/equipment -Method Post -Body '{"equipment":{"name":"Duplicate","serial_number":"LAP-001","status":"available","category_id":5}}'
```

**Response:**
```
HTTP Status: 422

{"errors":["Serial number has already been taken"]}
```

**Result:**  PASS

---

## Edge Case 3: Invalid status value

**Command:**
```powershell
Test-Api -Uri http://localhost:3000/equipment -Method Post -Body '{"equipment":{"name":"Bad Status","serial_number":"ZZZ-998","status":"broken","category_id":5}}'
```

**Response:**
```
HTTP Status: 422

{"errors":["Status is not included in the list"]}
```

**Result:**  PASS

---

## Edge Case 4: Duplicate category name

**Command:**
```powershell
Test-Api -Uri http://localhost:3000/categories -Method Post -Body '{"category":{"name":"Computing"}}'
```

**Response:**
```
HTTP Status: 422

{"errors":["Name has already been taken"]}
```

**Result:**  PASS

---

## Edge Case 5: Maintenance record with non-existent equipment_id

**Command:**
```powershell
Test-Api -Uri http://localhost:3000/maintenance_records -Method Post -Body '{"maintenance_record":{"description":"Test","performed_at":"2024-01-01T00:00:00Z","equipment_id":999}}'
```

**Response:**
```
HTTP Status: 422

{"errors":["Equipment must exist"]}
```

**Result:**  PASS (422 as expected, not 500)

---

## Edge Case 6: Delete category with equipment still assigned

**Command:**
```powershell
Test-Api -Uri http://localhost:3000/categories/5 -Method Delete
```

**Response:**
```
HTTP Status: 409

{"error":"Cannot delete category. 2 equipment items still belong to it."}
```

**Result:**  PASS

---

## Edge Case 7: GET missing category

**Command:**
```powershell
Test-Api -Uri http://localhost:3000/categories/999
```

**Response:**
```
HTTP Status: 404

{"error":"Category not found"}
```

**Result:**  PASS

---

## Edge Case 8: GET missing equipment

**Command:**
```powershell
Test-Api -Uri http://localhost:3000/equipment/999
```

**Response:**
```
HTTP Status: 404

{"error":"Equipment not found"}
```

**Result:**  PASS

---

## Edge Case 9: PATCH missing category

**Command:**
```powershell
Test-Api -Uri http://localhost:3000/categories/999 -Method Patch -Body '{"category":{"name":"Ghost"}}'
```

**Response:**
```
HTTP Status: 404

{"error":"Category not found"}
```

**Result:**  PASS

---

## Edge Case 10: Future maintenance date

**Command:**
```powershell
Test-Api -Uri http://localhost:3000/maintenance_records -Method Post -Body '{"maintenance_record":{"description":"Future fix","performed_at":"2030-01-01T00:00:00Z","equipment_id":1}}'
```

**Response:**
```
HTTP Status: 422

{"errors":["Performed at cannot be in the future"]}
```

**Result:**  PASS

---

## Summary

| Edge Case | Scenario | Expected Status | Actual Status | Result |
|-----------|----------|----------------|---------------|--------|
| 1 | Non-existent category_id | 422 | 422 | Success |
| 2 | Duplicate serial number | 422 | 422 | Success |
| 3 | Invalid status value | 422 | 422 | Success |
| 4 | Duplicate category name | 422 | 422 | Success |
| 5 | Non-existent equipment_id | 422 | 422 | Success |
| 6 | Delete category with equipment | 409 | 409 | Success |
| 7 | GET missing category | 404 | 404 | Success |
| 8 | GET missing equipment | 404 | 404 | Success |
| 9 | PATCH missing category | 404 | 404 | Success |
| 10 | Future maintenance date | 422 | 422 | Success |

**All 10 edge cases passed.**
