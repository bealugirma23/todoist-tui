# Sections

## GET /sections

Get active sections.

```http
GET /api/v1/sections
```

Query:

- `project_id`
- `cursor`
- `limit`
- `public_key`

## POST /sections

Create a section.

```http
POST /api/v1/sections
```

Body:

- `name` — required
- `project_id` — required
- `order`
- `description`

## GET /sections/{section_id}

Get one section.

```http
GET /api/v1/sections/{section_id}
```

Optional query:

- `public_key`

## POST /sections/{section_id}

Update a section.

```http
POST /api/v1/sections/{section_id}
```

Body:

- `name`
- `section_order`
- `is_collapsed`
- `description`

## DELETE /sections/{section_id}

Delete a section and its tasks.

```http
DELETE /api/v1/sections/{section_id}
```

## POST /sections/{section_id}/archive

Archive a section.

```http
POST /api/v1/sections/{section_id}/archive
```

## POST /sections/{section_id}/unarchive

Unarchive a section.

```http
POST /api/v1/sections/{section_id}/unarchive
```

## GET /sections/search

Search active sections by name.

```http
GET /api/v1/sections/search
```

Query:

- `query` — required
- `project_id`
- `cursor`
- `limit`
