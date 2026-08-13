# Todoist API v1 — Endpoint Reference

Official source: https://developer.todoist.com/api/v1/

Base URL:

```text
https://api.todoist.com/api/v1
```

This folder documents the REST-style endpoints exposed by the current Todoist API v1 documentation. It also includes the `/sync` endpoint because Todoist documents it as part of API v1 and notes that some operations are only available through Sync.

## Authentication

Most API requests use:

```http
Authorization: Bearer YOUR_ACCESS_TOKEN
```

OAuth uses Todoist's OAuth endpoints outside the `/api/v1` base path. See `auth.md`.

## Pagination

Cursor pagination is used by many list endpoints:

```http
GET /api/v1/tasks?limit=50
```

Then use the returned `next_cursor`:

```http
GET /api/v1/tasks?cursor=NEXT_CURSOR&limit=50
```

Todoist documents a default page size of 50 and a maximum of 200 for the standard cursor-paginated endpoints. Keep the same filters/sorting parameters when following a cursor.

## Endpoint index

| Area | File | Endpoints |
|---|---|---:|
| Authentication & token management | `auth.md` | 4 |
| Tasks | `tasks.md` | 11 |
| Projects | `projects.md` | 13 |
| Sections | `sections.md` | 8 |
| Labels | `labels.md` | 8 |
| Comments | `comments.md` | 4 |
| Folders | `folders.md` | 4 |
| Workspaces | `workspaces.md` | 15 |
| Reminders & notifications | `reminders.md` | 5 |
| Templates | `templates.md` | 5 |
| Files & backups | `files.md` | 5 |
| User, activity & settings | `user-activity.md` | 2 |
| IDs | `ids.md` | 1 |
| Sync | `sync.md` | 1 |
| **API v1 HTTP endpoints** | | **93** |

> Note: Todoist's API v1 documentation also describes product-plan restrictions and Sync commands. Sync is one HTTP endpoint with many command types, so those commands are documented separately in `sync.md` rather than counted as separate HTTP endpoints.

## Important v1 behavior

- Endpoints are lowercase.
- The v1 API uses the newer opaque resource IDs for most objects.
- `/tasks`, `/projects`, `/sections`, `/comments`, and `/labels` use unified JSON error responses.
- Several list endpoints use cursor-based pagination.
- The old `filter` and `lang` parameters were removed from `GET /tasks`; filtering is now handled by `GET /tasks/filter`.
- `/sync` is `POST` only in v1.

## Scope note

The manifest contains **93 `/api/v1` HTTP endpoints** plus the two OAuth endpoints used by the authorization flow. Todoist's `/sync` is counted once as an HTTP endpoint; its many Sync commands are documented as operations inside that endpoint rather than separate HTTP routes.
