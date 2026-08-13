# Files & Backups

## POST /uploads

Upload a file attachment.

```http
POST /api/v1/uploads
```

Supports multipart form data or raw binary upload.

Multipart fields include:

- `file` — required
- `file_name`
- `project_id`

For raw binary uploads, send the file directly and use `Content-Type` and optionally `X-File-Name`.

## GET /uploads

Get upload information.

```http
GET /api/v1/uploads
```

## DELETE /uploads

Delete an uploaded file.

```http
DELETE /api/v1/uploads
```

## GET /backups

List available Todoist backups.

```http
GET /api/v1/backups
```

Query:

- `mfa_token` where required

Access can depend on `backups:read`, `data:read_write`, personal tokens, and MFA.

## GET /backups/download

Download a backup archive.

```http
GET /api/v1/backups/download
```

Query:

- `file` — required

The endpoint validates the backup and redirects to a short-lived signed download URL.
