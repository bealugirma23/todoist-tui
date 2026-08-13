# Folders

Folders are workspace project containers.

## GET /folders

List folders in a workspace.

```http
GET /api/v1/folders
```

Query:

- `workspace_id` — required
- `cursor`
- `limit`

## POST /folders

Create a folder.

```http
POST /api/v1/folders
```

Body:

- `name` — required
- `workspace_id` — required
- `default_order`
- `child_order`

## POST /folders/{folder_id}

Update a folder.

```http
POST /api/v1/folders/{folder_id}
```

Body:

- `name`
- `default_order`

## DELETE /folders/{folder_id}

Delete a folder. Projects in the folder are moved out of it.

```http
DELETE /api/v1/folders/{folder_id}
```
