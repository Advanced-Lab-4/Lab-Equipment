# Lab Equipment API

A RESTful Rails API for tracking laboratory equipment inventory, categories, and maintenance history. Built to replace a chaotic WhatsApp group and whiteboard system with structured, validated data and full CRUD operations.

## Setup Instructions

```bash
git clone <repo-url>
cd lab_equipment_api
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

The API will be available at `http://localhost:3000`.

## Testing with PowerShell (Windows)

If you are testing on Windows PowerShell, use this helper function to avoid JSON parsing errors:

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

**Example usage:**

```powershell
# GET request
Test-Api -Uri http://localhost:3000/categories

# POST request
Test-Api -Uri http://localhost:3000/categories -Method Post -Body '{"category":{"name":"Robotics"}}'

# DELETE request
Test-Api -Uri http://localhost:3000/categories/1 -Method Delete
```

## Data Model

### Categories

| Column | Type   | Rules                                  |
| ------ | ------ | -------------------------------------- |
| name   | string | Required, unique, minimum 3 characters |

### Equipment

| Column        | Type    | Rules                                                                        |
| ------------- | ------- | ---------------------------------------------------------------------------- |
| name          | string  | Required, minimum 3 characters, must contain at least one letter             |
| serial_number | string  | Required, unique, format: `XXX-NNN` (e.g., `LAP-001`)                        |
| status        | string  | Required, one of: `available`, `in_use`, `maintenance`. Default: `available` |
| category_id   | integer | Required, foreign key to categories                                          |

### Maintenance Records

| Column       | Type     | Rules                              |
| ------------ | -------- | ---------------------------------- |
| description  | text     | Required                           |
| performed_at | datetime | Required, cannot be in the future  |
| equipment_id | integer  | Required, foreign key to equipment |

## API Endpoints

### Categories

| Method | Path              | Description                                                  |
| ------ | ----------------- | ------------------------------------------------------------ |
| GET    | `/categories`     | List all categories, ordered by name                         |
| GET    | `/categories/:id` | Show one category, includes equipment count                  |
| POST   | `/categories`     | Create a new category                                        |
| PATCH  | `/categories/:id` | Update a category                                            |
| DELETE | `/categories/:id` | Delete a category. Returns `409` if equipment still assigned |

### Equipment

| Method | Path             | Description                                                        |
| ------ | ---------------- | ------------------------------------------------------------------ |
| GET    | `/equipment`     | List all equipment, ordered by name. Filter: `?status=available`   |
| GET    | `/equipment/:id` | Show one equipment item, includes category and maintenance records |
| POST   | `/equipment`     | Create equipment. Validates category exists                        |
| PATCH  | `/equipment/:id` | Update equipment                                                   |
| DELETE | `/equipment/:id` | Delete equipment. Cascades maintenance records                     |

### Maintenance Records

| Method | Path                       | Description                                                                       |
| ------ | -------------------------- | --------------------------------------------------------------------------------- |
| GET    | `/maintenance_records`     | List all records, ordered by `performed_at` descending. Filter: `?equipment_id=3` |
| GET    | `/maintenance_records/:id` | Show one record, includes equipment name                                          |
| POST   | `/maintenance_records`     | Create a record. Validates equipment exists                                       |
| PATCH  | `/maintenance_records/:id` | Update a record                                                                   |
| DELETE | `/maintenance_records/:id` | Delete a record                                                                   |

## Business Rules

1. **Serial Number Format** — Must match `XXX-NNN` (three uppercase letters, dash, three digits).  
   Valid: `LAP-001`, `MIC-042`. Invalid: `lap-001`, `LAP01`, `LAP-1`.

2. **Maintenance Date Cannot Be Future** — `performed_at` must be today or earlier.

3. **Category Name Minimum Length** — Must be at least 3 characters.

4. **Equipment Name Must Be Real** — Minimum 3 characters and must contain at least one letter.  
   Invalid: `123`, `!!!`, `--`, `AB`.

## Response Format

### Success

- `201 Created` — Record created
- `200 OK` — Record read or updated
- `204 No Content` — Record deleted (empty body)

### Errors

- `404 Not Found` — Record does not exist
  ```json
  { "error": "Category not found" }
  ```
- `422 Unprocessable Entity` — Validation failed
  ```json
  { "errors": ["Name can't be blank", "Serial number has already been taken"] }
  ```
- `409 Conflict` — Cannot delete category with existing equipment
  ```json
  { "error": "Cannot delete category. 4 equipment items still belong to it." }
  ```

## Task Assignment

| Task | Description                              | Owner  | Branch               | Status |
| ---- | ---------------------------------------- | ------ | -------------------- | ------ |
| 1    | Data model and migrations                | Eyoel  | `task-1-model`       | Done   |
| 2    | Seed data                                | Rediet | `task-2-seeds`       | Done   |
| 3    | Category CRUD with delete protection     | Dibora | `task-3-categories`  | Done   |
| 4    | Equipment CRUD with filtering            | Dibora | `task-4-equipment`   | Done   |
| 5    | MaintenanceRecord CRUD with filtering    | Kidus  | `task-5-maintenance` | Done   |
| 6    | Business rules (4 custom validations)    | Rediet | `task-6-rules`       | Done   |
| 7    | Edge case testing and curl documentation | Kidus  | `task-7-edge-cases`  | Done   |

## Edge Case Testing

All 10 edge cases are documented in `curl_tests.md` and verified against the spec:

1. Equipment with non-existent `category_id` → `422`
2. Duplicate serial number → `422`
3. Invalid status value → `422`
4. Duplicate category name → `422`
5. Maintenance record with non-existent `equipment_id` → `422`
6. Delete category with equipment still assigned → `409`
7. GET missing category → `404`
8. GET missing equipment → `404`
9. PATCH missing category → `404`
10. Future maintenance date → `422`

## Database Constraints

Enforced at the migration level:

- `categories.name` — unique index
- `equipment.serial_number` — unique index
- `equipment.category_id` — foreign key to categories
- `equipment.status` — database default of `available`
- `maintenance_records.equipment_id` — foreign key to equipment
- `maintenance_records` — composite index on `[equipment_id, performed_at]`

## Team

Built by a 4-person team using feature branches and Pull Requests. Every task was authored by its assigned owner and merged via PR into `main`.
