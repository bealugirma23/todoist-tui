# Projects

## GET /projects

Get active projects.

```http
GET /api/v1/projects
```

Query parameters:

- `folder_id`
- `workspace_id`
- `cursor`
- `limit`

If `folder_id` is provided, it takes precedence over `workspace_id`.

## POST /projects

Create a project.

```http
POST /api/v1/projects
```

Common body fields:

- `name` — required
- `description`
- `color`
- `parent_id`
- `workspace_id`
- `folder_id`
- `view_style`
- `is_favorite`
- `is_collapsed`
- `child_order`

## GET /projects/{project_id}

Get one project.

```http
GET /api/v1/projects/{project_id}
```

## POST /projects/{project_id}

Update a project.

```http
POST /api/v1/projects/{project_id}
```

Common fields:

- `name`
- `description`
- `color`
- `is_favorite`
- `view_style`
- `child_order`
- `is_collapsed`
- `folder_id`

## DELETE /projects/{project_id}

Delete a project and its sections/tasks.

```http
DELETE /api/v1/projects/{project_id}
```

## POST /projects/{project_id}/archive

Archive a project.

```http
POST /api/v1/projects/{project_id}/archive
```

## POST /projects/{project_id}/unarchive

Unarchive a project.

```http
POST /api/v1/projects/{project_id}/unarchive
```

## POST /projects/{project_id}/join

Join a workspace project.

```http
POST /api/v1/projects/{project_id}/join
```

## GET /projects/archived

Get archived personal/user projects.

```http
GET /api/v1/projects/archived
```

Query:

- `cursor`
- `limit`

## GET /projects/search

Search active projects by name.

```http
GET /api/v1/projects/search
```

Query:

- `query` — required
- `cursor`
- `limit`

`*` can be used as a wildcard.

## GET /projects/{project_id}/collaborators

Get project collaborators.

```http
GET /api/v1/projects/{project_id}/collaborators
```

Query:

- `cursor`
- `limit`
- `public_key`

## GET /projects/{project_id}/full

Get the project's full data.

```http
GET /api/v1/projects/{project_id}/full
```

This is the v1 replacement for the old project-data endpoint.

## GET /projects/permissions

Get available project/workspace roles and actions.

```http
GET /api/v1/projects/permissions
```
