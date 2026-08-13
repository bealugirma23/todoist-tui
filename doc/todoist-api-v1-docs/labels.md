# Labels

## GET /labels

Get personal labels.

```http
GET /api/v1/labels
```

Query:

- `cursor`
- `limit`

## POST /labels

Create a personal label.

```http
POST /api/v1/labels
```

Body:

- `name` — required
- `order`
- `color`
- `is_favorite`

## GET /labels/{label_id}

Get a personal label.

```http
GET /api/v1/labels/{label_id}
```

## POST /labels/{label_id}

Update a personal label.

```http
POST /api/v1/labels/{label_id}
```

Body:

- `name`
- `order`
- `color`
- `is_favorite`

## DELETE /labels/{label_id}

Delete a personal label and remove its task occurrences.

```http
DELETE /api/v1/labels/{label_id}
```

## GET /labels/search

Search labels by name.

```http
GET /api/v1/labels/search
```

Query:

- `query` — required
- `cursor`
- `limit`

## GET /labels/shared

Get shared-label names from active tasks.

```http
GET /api/v1/labels/shared
```

Query:

- `omit_personal`
- `cursor`
- `limit`

## POST /labels/shared/rename

Rename a shared label across active tasks.

```http
POST /api/v1/labels/shared/rename
```

Body:

```json
{
  "name": "waiting",
  "new_name": "follow-up"
}
```

## POST /labels/shared/remove

Remove a shared label from active tasks.

```http
POST /api/v1/labels/shared/remove
```

Body:

```json
{
  "name": "waiting"
}
```
