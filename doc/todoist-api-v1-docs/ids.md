# ID Mappings

## GET /id_mappings/{obj_name}/{obj_ids}

Translate IDs between the legacy/v1 and newer ID formats.

```http
GET /api/v1/id_mappings/{obj_name}/{obj_ids}
```

Path parameters:

- `obj_name` — one of `sections`, `tasks`, `comments`, `reminders`, `location_reminders`, `projects`
- `obj_ids` — comma-separated IDs

The documented endpoint supports up to 100 IDs of the same object type per request.

Example:

```http
GET /api/v1/id_mappings/tasks/918273645,918273646
```
